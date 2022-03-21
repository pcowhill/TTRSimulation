classdef Rules < handle
    %Rules Base rules class
    %   Abstract class that provides an interface to be implemented by subclasses

    properties (SetAccess=protected)
        startingTrains = 45 %number of trains each player starts with

        nStartingCards = 4 %number of cards each player starts with

        nFaceUpCards = 5 %Number of face up cards on table

        nMulticoloredAllowed = 2 %Number of locomotives allowed in the face up pile

        longestRoutePoints = 10
    end

    methods (Abstract=true)
        initGameState(rules);
        [claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards] = ...
                getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, routesClaimed, cardsDrawn, drawnDestinations);
            %getPossibleActions Get all possible actions for this player
            %   Returns list of claimable routes, drawable cards, and
            %   whether or not the player can draw destination cards
            %   
            %   Inputs
            %
            % routesClaimed - routes claimed so far for this player's turn
            % cardsDrawn - cards drawn so far this turn
            % drawnDestinations - whether the player has drawn destination
            % cards

        over =  isTurnOver(rules, claimableRoutes, drawableCards, drawDestinationCards, route, card, destinations);
            %isTurnOver Returns true if the player's last action has caused
            %   their turn to be over.
            %
            %   Input Parameters
            %
            %   claimableRoutes - routes that were available to be claimed
            %   for the last action
            %
            %   drawableCards - train cards that were available to be drawn
            %   for the last action
            %
            %   drawDestinationCards - true if it was possible to draw
            %   destination cards for the last action
            %
            %   route - index of the route the player claimed last action;
            %   0 if no route was claimed
            %   
            %   card - index of the card the player drew last action; 0 if
            %   no card was drawn
            %
            %   destinations - true if the player drew destination cards
            %   last turn

        points = getRoutePoints(rules, route);
        %getRoutePoints Returns the number of victory points claiming the
        %given route is worth

        updateGameState(rules, board, players, trainsDeck, destinationsDeck);
        %updateGameState Updates the internal state of the rules object for
        %determining the end of the game

        over = isGameOver(rules)
        %over Returns true if the game is over

        updateEndgameScores(rules, board, players)
        %updateEndgameScores Add scores for destination tickets and longest
        %route
    end

    methods (Access = protected)
        %getClaimableRoutes
        %   Returns a list of routes that are claimable given the player's
        %   current hand
        function [claimableRoutes, claimableRouteColors] = getClaimableRoutes(rules, player, board)
            claimableRoutes = Route.empty;
            claimableRouteColors = Color.empty;
            if ~isempty(player.trainCardsHand)
                unclaimedRoutes = board.getUnclaimedRoutes();

                % get how many cards of each color the player has
                colors = enumeration('Color');
                colors(or(colors == Color.gray, colors == Color.unknown)) = [];
                multicoloredIx = find(colors==Color.multicolored);
                colorCounts = zeros(length(colors),1);
                for ix=1:length(colorCounts)
                    colorCounts(ix) = sum(colors(ix) == [player.trainCardsHand.color]);
                end

                nTrainsLeft = rules.startingTrains - board.getNumOfTrains(player.color);

                % Commented out a different implementation which was slower
%                 for ix=1:length(colorCounts)
%                     colorRoutes = unclaimedRoutes(and(and([unclaimedRoutes.length]<=colorCounts(ix)+colorCounts(multicoloredIx),...
%                         [unclaimedRoutes.length]<=nTrainsLeft),...
%                         or([unclaimedRoutes.color]==colors(ix),[unclaimedRoutes.color]==Color.gray)));
%                     claimableRoutes = [claimableRoutes colorRoutes];
%                     claimableRouteColors = [claimableRouteColors repmat(colors(ix),1,length(colorRoutes))];
%                 end
                
                for ix=1:length(unclaimedRoutes)
                    route = unclaimedRoutes(ix);
                    if route.length <= nTrainsLeft
                        if route.color == Color.gray
                            %if it's a gray route, find which colors the
                            %player has enoug cards of to claim the route
                            %including locomotives. Make sure not to count
                            %locomotives twice                        
                            useableColors = colors(and(colorCounts>0,route.length <= colorCounts+((colors~=Color.multicolored)*colorCounts(multicoloredIx))));
                            for c=1:length(useableColors)
                                claimableRoutes(end+1) = route;
                                claimableRouteColors(end+1) = useableColors(c);
                            end
                        else
                            % if it's a colored route, check if the player
                            % has enough cards to claim it including
                            % locomotives
                            if colorCounts(colors==route.color)>0 && route.length <= colorCounts(colors==route.color)+((route.color~=Color.multicolored)*colorCounts(multicoloredIx))
                                claimableRoutes(end+1) = route;
                                claimableRouteColors(end+1) = route.color;
                            end
                        end
                    end
                end
            end        
        end

        function [ticketsCompleted, longestRouteLengths] = getTicketsCompletedAndLongestRoute(rules, board, players)
            %getTicketsCompletedAndLongestRoute
            longestRouteLengths = [];
            ticketsCompleted = {};
            for playerIx = 1:length(players)
                % make graph of only player owned edges
                playerGraph = graph(board.routeGraph.Edges(board.routeGraph.Edges.Owner==players(playerIx).color, :));
                destinationTickets = players(playerIx).destinationCardsHand;
                ticketsCompleted{playerIx} = false(1,length(destinationTickets));
                for destIx = 1:length(destinationTickets)
                    % first we check if the nodes of the ticket are present
                    % in the player's graph
                    if any(contains(playerGraph.Nodes.Name, destinationTickets(destIx).firstLocation.string())) && ...
                            any(contains(playerGraph.Nodes.Name, destinationTickets(destIx).secondLocation.string()))
                        % find paths betweent the nodes in the player's
                        % graph
                        paths = allpaths(playerGraph, destinationTickets(destIx).firstLocation.string(), ...
                           destinationTickets(destIx).secondLocation.string());
                        if ~isempty(paths)
                            %at least 1 path exists, ticket is complte
                            ticketsCompleted{playerIx}(destIx) = true;
                        end
                    end
                end
                
                % Separate graph into connected components to find longest
                % path. We simply iterate through every possible path in
                % each connected graph to find the longest one
                bins = conncomp(playerGraph);
                longestRouteLengths(playerIx) = 0;
                for binIx=1:max(bins)
                    connectedGraph = subgraph(playerGraph, playerGraph.Nodes.Name(bins==binIx));
                    nNodes = height(connectedGraph.Nodes);

                    % get all pairings of nodes in the connected graph
                    nodeCombos = nchoosek(1:nNodes, 2);
                    nodeCombos = [repmat(transpose(1:nNodes),1,2); nodeCombos];

                    for comboIx=1:length(nodeCombos)
                        % get all paths between the nodes
                        [paths, edgepaths] = allpaths(connectedGraph, connectedGraph.Nodes.Name(nodeCombos(comboIx,1)), connectedGraph.Nodes.Name(nodeCombos(comboIx,2)));
                        for pathIx=1:length(paths)
                            edges = edgepaths{pathIx};
                            % if no edges are repeated, this could be a
                            % longest route
                            if length(unique(edges)) ==  length(edges)
                                longestRouteLengths(playerIx) = max(longestRouteLengths(playerIx),...
                                    sum(connectedGraph.Edges.Length(edges)));
                            end
                        end
                    end       
                end
            end
        end
    end
end