classdef VariableUtilityPlayer < Player 
    %VariableUtilityPlayer class
    %   Player that chooses actions based on weighted utility values.

    properties (SetAccess=protected)
        destinationsCompleted

        routeUtilities
        routeLengths
        routeIds
        colorUtilities
        
        potentialDiscount = 1

        checkDestinations

    end

    properties (SetAccess=immutable)
        lengthWeight = 1
        destinationTicketWeight = 1
    end

    methods(Abstract)
        drawCards = shouldDrawDestinationCards(player,board);
    end


    methods (Access = public)
        function obj = VariableUtilityPlayer(playerNumber, lengthWeight, destinationTicketWeight)
            obj@Player(playerNumber);
            obj.lengthWeight = lengthWeight;
            obj.destinationTicketWeight = destinationTicketWeight;
        end

        function initPlayerSpecific(player, startingHand, board, destinationsDeck, nStartingTrains)
            arguments
                player Player
                startingHand TrainCard
                board Board
                destinationsDeck DestinationsDeck
                nStartingTrains
            end
            player.checkDestinations=false;
            player.destinationsCompleted =zeros(1,length(player.destinationCardsHand));
        end

        function [route, card, drawDestinationCards] = chooseAction(player, board, claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards)
            arguments
                player Player
                board Board
                claimableRoutes Route
                claimableRouteColors Color
                drawableCards TrainCard
                drawDestinationCards
            end

            % potential discount is based on number of trains players have
            % left
            playerTrains = Rules.getPlayerTrains(board, player.allPlayers, player.nStartingTrains);
            player.potentialDiscount=1-(min(playerTrains)/(player.nStartingTrains)-1)^4;
            disp(player.potentialDiscount);

            drawDestinationCards=false;
            if player.checkDestinations
                player.destinationsCompleted=Rules.getTicketsCompleted(board, player);
                player.checkDestinations=false;
            end
            if player.shouldDrawDestinationCards(board)
                drawDestinationCards=true;
                card=0;
                route=0;
                player.checkDestinations=true;
            elseif isempty(drawableCards)                
                 % claim longest claimable route
                [~, sortedIndices] = sort([claimableRoutes.length], 'descend');
                route = sortedIndices(1);
                card = 0;
                drawDestinationCards = false;
            else
                player.getUtilityValues(board, playerTrains([player.allPlayers.color]==player.color));
                
                maxUtility=0;
                card=0;
                route=0;
                colorsInHand=containers.Map;
                for ix=1:length(claimableRoutes)
                    routeObj = claimableRoutes(ix);
                    color = claimableRouteColors(ix);
                    claimUtility=player.routeUtilities(player.routeIds==routeObj.id);
                    if claimUtility ~= 0 && claimUtility>maxUtility
                        if ~isKey(colorsInHand,color.string)
                            colorsInHand(color.string) = length(find([player.trainCardsHand.color]==color));
                        end
                        handUtility=player.colorUtilities(color.string)*colorsInHand(color.string)+...
                            player.colorUtilities("multicolored")*(routeObj.length-colorsInHand(color.string));
                        % check if utility of claiming route is higher than
                        % utility of having it in hand
                        if claimUtility >= handUtility && claimUtility > maxUtility
                            route=ix;
                            maxUtility=claimUtility;
                        end
                    end
                end
                for ix=1:length(drawableCards)
                    cardObj = drawableCards(ix);
                    utility = 0;
                    if cardObj.color == Color.unknown
                        % set drawing card utility to average of all colors
                        utility = mean(cell2mat(player.colorUtilities.values));
                    else
                        utility = player.colorUtilities(cardObj.color.string);
                    end
                    %check if card provides more utility
                    %draw non-multicolored card if multicolored card has
                    %same utility
                    if utility>maxUtility || (utility==maxUtility && card>0 && drawableCards(card).color==Color.multicolored) || maxUtility==0
                        maxUtility = utility;
                        route=0;
                        card=ix;                       
                    end
                end
                %draw a card if no other actions provide utility
                if route==0 && card==0 && ~drawDestinationCards
                    card=length(drawableCards);
                end
                if route~=0
                    player.checkDestinations=true;
                end
            end
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            [~, sortedIndices] = sort([destinationCards.pointValue]);
            keptCardIndices=sortedIndices(1);
        end

        

        function getUtilityValues(player, board, trainsLeft)
            unclaimedRoutes = board.getUnclaimedRoutes();
            %don't bother recalculating utility if no new routes were claimed
            if isempty(player.routeUtilities) || ~all(ismember(player.routeIds, [unclaimedRoutes.id]))
                player.getRouteUtilities(board, unclaimedRoutes, trainsLeft);
                player.getColorUtilities(unclaimedRoutes);
            end
        end

        function getRouteUtilities(player, board, unclaimedRoutes, trainsLeft)

            % initialize route utilities
            player.routeUtilities = zeros(length(unclaimedRoutes),1);
            player.routeLengths = zeros(length(unclaimedRoutes),1);
            player.routeIds = transpose([unclaimedRoutes.id]);
            
            %make graph which includes only unowned routes and
            %routes owned by the player
            destinationGraph = graph(board.routeGraph.Edges(or(board.routeGraph.Edges.Owner==player.color,board.routeGraph.Edges.Owner==Color.gray), :));
            
            %set weight of owned routes to zero
            ownedEdges=(destinationGraph.Edges.Owner==player.color);
            destinationGraph.Edges.Weight(ownedEdges)=0;

            %get indices of destination ticket cards in player's hand that
            %have not been conpleted
            unfinishedDestinationsIx = find(not(player.destinationsCompleted));   
            unfinishedDestinations = player.destinationCardsHand(unfinishedDestinationsIx);
            baselineDistances=Inf(1,length(unfinishedDestinations));
            for destIx=1:length(unfinishedDestinations)                
                s=unfinishedDestinations(destIx).firstLocation;
                t=unfinishedDestinations(destIx).secondLocation;
                if any(ismember(destinationGraph.Nodes.Name, s.string)) && ...
                            any(ismember(destinationGraph.Nodes.Name, t.string))
                    [~,d] = shortestpath(destinationGraph,...
                        s.string,...
                        t.string);
                    baselineDistances(destIx)=d;
                end
            end
            [edgeIndices,~]=find(destinationGraph.Edges.id==[unclaimedRoutes.id]);
            for ix=1:length(unclaimedRoutes)
                route = unclaimedRoutes(ix);
                player.routeLengths(ix) = route.length;

                %length utility score
                player.routeUtilities(ix) = player.lengthWeight * VariableUtilityPlayer.getRouteLengthUtility(route);

                %destination ticket utility score
                if player.destinationTicketWeight>0
                    destinationUtility=0;

                    destGraphCopy=destinationGraph;
                    e=edgeIndices(ix);
                    destGraphCopy.Edges.Weight(e)=0;
                    for destIx=1:length(unfinishedDestinations)
                        d=baselineDistances(destIx);
                        dest = unfinishedDestinations(destIx);

                        %general theory: check how much claiming this route
                        %would reduce the length of the shortest path to
                        %complete the destination ticket (player claimed
                        %routes are considered to be 0 length)
                        if d~=Inf && d <= trainsLeft
                            [~,newd]=shortestpath(destGraphCopy,dest.firstLocation.string,dest.secondLocation.string);
                            if newd~=Inf
                                %utility is linear based on shortest path
                                %length reduction and destination ticket point
                                %value
                                destinationUtility = max(destinationUtility,...
                                    VariableUtilityPlayer.getDestinationTicketUtility(d,newd,dest.pointValue));
                            end
                        end
                    end
                    player.routeUtilities(ix) = player.routeUtilities(ix)+...
                            player.destinationTicketWeight*destinationUtility;
                end
            end
        end

        function getColorUtilities(player, unclaimedRoutes)
            colors = enumeration('Color');
            colors(or(colors == Color.unknown, colors==Color.gray)) = [];
            player.colorUtilities = containers.Map(colors.string,zeros(length(colors),1));
            grayUtility = 0;
            
            for colorIx=1:length(colors)
                color = colors(colorIx);
                routesOfColor = unclaimedRoutes(or(color==Color.multicolored, [unclaimedRoutes.color]==color));
                [rows,~] = find([routesOfColor.id]==player.routeIds);
                
                if isempty(rows)
                    utility=0;
                else
                    %card utility is the route utility which the color can be
                    %used to claim divided by the length of the route
                    utility= max(player.routeUtilities(rows)./player.routeLengths(rows)*player.potentialDiscount);
                end
                if color ~= Color.gray
                    player.colorUtilities(color.string)=utility;               
                else
                    grayUtility=utility;
                end
            end

            grayRouteColor = Color.gray;
            mostColorsInHand = 0;
            for colorIx=1:length(colors)
                color = colors(colorIx);
                if color ~= Color.multicolored && player.colorUtilities(color.string) < grayUtility
                    colorsInHand = length(find([player.trainCardsHand.color]==color));
                    if colorsInHand > mostColorsInHand
                        mostColorsInHand = colorsInHand;
                        grayRouteColor = color;
                    end
                end
            end
            if grayRouteColor~=Color.gray
                %the color most common in the player's hand which has less 
                % utility than the gray utility is treated as the color for the
                % gray routes
                player.colorUtilities(grayRouteColor.string)=grayUtility;
            end
        end
    end

    methods (Static)
        function utility = getRouteLengthUtility(route)
            switch route.length
                case 1
                    utility = 1;
                case 2
                    utility = 2;
                case 3
                    utility = 4;
                case 4
                    utility = 7;
                case 5
                    utility = 10;
                case 6
                    utility = 15;
                otherwise
                    utility = 0;
            end

        end

        function utility = getDestinationTicketUtility(distance, newDistance, ticketPoints)
            reduction=max(0,min((1-newDistance/distance),1));
            utility=reduction*ticketPoints*2;
        end
    end
end