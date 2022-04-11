classdef TreacheryRules < Rules
    %TREACHERYRULES Add some additional actions players may take to more
    % directly harm or stunt the progress of other players.
    
    properties (SetAccess = private)
        turnsRemaining = -1; % -1 means the end has not been triggered
    end
    
    methods
        function initGameState(rules)
            rules.turnsRemaining = -1;
        end

        function possibleActions = ...
                getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, takenActions)
            arguments
                rules Rules
                player Player 
                board Board
                trainsDeck TrainsDeck
                destinationsDeck DestinationsDeck
                takenActions struct
            end

            possibleActions = struct();

            if (~isempty(takenActions.routesClaimed) || ...
                    length(takenActions.cardsDrawn) > 1 || ...
                    takenActions.destinationsDrawn) && ...
                    (isfield(takenActions, 'wasTrainSacrificed') && takenActions.wasTrainSacrificed)
                % The turn is over
                possibleActions.claimableRoutes = Route.empty;
                possibleActions.claimableRouteColors = Color.empty;
                possibleActions.drawableCards = TrainCard.empty;
                possibleActions.canDrawDestinationCards = false;
                possibleActions.canSacrificeTrain = false;
            elseif (~isempty(takenActions.routesClaimed) || ...
                    length(takenActions.cardsDrawn) > 1 || ...
                    takenActions.destinationsDrawn)
                % The only thing the player can do is sacrifice a train if
                % they have one
                possibleActions.claimableRoutes = Route.empty;
                possibleActions.claimableRouteColors = Color.empty;
                possibleActions.drawableCards = TrainCard.empty;
                possibleActions.canDrawDestinationCards = false;
                possibleActions.canSacrificeTrain = board.getNumOfTrains(player.color) > 0;
            else
                if trainsDeck.drawable()
                    possibleActions.drawableCards = [trainsDeck.getFaceUpCards() TrainCard(Color.unknown)];
                end

                if (isfield(takenActions, 'wasTrainSacrificed') && takenActions.wasTrainSacrificed)
                    possibleActions.canSacrificeTrain = false;
                else
                    possibleActions.canSacrificeTrain = board.getNumOfTrains(player.color) > 0;
                end

                if ~isempty(takenActions.cardsDrawn)
                    %Don't allow the player to draw a locomotive as their
                    %second card
                    indicesToRemove = [];
                    for cardIndex = 1:length(possibleActions.drawableCards)
                        if possibleActions.drawableCards(cardIndex).color == Color.multicolored
                            indicesToRemove = [indicesToRemove cardIndex];
                        end
                    end
                    possibleActions.drawableCards(indicesToRemove) = [];

                    % Can only draw a card as second action
                    possibleActions.claimableRoutes = Route.empty;
                    possibleActions.claimableRouteColors = Color.empty;
                    possibleActions.canDrawDestinationCards = false;
                else
                    possibleActions.canDrawDestinationCards=false;
                    if destinationsDeck.getNumCardsLeft() > 0
                        possibleActions.canDrawDestinationCards = true;                
                    end
                    [possibleActions.claimableRoutes, possibleActions.claimableRouteColors] = rules.getClaimableRoutes(player, board);
                    [possibleActions.stealableRoutes, possibleActions.stealableRouteColors] = rules.getStealableRoutes(player, board);
                end
            end
        end

        function over =  isTurnOver(rules, possibleActions, takenActions)
            % if the player claimed a route, drew a multiclor card, or drew
            % destination cards, their turn is over
            over = (~isempty(takenActions.routesClaimed) || ...
                (~isempty(takenActions.cardsDrawn) && (takenActions.cardsDrawn(end).color == Color.multicolored)) || ...
                takenActions.destinationsDrawn) && ...
                (isfield(takenActions, 'wasTrainSacrificed') && takenActions.wasTrainSacrificed);
        end

        function points = getRoutePoints(rules, route)
            %getRoutePoints Return the number of victory points the given
            %route is worth
            if route.length == 1
                points = 1;
            elseif route.length == 2
                points = 2;
            elseif route.length == 3
                points = 4;
            elseif route.length == 4
                points = 7;
            elseif route.length == 5
                points = 10;
            else
                points = 15;
            end
        end

        function updateGameState(rules, board, players, trainsDeck, destinationsDeck)
            playerTrains=Rules.getPlayerTrains(board, players, rules.startingTrains);
            for p = 1:length(players)
                if  playerTrains(p) <= 2
                    % if a player has two or less trains remaining,
                    % everyone gets one more turn before the game is over
                    if rules.turnsRemaining == -1
                        % -1 means the ending hasn't been triggered already
                        rules.turnsRemaining = length(players);
                    else
                        rules.turnsRemaining = rules.turnsRemaining - 1;
                    end
                    break;
                end
            end
        end

        function over = isGameOver(rules)
            % turnsRemaining==0 only when the end condition is triggered
            % and everyone has taken their final turn
            over = rules.turnsRemaining == 0;
        end

        function updateEndgameScores(rules, board, players)
            % apply destination ticket and longest route victory points
           longestRouteLengths = Rules.getLongestRoute(board, players)

            for playerIx=1:length(players)
                destinationTickets = players(playerIx).destinationCardsHand;
                ticketsCompleted = Rules.getTicketsCompleted(board,players(playerIx));
                for destIx=1:length(destinationTickets)
                    if ticketsCompleted(destIx)
                        % add points if ticket was completed
                        players(playerIx).addToVictoryPoints(destinationTickets(destIx).pointValue);
                    else
                        % subtract points if ticket was not completed
                        players(playerIx).addToVictoryPoints(-destinationTickets(destIx).pointValue);
                    end
                end
            end

            % longest route receives points, all receive points in case of
            % tie
            longestRouteWinners = find(longestRouteLengths == max(longestRouteLengths));
            for playerIx=1:length(longestRouteWinners)
                players(longestRouteWinners(playerIx)).addToVictoryPoints(rules.longestRoutePoints);
            end
        end

        function [claimableRoutes, claimableRouteColors] = getStealableRoutes(rules, player, board)
            claimableRoutes = Route.empty;
            claimableRouteColors = Color.empty;
            if ~isempty(player.trainCardsHand)
                claimedRoutes = board.getClaimedRoutes();
                for iRoute = length(claimedRoutes):-1:1
                    if board.owner(claimedRoutes(iRoute)) == player.color
                        claimedRoutes(iRoute) = [];
                    end
                end

                % get how many cards of each color the player has
                colors = enumeration('Color');
                colors(or(colors == Color.gray, colors == Color.unknown)) = [];
                multicoloredIx = find(colors==Color.multicolored);
                colorCounts = zeros(length(colors),1);
                for ix=1:length(colorCounts)
                    colorCounts(ix) = sum(colors(ix) == [player.trainCardsHand.color]);
                end

                nTrainsLeft = rules.startingTrains - board.getNumOfTrains(player.color);
                
                for ix=1:length(claimedRoutes)
                    route = claimedRoutes(ix);
                    cardsToSteal = TreacheryRules.numCardsToSteal(route);
                    if route.length <= nTrainsLeft
                        if route.color == Color.gray
                            %if it's a gray route, find which colors the
                            %player has enoug cards of to claim the route
                            %including locomotives. Make sure not to count
                            %locomotives twice                        
                            useableColors = colors(and(colorCounts>0,cardsToSteal <= colorCounts+((colors~=Color.multicolored)*colorCounts(multicoloredIx))));
                            for c=1:length(useableColors)
                                claimableRoutes(end+1) = route;
                                claimableRouteColors(end+1) = useableColors(c);
                            end
                        else
                            % if it's a colored route, check if the player
                            % has enough cards to claim it including
                            % locomotives
                            if colorCounts(colors==route.color)>0 && cardsToSteal <= colorCounts(colors==route.color)+((route.color~=Color.multicolored)*colorCounts(multicoloredIx))
                                claimableRoutes(end+1) = route;
                                claimableRouteColors(end+1) = route.color;
                            end
                            if colorCounts(multicoloredIx)>=cardsToSteal
                                claimableRoutes(end+1)=route;
                                claimableRouteColors(end+1)=Color.multicolored;
                            end
                        end
                    end
                end
            end        
        end
    end

    methods(Static)
        function numCards = numCardsToSteal(route)
            % numCardsToSteal method
            % Returns the number of cards needed to steal a claimed route
            % from another player.
            arguments
                route Route
            end
            numCards = route.length * 2;
        end
    end
end