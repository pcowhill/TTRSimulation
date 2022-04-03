classdef VariableUtilityPlayer < Player 
    %VariableUtilityPlayer class
    %   Player that chooses actions based on weighted utility values.

    properties (SetAccess=protected)
        destinationsCompleted

        routeUtilities
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

        function chosenActions = chooseAction(player, board, possibleActions)
            arguments
                player Player
                board Board
                possibleActions struct
            end

            chosenActions = struct();

            % potential discount is based on number of trains players have
            % left
            playerTrains = Rules.getPlayerTrains(board, player.allPlayers, player.nStartingTrains);
            player.potentialDiscount=1-(min(playerTrains)/player.nStartingTrains-1)^4;
            disp(player.potentialDiscount);

            chosenActions.drawDestinationCards=false;
            if player.checkDestinations
                player.destinationsCompleted=Rules.getTicketsCompleted(board, player);
                player.checkDestinations=false;
            end
            if player.shouldDrawDestinationCards(board)
                chosenActions.drawDestinationCards=true;
                chosenActions.card=0;
                chosenActions.route=0;
                player.checkDestinations=true;
            elseif isempty(possibleActions.drawableCards)                
                 % claim longest claimable route
                [~, sortedIndices] = sort([possibleActions.claimableRoutes.length], 'descend');
                chosenActions.route = sortedIndices(1);
                chosenActions.card = 0;
                chosenActions.drawDestinationCards = false;
            else
                player.getUtilityValues(board, playerTrains([player.allPlayers.color]==player.color));
                
                maxUtility=0;
                chosenActions.card=0;
                chosenActions.route=0;
                for ix=1:length(possibleActions.claimableRoutes)
                    routeObj = possibleActions.claimableRoutes(ix);
                    color = possibleActions.claimableRouteColors(ix);
                    claimUtility=player.routeUtilities.utility(player.routeUtilities.id==routeObj.id);
                    if claimUtility ~= 0
                        colorsInHand = length(find([player.trainCardsHand.color]==color));
                        handUtility=player.colorUtilities(color.string)*colorsInHand+...
                            player.colorUtilities("multicolored")*(routeObj.length-colorsInHand);
                        % check if utility of claiming route is higher than
                        % utility of having it in hand
                        if claimUtility >= handUtility && claimUtility > maxUtility
                            chosenActions.route=ix;
                            maxUtility=claimUtility;
                        end
                    end
                end
                for ix=1:length(possibleActions.drawableCards)
                    cardObj = possibleActions.drawableCards(ix);
                    if cardObj.color == Color.unknown
                        % set drawing card utility to average of all colors
                        utility = mean(cell2mat(player.colorUtilities.values));
                    else
                        utility = player.colorUtilities(cardObj.color.string);
                    end
                    %check if card provides more utility
                    %draw non-multicolored card if multicolored card has
                    %same utility
                    if utility>maxUtility || (utility==maxUtility && chosenActions.card>0 && possibleActions.drawableCards(chosenActions.card).color==Color.multicolored) || maxUtility==0
                        maxUtility = utility;
                        chosenActions.route=0;
                        chosenActions.card=ix;                       
                    end
                end
                %draw a card if no other actions provide utility
                if chosenActions.route==0 && chosenActions.card==0 && ~chosenActions.drawDestinationCards
                    chosenActions.card=length(possibleActions.drawableCards);
                end
                if chosenActions.route~=0
                    player.checkDestinations=true;
                end
            end
        end

        function tf = canTakeAction(player, possibleActions)
            arguments
                player Player
                possibleActions struct
            end
            tf = (isempty(possibleActions.claimableRoutes) && ...
                  isempty(possibleActions.drawableCards) && ...
                  ~possibleActions.canDrawDestinationCards);
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

        function utility = getRouteLengthUtility(player, route)
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

        function getUtilityValues(player, board, trainsLeft)
            unclaimedRoutes = board.getUnclaimedRoutes();
            %don't bother recalculating utility if no new routes were claimed
            if isempty(player.routeUtilities) || ~all(ismember(player.routeUtilities.id, [unclaimedRoutes.id]))
                player.getRouteUtilities(board, unclaimedRoutes, trainsLeft);
                player.getColorUtilities(unclaimedRoutes);
            end
        end

        function getRouteUtilities(player, board, unclaimedRoutes, trainsLeft)

            % initialize route utilities
            utility = zeros(length(unclaimedRoutes),1);
            routeLength = zeros(length(unclaimedRoutes),1);
            id = transpose([unclaimedRoutes.id]);
            player.routeUtilities = table(id, utility, routeLength);

            %make graph which includes only unowned routes and
            %routes owned by the player
            destinationGraph = graph(board.routeGraph.Edges(or(board.routeGraph.Edges.Owner==player.color,board.routeGraph.Edges.Owner==Color.gray), :));
            
            %set weight of owned routes to zero
            ownedEdges=(destinationGraph.Edges.Owner==player.color);
            destinationGraph.Edges.Weight(ownedEdges)=0;

            %get indices of destination ticket cards in player's hand that
            %have not been conpleted
            unfinishedDestinationsIx = find(not(player.destinationsCompleted));    
            for ix=1:length(unclaimedRoutes)
                route = unclaimedRoutes(ix);
                player.routeUtilities.routeLength(ix) = route.length;

                %length utility score
                player.routeUtilities.utility(ix) = player.lengthWeight * player.getRouteLengthUtility(route);

                %destination ticket utility score
                if player.destinationTicketWeight>0
                    destinationUtility=0;
                    for destIx=1:length(unfinishedDestinationsIx)
                        dest = player.destinationCardsHand(unfinishedDestinationsIx(destIx));
                        node1=find(destinationGraph.Nodes.Name==route.locations(1));
                        node2=find(destinationGraph.Nodes.Name==route.locations(2)); 

                        %general theory: check how much claiming this route
                        %would reduce the length of the shortest path to
                        %complete the destination ticket (player claimed
                        %routes are considered to be 0 length)
                        if any(ismember(destinationGraph.Nodes.Name, dest.firstLocation.string)) && ...
                                any(ismember(destinationGraph.Nodes.Name, dest.secondLocation.string))
                            [~,d]=shortestpath(destinationGraph,dest.firstLocation.string,dest.secondLocation.string);
                            if d~=Inf && d <= trainsLeft
                                destGraphCopy=destinationGraph;
                                e=find(destGraphCopy.Edges.id==route.id);
                                destGraphCopy.Edges.Weight(e)=0;
                                [~,newd]=shortestpath(destGraphCopy,dest.firstLocation.string,dest.secondLocation.string);
                                if newd~=Inf
                                    %utility is linear based on shortest path
                                    %length reduction and destination ticket point
                                    %value
                                    reduction=max(0,min((1-newd/d),1));
                                    util=reduction*dest.pointValue*2;
                                    destinationUtility = max(destinationUtility, util);
                                end
                            end
                        end
                    end
                    player.routeUtilities.utility(ix) = player.routeUtilities.utility(ix)+...
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
                [rows,~] = find([routesOfColor.id]==player.routeUtilities.id);
                
                if isempty(rows)
                    utility=0;
                else
                    %card utility is the route utility which the color can be
                    %used to claim divided by the length of the route
                    utility= max(player.routeUtilities.utility(rows)./player.routeUtilities.routeLength(rows)*player.potentialDiscount);
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
end