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
                    (isfield(takenActions, 'wasTrainSacrificed') && takenActions.wasTrainSacrified)
                % The turn is over
                possibleActions.claimableRoutes = Route.empty;
                possibleActions.claimableRouteColors = Color.empty;
                possibleActions.drawableCards = TrainCard.empty;
                possibleActions.canDrawDestinationCards = false;
                possibleActions.canSacrificeTrain = false;
            elseif (~isempty(takenActions.routesClaimed) || ...
                    length(takenActions.cardsDrawn) > 1 || ...
                    takenActions.destinationsDrawn)
                % The only thing the player can do is sacrifice a train
                possibleActions.claimableRoutes = Route.empty;
                possibleActions.claimableRouteColors = Color.empty;
                possibleActions.drawableCards = TrainCard.empty;
                possibleActions.canDrawDestinationCards = false;
                possibleActions.canSacrificeTrain = true;
            else
                if trainsDeck.drawable()
                    possibleActions.drawableCards = [trainsDeck.getFaceUpCards() TrainCard(Color.unknown)];
                end

                if (isfield(takenActions, 'wasTrainSacrificed') && takenActions.wasTrainSacrified)
                    possibleActions.canSacrificeTrain = false;
                else
                    possibleActions.canSacrificeTrain = true;
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
    end
end