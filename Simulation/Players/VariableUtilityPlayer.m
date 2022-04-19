classdef VariableUtilityPlayer < Player 
    %VariableUtilityPlayer class
    %   Player that chooses actions based on weighted utility values.

    properties (SetAccess=protected)
        destinationsCompleted

        routeUtilities
        routeLengths
        routeIds
        colorUtilities
        multicoloredColor
        
        potentialDiscount = 1

        checkDestinations

    end

    properties (SetAccess=immutable)
        lengthWeight = 0
        destinationTicketWeight = 0
        deviantWeight=0
    end

    methods(Abstract)
        drawCards = shouldDrawDestinationCards(player,board);
        getPotentialDiscount(player,board);
    end


    methods (Access = public)
        function obj = VariableUtilityPlayer(playerNumber, lengthWeight, destinationTicketWeight, deviantWeight)
            obj@Player(playerNumber);
            obj.lengthWeight = lengthWeight;
            obj.destinationTicketWeight = destinationTicketWeight;
            obj.deviantWeight=deviantWeight;
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
            player.routeIds=[];
            player.routeUtilities=[];
            player.routeLengths=[];
        end

        function chosenActions = chooseAction(player, board, possibleActions)
            arguments
                player Player
                board Board
                possibleActions struct
            end

            chosenActions = struct();

            player.getPotentialDiscount(board);

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
                player.getUtilityValues(board, Rules.getPlayerTrains(board, [player], player.nStartingTrains));
                
                maxUtility=0;
                chosenActions.card=0;
                chosenActions.route=0;
                colorsInHand=containers.Map;
                for ix=1:length(possibleActions.claimableRoutes)
                    routeObj = possibleActions.claimableRoutes(ix);
                    color = possibleActions.claimableRouteColors(ix);
                    claimUtility=player.routeUtilities(player.routeIds==routeObj.id);
                    if claimUtility ~= 0 && claimUtility>maxUtility
                        handColor = color;
                        if color==Color.multicolored && player.multicoloredColor~=Color.gray
                            handColor = player.multicoloredColor;
                        end
                        if ~isKey(colorsInHand,handColor.string)
                            colorsInHand(handColor.string) = length(find([player.trainCardsHand.color]==handColor));
                        end
                        handUtility=player.potentialDiscount*...
                            (player.colorUtilities(handColor.string)*colorsInHand(handColor.string)+...
                            player.colorUtilities("multicolored")*max(0,routeObj.length-colorsInHand(handColor.string)));
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
                    if ~isKey(colorsInHand,cardObj.color.string)
                        colorsInHand(cardObj.color.string) = length(find([player.trainCardsHand.color]==cardObj.color));
                    end
                    inHandWeight=(colorsInHand(cardObj.color.string)+player.potentialDiscount)/(colorsInHand(cardObj.color.string)+1);
                    if cardObj.color == Color.unknown
                        % set drawing card utility to average of all colors
                        utility = mean(cell2mat(player.colorUtilities.values))*player.potentialDiscount;
                    else
                        utility = player.colorUtilities(cardObj.color.string)*inHandWeight;
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

        function tf = cannotTakeAction(player, possibleActions)
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
    end
    methods(Access=protected)      

        function getUtilityValues(player, board, trainsLeft)
            unclaimedRoutes = board.getUnclaimedRoutes();
            player.getRouteUtilities(board, unclaimedRoutes, trainsLeft);
            player.getColorUtilities(unclaimedRoutes);
        end

        function getRouteUtilities(player, board, unclaimedRoutes, trainsLeft)
            % initialize route utilities
            player.routeUtilities = zeros(length(unclaimedRoutes),1);
            player.routeLengths = zeros(length(unclaimedRoutes),1);
            player.routeIds = transpose([unclaimedRoutes.id]);
            
            %make graph which includes only unowned routes and
            %routes owned by the player
            allDestinationGraphs={};
            allPlayerNodes={};
            nodeDistances={};
            for playerIx=1:length(player.allPlayers)
                allDestinationGraphs{playerIx}=graph(board.routeGraph.Edges(or(board.routeGraph.Edges.Owner==player.allPlayers(playerIx).color,board.routeGraph.Edges.Owner==Color.gray), :));
                %set weight of owned routes to zero
                ownedEdges=allDestinationGraphs{playerIx}.Edges.Owner==player.allPlayers(playerIx).color;
                allDestinationGraphs{playerIx}.Edges.Weight(ownedEdges)=0;
                ownedNodes = allDestinationGraphs{playerIx}.Edges.EndNodes(ownedEdges,:);
                allPlayerNodes{playerIx} = unique(reshape(ownedNodes,1,[]));
                nodeDistances{playerIx}=distances(allDestinationGraphs{playerIx},allPlayerNodes{playerIx},allPlayerNodes{playerIx});
                [edgeIndices,~]=find(allDestinationGraphs{playerIx}.Edges.id==[unclaimedRoutes.id]);
                allEdgeIndices{playerIx} = edgeIndices;
            end
            destinationGraph = allDestinationGraphs{[player.allPlayers.color]==player.color};            

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
            edgeIndices=allEdgeIndices{[player.allPlayers.color]==player.color};
            for ix=1:length(unclaimedRoutes)
                route = unclaimedRoutes(ix);
                player.routeLengths(ix) = route.length;

                if route.length > trainsLeft
                    player.routeUtilities(ix) = 0;
                else
    
                    %length utility score
                    lengthUtility=VariableUtilityPlayer.getRouteLengthUtility(route);
                    player.routeUtilities(ix) = player.lengthWeight * lengthUtility;
    
    
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
                                    destinationUtility = destinationUtility + ...
                                        VariableUtilityPlayer.getDestinationTicketUtility(d,newd,dest.pointValue);
                                end
                            end
                        end
                        player.routeUtilities(ix) = player.routeUtilities(ix)+...
                                player.destinationTicketWeight*destinationUtility;
                    end
    
                    if player.deviantWeight > 0
                        deviantUtility=0;
                        deviantRouteLengthUtility = 0;
                        deviantConnectionUtility = 0;
    
                        for playerIx=1:length(player.allPlayers)
                            p = player.allPlayers(playerIx);
                            if p.color ~= player.color
                                if route.color ~= Color.gray
                                    cardsInPlayersHand=length(find([p.publicHand.color]==route.color));
                                    %colorFactor is based on how many cards of
                                    %that color the opposing player has drawn,
                                    %making it more likely they will try to
                                    %claim this route
                                    colorFactor = max(0,min(1,(cardsInPlayersHand-max(0,cardsInPlayersHand-route.length)*0.5)/route.length));
                                    colorFactor = sqrt(colorFactor);
                                    colorFactor = 0.2+0.8*colorFactor;
                                else
                                    colorFactor = 0.2;
                                end
                                
                                %add utility based on the length of the route
                                %and if the opposing player is accumulating the cards to
                                %be able to claim it
                                deviantRouteLengthUtility = max(deviantRouteLengthUtility, colorFactor*lengthUtility);
    
                                %add utility if this route helps connect other
                                %routes claimed by the opposing player,
                                %attempting to block completion of destination
                                %cards
                                destGraphCopy=allDestinationGraphs{playerIx};
                                e=allEdgeIndices{playerIx}(ix);
                                destGraphCopy.Edges.Weight(e)=0;
                                d=nodeDistances{playerIx};
                                newd=distances(destGraphCopy,allPlayerNodes{playerIx},allPlayerNodes{playerIx});
                                if ~isempty(d)
                                    reduction=min(newd./d,[],2);
                                    %12 is about the average point value for a
                                    %destination ticket card
                                    deviantConnectionUtility=max(deviantConnectionUtility, colorFactor*12*(0.5*max(0,1-reduction(1))+0.5*max(0,1-reduction(2))));
                                end
    
                            end
                        end
                        deviantUtility = max(deviantRouteLengthUtility, deviantConnectionUtility);
                        player.routeUtilities(ix) = player.routeUtilities(ix)+...
                                player.deviantWeight*deviantUtility;
                    end
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
                    [utility, i]= max(player.routeUtilities(rows)./player.routeLengths(rows));
                    if color==Color.multicolored
                        player.multicoloredColor=unclaimedRoutes([unclaimedRoutes.id]==player.routeIds(i)).color;
                    end
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
                if player.multicoloredColor == Color.gray
                    player.multicoloredColor = grayRouteColor;
                end
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
            utility=reduction*ticketPoints;
        end
    end
end