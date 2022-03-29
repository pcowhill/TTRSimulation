classdef VariableUtilityPlayer < Player
    %Long Route Player class
    %   Player that is just trying to claim long routes.

    properties (SetAccess=protected)
        destinationsCompleted

        routeUtilities
        colorUtilities

        lengthWeight = 1
        longestRouteWeight=0
        destinationTicketWeight = 0
        potentialDiscount = 0.9

        checkDestinations


    end

    methods(Abstract)
        drawCards = shouldDrawDestinationCards(player,board);
    end


    methods (Access = public)
        function obj = VariableUtilityPlayer(playerNumber, lengthWeight, longestRouteWeight, destinationTicketWeight)
            obj@Player(playerNumber);
            obj.lengthWeight = lengthWeight;
            obj.longestRouteWeight = longestRouteWeight;
            obj.destinationTicketWeight = destinationTicketWeight;
        end

        function initPlayer(player, startingHand, board, destinationsDeck)
            arguments
                player Player
                startingHand TrainCard
                board Board
                destinationsDeck DestinationsDeck
            end
            initPlayer@Player(player, startingHand, board, destinationsDeck);
            player.checkDestinations=false;
            player.destinationsCompleted =zeros(1,length(player.destinationCardsHand));

        end

        function [route, card, destination] = chooseAction(player, board, claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards)
            arguments
                player Player
                board Board
                claimableRoutes Route
                claimableRouteColors Color
                drawableCards TrainCard
                drawDestinationCards
            end
            destination=0;
            if player.checkDestinations
                player.destinationsCompleted=Rules.getTicketsCompleted(board, player);
                player.checkDestinations=false;
            end
            if player.shouldDrawDestinationCards(board)
                destination=1;
                card=0;
                route=0;
                player.checkDestinations=true;
            elseif isempty(drawableCards)                
                 % claim longest claimable route
                [~, sortedIndices] = sort([claimableRoutes.length], 'descend');
                route = sortedIndices(1);
                card = 0;
                destination = 0;
            else
                player.getUtilityValues(board);
                
                maxUtility=0;
                card=0;
                route=0;
                for ix=1:length(claimableRoutes)
                    routeObj = claimableRoutes(ix);
                    color = claimableRouteColors(ix);
                    claimUtility=player.routeUtilities.utility(player.routeUtilities.id==routeObj.id);
                    colorsInHand = length(find([player.trainCardsHand.color]==color));
                    handUtility=player.colorUtilities(color.string)*length(colorsInHand)+...
                        player.colorUtilities("multicolored")*(routeObj.length-length(colorsInHand));
                    % check if utility of claiming route is higher than
                    % utility of having it in hand
                    if claimUtility > handUtility
                        route=ix;
                        maxUtility=claimUtility;
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
    
                    if utility>maxUtility || (utility==maxUtility&&card>0&&drawableCards(card).color==Color.multicolored) || maxUtility==0
                        maxUtility = utility;
                        route=0;
                        card=ix;
                    end
                end
                if route==0 && card==0 && destination==0
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

        function getUtilityValues(player, board)
            unclaimedRoutes = board.getUnclaimedRoutes();
            %don't bother calculating utility if no new routes were claimed
            if length(unclaimedRoutes) ~= height(player.routeUtilities)
                player.getRouteUtilities(board, unclaimedRoutes);
                player.getColorUtilities(unclaimedRoutes);
            end
        end

        function getRouteUtilities(player, board, unclaimedRoutes)
            utility = zeros(length(unclaimedRoutes),1);
            id = transpose([unclaimedRoutes.id]);
            player.routeUtilities = table(id, utility);

            destinationGraph = graph(board.routeGraph.Edges(or(board.routeGraph.Edges.Owner==player.color,board.routeGraph.Edges.Owner==Color.gray), :));
            
            ownedEdges=(destinationGraph.Edges.Owner==player.color);
            destinationGraph.Edges.Weight(ownedEdges)=0;

            unfinishedDestinationsIx = find(not(player.destinationsCompleted));    
            for ix=1:length(unclaimedRoutes)
                route = unclaimedRoutes(ix);
                player.routeUtilities.length(ix) = route.length;
                player.routeUtilities.utility(ix) = player.lengthWeight * player.getRouteLengthUtility(route);

                if player.destinationTicketWeight>0
                    destinationUtility=0;
                    for destIx=1:length(unfinishedDestinationsIx)
                        dest = player.destinationCardsHand(unfinishedDestinationsIx(destIx));
                        node1=find(destinationGraph.Nodes.Name==route.locations(1));
                        node2=find(destinationGraph.Nodes.Name==route.locations(2)); 

                        if any(ismember(destinationGraph.Nodes.Name, dest.firstLocation.string)) && ...
                                any(ismember(destinationGraph.Nodes.Name, dest.secondLocation.string))
                            [~,d]=shortestpath(destinationGraph,dest.firstLocation.string,dest.secondLocation.string);
                            destGraphCopy=destinationGraph;
                            e=findedge(destGraphCopy,node1,node2);
                            destGraphCopy.Edges.Weight(e)=0;
                            [~,newd]=shortestpath(destGraphCopy,dest.firstLocation.string,dest.secondLocation.string);
                            util = exp(-newd/d)*dest.pointValue*2;
                            if newd/d >= 1
                                util=0;
                            end
                            destinationUtility = max(destinationUtility, util);
                        end
                    end
                    player.routeUtilities.utility(ix) = player.routeUtilities.utility(ix)+...
                            player.destinationTicketWeight*destinationUtility;
                end
            end

        end

        function getColorUtilities(player, unclaimedRoutes)
            colors = enumeration('Color');
            colors(or(colors == Color.gray, colors == Color.unknown)) = [];
            player.colorUtilities = containers.Map(colors.string,zeros(length(colors),1));
            for colorIx=1:length(colors)
                color = colors(colorIx);
                routesOfColor = unclaimedRoutes(or(color==Color.multicolored, or([unclaimedRoutes.color]==color, [unclaimedRoutes.color]==Color.gray.string)));
                [rows,~] = find([routesOfColor.id]==player.routeUtilities.id);
                
                utility= max(player.routeUtilities.utility(rows)./player.routeUtilities.length(rows)*player.potentialDiscount);
                player.colorUtilities(color.string)=utility;
            end
        end
    end
end