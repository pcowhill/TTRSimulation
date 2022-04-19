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
        end
        
        function results = simulateGame(game, logger)
            % Set up the game components
            game.rules.initGameState()
            game.destinationsDeck.init();
            game.board.init();
            startingCards = game.trainsDeck.init(length(game.players)*game.rules.nStartingCards, game.rules.nFaceUpCards, game.rules.nMulticoloredAllowed);
            for playerIx = 1:length(game.players)
               logger.writeTurnAndPlayer("Initializing player destination cards", "Player " + playerIx)
               game.players(playerIx).initPlayer(startingCards(playerIx : length(game.players) : end), game.board, game.destinationsDeck, game.rules.startingTrains, game.players, logger);
            end
            
            gameOver = false;
            playerIx = 1;
            turnCount = 0;
            % Play game until rules say it's over
            while ~gameOver
               turnCount = turnCount + (playerIx==1);
               logger.writeTurnAndPlayer("Turn " + turnCount, "Player " + playerIx);
               game.players(playerIx).takeTurn(game.rules, game.board, game.trainsDeck, game.destinationsDeck, logger);   
               game.rules.updateGameState(game.board, game.players, game.trainsDeck, game.destinationsDeck);
               gameOver = game.rules.isGameOver();
               playerIx = mod(playerIx, length(game.players))+1;
            end
            
            % Calculate Final Scores

            game.rules.updateEndgameScores(game.board, game.players);
            finalScores=[game.players.victoryPoints];

            % Game results, metrics, and visualization - This will be stuff that can be collected at
            % the end of a game
            results = processGameResults(game, playerIx, turnCount, finalScores, logger);
        end

        function results = processGameResults(game, playerIx, turnCount, finalScores, logger)

            % Calculate Player Specific Metrics
            lastPlayer = playerIx; 

            for playerIx = 1:length(game.players)
                % number of trains played
                trainsPlayed(1,playerIx) = getNumOfTrains(game.board, game.players(playerIx).color);
 
                % number of cards left
                trainCardsLeft(1, playerIx) = length(game.players(playerIx).trainCardsHand);
                
                % number of destination ticket cards completed
                destCardsCompleted(1,playerIx) = sum(game.rules.getTicketsCompleted(game.board, game.players(playerIx)) == true);
 
                % get routes claimed
                routes = game.board.routeGraph.Edges(:,4).Owner == game.players(playerIx).color;
                routesClaimed(1,playerIx) = sum(routes);
                avgRouteLength(1,playerIx) = mean(game.board.routeGraph.Edges.Length(routes));

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
 
            % return finalScores, trainsPlayed, trainCardsLeft, destCardsCompleted,
            % playerTurns, and routesClaimed in the game results -- all of 
            % these are arrays of size 1 * nPlayers
            results = [finalScores, trainsPlayed, trainCardsLeft, ...
                destCardsCompleted, playerTurns, routesClaimed, avgRouteLength, longestRoute];
 
            % Display figure of the board colored based on the owners of the
            % routes at the end of the game.
            game.returnColoredBoard();
        end

        function p = returnColoredBoard(game)

            edgeOwners=game.board.routeGraph.Edges.Owner;
            edgeColors = repmat([0 0 0], length(edgeOwners), 1);    
            tmp=find(edgeOwners=='red');
            edgeColors(tmp, :)=repmat([1 0 0], length(tmp),1);
            tmp=find(edgeOwners=='yellow');
            edgeColors(tmp, :)=repmat([1 1 0], length(tmp),1);
            tmp=find(edgeOwners=='green');
            edgeColors(tmp, :)=repmat([0 1 0], length(tmp),1);
            tmp=find(edgeOwners=='blue');
            edgeColors(tmp, :)=repmat([0 0 1], length(tmp),1);
            tmp=find(edgeOwners=="unknown");
            edgeColors(tmp, :)=repmat([0.5, 0.5, 0.5], length(tmp), 1);

            p = plot(game.board.routeGraph, 'EdgeColor', edgeColors, 'Parent', game.axesForFinalBoard);
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
