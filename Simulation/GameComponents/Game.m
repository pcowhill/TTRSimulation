classdef Game
    %GAME Can simulate a single game of TTR
    %   Given a board, players, rules, train deck, and destinations deck,
    %   this class can simulate a full game and return the results
    
    properties(SetAccess=private)
        board Board

        players Player

        rules Rules

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
           startingCards = game.trainsDeck.init(length(game.players)*game.rules.startingCards);
           for playerIndex = 1:length(game.players)
               game.players(playerIndex).initPlayer(startingCards(playerIndex : length(game.players) : end));
           end

           gameOver = false;
           playerIndex = 1;
           % Play game until rules say it's over
           while ~gameOver
               game.players(playerIndex).takeTurn(game.rules, game.board, game.trainsDeck, game.destinationsDeck);   
               game.rules.udpateGameState(game.board, game.players, game.trainsDeck, game.destinationsDeck);
               gameOver = game.rules.isGameOver();
               playerIndex = playerIndex + 1;
           end

           % apply destination ticket and longest route victory points

           % metrics stuff?
            
        end
    end
end

