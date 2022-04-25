classdef Game
    %GAME Can simulate a single game of TTR
    %   Given a board, players, rules, train deck, and destinations deck,
    %   this class can simulate a full game and return the results

    properties(SetAccess=private)
        board Board

        players

        rules

        trainsDeck TrainsDeck

        destinationsDeck DestinationsDeck

        nTimesRouteClaimedByWinner
    end

    methods
        function game = Game(board, players, rules, trainsDeck, destinationsDeck)
            %GAME Initialize properties
            arguments
                board Board
                players Player
                rules Rules
                trainsDeck TrainsDeck
                destinationsDeck DestinationsDeck
            end
            game.board = board;
            game.players = players;
            game.rules = rules;
            game.trainsDeck = trainsDeck;
            game.destinationsDeck = destinationsDeck;
            game.nTimesRouteClaimedByWinner = zeros(1,length(game.board.initialRoutes));
        end

        function results = simulateGame(game, logger, randStream)
            % Set up the game components
            game.rules.initGameState()
            game.destinationsDeck.init(randStream);
            game.board.init();
            startingCards = game.trainsDeck.init(length(game.players)*game.rules.nStartingCards, game.rules.nFaceUpCards, game.rules.nMulticoloredAllowed, randStream);
            for playerIx = 1:length(game.players)
               logger.writeTurnAndPlayer("Initializing player destination cards", "Player " + playerIx)
               game.players(playerIx).initPlayer(startingCards(playerIx : length(game.players) : end), game.board, game.destinationsDeck, game.rules.startingTrains, game.players, logger);
            end

            gameOver = false;
            playerIx = 1;
            turnCount = 0;
            numTurnsAhead = zeros(1,length(game.players));
            numTurnsAheadLong = zeros(1,length(game.players));

            % Play game until rules say it's over
            while ~gameOver
               turnCount = turnCount + (playerIx==1);
               logger.writeTurnAndPlayer("Turn " + turnCount, "Player " + playerIx);
               game.players(playerIx).takeTurn(game.rules, game.board, game.trainsDeck, game.destinationsDeck, logger, randStream);
               game.rules.updateGameState(game.board, game.players, game.trainsDeck, game.destinationsDeck);
               gameOver = game.rules.isGameOver();
               playerIx = mod(playerIx, length(game.players))+1;

                % Balance Measure -- Result Known Long Ahead of Time? -- Track who is winning during each turn
                % in the game - measure of balance  -- added to the Game.m class
               if playerIx == 1 % Once all players have taken turns, see who has the most points for that turnCount
                    % Check current scores, not including the longest route
                    maxVictoryPts = max([game.players.victoryPoints]);
                    idx = find(maxVictoryPts == [game.players.victoryPoints]);
                    numTurnsAhead(idx) = numTurnsAhead(idx) + 1;

                    % Check current scores, factoring in longest route
                    longRoutePts = max([game.rules.getLongestRoute(game.board, game.players)]);
                    longRouteIdx = find(longRoutePts == [game.rules.getLongestRoute(game.board, game.players)]);
                    scoreWithLongestRoute = [game.players.victoryPoints] + (ismember(1:length(game.players),longRouteIdx))*[game.rules.longestRoutePoints];
                    maximum = max(scoreWithLongestRoute);
                    maxIdx = find(maximum==scoreWithLongestRoute);
                    numTurnsAheadLong(1,maxIdx) = numTurnsAheadLong(1,maxIdx) + 1;
               end
            end

            numTurnsAhead
            numTurnsAheadLong

            % Calculate Final Scores
            game.rules.updateEndgameScores(game.board, game.players);
            finalScores=[game.players.victoryPoints];

            % Game results, metrics, and visualization - This will be stuff that can be collected at
            % the end of a game
            results = processGameResults(game, playerIx, turnCount, finalScores, logger, numTurnsAhead, numTurnsAheadLong);
        end

        function results = processGameResults(game, playerIx, turnCount, finalScores, logger, numTurnsAhead, numTurnsAheadLong)

            % Calculate Player Specific Metrics
            lastPlayer = playerIx;

            for playerIx = 1:length(game.players)
                % number of trains played
                trainsPlayed(1,playerIx) = getNumOfTrains(game.board, game.players(playerIx).color);

                % number of cards left
                trainCardsLeft(1, playerIx) = length(game.players(playerIx).trainCardsHand);

                % number of destination ticket cards completed
                destCardsCompleted(1,playerIx) = sum(game.rules.getTicketsCompleted(game.board, game.players(playerIx)) == true);

                % get routes claimed, average route length, and longest
                % route
                ownsRoute = (game.board.routeGraph.Edges(:,4).Owner == game.players(playerIx).color);
                routesClaimed(1,playerIx) = sum(ownsRoute);

                idxOfRoutesOwned = find(ownsRoute == 1);
                avgRouteLength(1,playerIx) = mean(game.board.routeGraph.Edges.Length(idxOfRoutesOwned));
                longestRoute(1,playerIx) = game.rules.getLongestRoute(game.board, game.players(playerIx));
 
                % get turns per player
                if (playerIx < lastPlayer)
                    playerTurns(playerIx) = turnCount;
                else % turns are counted based on when the first player
                    % starts a new round, any players with an index greater
                    % or equal to the player whose turn WOULD HAVE been
                    % next, took one less turn than players with a lower
                    % index (e.g., if player 3 would have gone next, then
                    % both 3 and 4 would have played one less turn than
                    % players 1 and 2)
                    playerTurns(playerIx) = turnCount - 1;
                end
            end

             % Print player activity log
             activityLog = game.returnActivityLog(logger);
             activityLog

            % return finalScores, trainsPlayed, trainCardsLeft,
            % destCardsCompleted, playerTurns, routesClaimed, avgRouteLength,
            %and longestRoute in the game results -- all of these are arrays
            % of size 1 * nPlayers
             gameResults = [finalScores, trainsPlayed, trainCardsLeft, ...
                 destCardsCompleted, playerTurns, routesClaimed, ...
                 avgRouteLength, longestRoute, numTurnsAhead, numTurnsAheadLong];
            results.summary = gameResults;

            % Increment number of times each route claimed by winner(s)
            winningScore = max(finalScores);
            winnerIdx = [find(winningScore == finalScores)];
            winnerColor = [game.players(winnerIdx).color]

            % in the rare case there is more than one winner, loop over the winner
            % colors array
            routeOwners = game.board.routeGraph.Edges.Owner;
            for i = 1:length(winnerColor)
               idx=find(routeOwners==winnerColor(i));
               game.nTimesRouteClaimedByWinner(1, idx) = game.nTimesRouteClaimedByWinner(1, idx) + 1;
            end

            % Keep track of top winning routes -- how powerful is a given
            % action or combination of actions?
            winningRoutesTbl = [{game.board.routeGraph.Edges.EndNodes}, {num2cell(game.nTimesRouteClaimedByWinner')}];
            [winningRoutesTbl{1}, winningRoutesTbl{2}]

            results.winningRoutesTbl = winningRoutesTbl;
        end

    end

    methods(Static)
        function f = returnActivityLog(logger)
            % This function returns the file contents that were written in
            % the activity log file during the game.
            f = fileread(logger.fullpath);
        end
    end
end
