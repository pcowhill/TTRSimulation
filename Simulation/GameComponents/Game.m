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
        
        function results = simulateGame(game)
            logger = log4m.getLogger("logfile.txt");
            %logger.info("Initializing player's destination cards");

            % Set up the game components
            game.rules.initGameState()
            game.destinationsDeck.init();
            game.board.init();
            startingCards = game.trainsDeck.init(length(game.players)*game.rules.nStartingCards, game.rules.nFaceUpCards, game.rules.nMulticoloredAllowed);
            for playerIx = 1:length(game.players)
               logger.writeTurnAndPlayer("Initializing player destination cards", "Player " + playerIx)
               game.players(playerIx).initPlayer(startingCards(playerIx : length(game.players) : end), game.board, game.destinationsDeck);
            end
            
            logger = log4m.getLogger("logfile.txt");

            gameOver = false;
            playerIx = 1;
            turnCount = 0;
            % Play game until rules say it's over
            while ~gameOver
               turnCount = turnCount + (playerIx==1)
               logger.writeTurnAndPlayer("Turn " + turnCount, "Player " + playerIx)
               game.players(playerIx).takeTurn(game.rules, game.board, game.trainsDeck, game.destinationsDeck);   
               game.rules.updateGameState(game.board, game.players, game.trainsDeck, game.destinationsDeck);
               gameOver = game.rules.isGameOver();
               playerIx = mod(playerIx, length(game.players))+1;
            end

           % Game results, metrics, and visualization - This will be stuff that can be collected at
           % the end of a game
           results = processGameResults(game, playerIx, turnCount);
        end

        function results = processGameResults(game, playerIx, turnCount)
            
            % Calculate Final Scores
            game.rules.updateEndgameScores(game.board, game.players);
            finalScores=[game.players.victoryPoints]

            % Calculate Player Specific Metrics
            lastPlayer = playerIx; 

            for playerIx = 1:length(game.players)
                % number of trains left
                trainsLeft(1,playerIx) = getNumOfTrains(game.board, game.players(playerIx).color);
 
                % number of cards left
                trainCardsLeft(1, playerIx) = length(game.players(playerIx).trainCardsHand);
                destCardsLeft(1,playerIx) = length(game.players(playerIx).destinationCardsHand);
 
                % get routes claimed
                routesClaimed(1,playerIx) = sum(game.board.routeGraph.Edges(:,4).Owner == game.players(playerIx).color);
            
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
             activityLog = game.returnActivityLog();
             activityLog
 
            % return finalScores, trainsLeft, trainCardsLeft, destCardsLeft,
            % playerTurns, and routesClaimed in the game results -- all of 
            % these are arrays of size 1 * nPlayers
            results = [finalScores, trainsLeft, trainCardsLeft, ...
                destCardsLeft, playerTurns, routesClaimed];
 
            % Display figure of the board colored based on the owners of the
            % routes at the end of the game.
            game.returnColoredBoard();
        end

        function p = returnColoredBoard(game)
    
           % Print out the board
           p = plot(game.board.routeGraph, 'EdgeColor', [0.7 0.7 0.7], 'LineStyle', '-'); 
           edgeColorsMatrix(1:size(game.board.routeGraph.Edges,1),1:3) = 0.7;
           for routeIdx = 1:size(game.board.routeGraph.Edges,1) % look at the last column of the route graph to get the color of the route
               
                % If there is more than one route between two cities, make
                % sure you assign the color to just one route (one gray
                % route)
                if sum(and(string(game.board.routeGraph.Edges(:,1).EndNodes(:,1)) == string(game.board.routeGraph.Edges(routeIdx,1).EndNodes(1)),string(game.board.routeGraph.Edges(:,1).EndNodes(:,2)) == string(game.board.routeGraph.Edges(routeIdx,1).EndNodes(2)))) > 1
                    routes = find(and(string(game.board.routeGraph.Edges(:,1).EndNodes(:,1)) == string(game.board.routeGraph.Edges(routeIdx,1).EndNodes(1)),string(game.board.routeGraph.Edges(:,1).EndNodes(:,2)) == string(game.board.routeGraph.Edges(routeIdx,1).EndNodes(2)))); 
                    if edgeColorsMatrix(routes(1),:) == [0.7 0.7 0.7]                        
                        chosenEdgeIx = routes(1);  
                    else
                        % an owner of this route between the two cities
                        % has already been assigned, make sure to
                        % change the color of the OTHER edge between the
                        % two cities
                        chosenEdgeIx = routes(2);
                    end
                else % there's only one edge between these two cities, so just set the cityOrientation to the default order
                        chosenEdgeIx = routeIdx;
                end
                  
               switch game.board.routeGraph.Edges(routeIdx, 4).Owner
                   case Color.purple
                       edgeColorsMatrix(chosenEdgeIx,:) = [1 0 1];
                   case Color.blue
                       edgeColorsMatrix(chosenEdgeIx,:) = [0 0 1];
                   case Color.orange
                       edgeColorsMatrix(chosenEdgeIx,:) = [0.8290 0.4940 0.0250];
                   case Color.white
                       edgeColorsMatrix(chosenEdgeIx,:) = [1 1 1];
                   case Color.green
                       edgeColorsMatrix(chosenEdgeIx,:) = [0 1 0];
                  case Color.yellow
                       edgeColorsMatrix(chosenEdgeIx,:) = [1 1 0];
                  case Color.black
                       edgeColorsMatrix(chosenEdgeIx,:) = [0 0 0];
                   case Color.red
                       edgeColorsMatrix(chosenEdgeIx,:) = [1 0 0];
                   case Color.gray
                       % Do nothing
                       %edgeColorsMatrix(chosenEdgeIx,:) = [0.7 0.7 0.7];
               end
           end
           p.EdgeColor = edgeColorsMatrix;
        end
    end

    methods(Static)
        function f = returnActivityLog()
            % This function returns the file contents that were written in
            % the activity log file during the game.
            f = fileread("logfile.txt");     
        end
    end
end