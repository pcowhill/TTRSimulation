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
            % Set up the game components
            game.rules.initGameState()
            game.destinationsDeck.init();
            game.board.init();
            startingCards = game.trainsDeck.init(length(game.players)*game.rules.nStartingCards, game.rules.nFaceUpCards, game.rules.nMulticoloredAllowed);
            for playerIx = 1:length(game.players)
               game.players(playerIx).initPlayer(startingCards(playerIx : length(game.players) : end), game.board, game.destinationsDeck, game.rules.startingTrains, game.players);
            end
            
            gameOver = false;
            playerIx = 1;
            turnCount = 0;
            % Play game until rules say it's over
            while ~gameOver
               turnCount = turnCount + (playerIx==1)
               if turnCount > 100
                   help
               end
               game.players(playerIx).takeTurn(game.rules, game.board, game.trainsDeck, game.destinationsDeck);   
               game.rules.updateGameState(game.board, game.players, game.trainsDeck, game.destinationsDeck);
               gameOver = game.rules.isGameOver();
               playerIx = mod(playerIx, length(game.players))+1;
            end
            
            game.rules.updateEndgameScores(game.board, game.players);
            finalScores=[game.players.victoryPoints]

           % metrics stuff?
            
        end
    end
end

