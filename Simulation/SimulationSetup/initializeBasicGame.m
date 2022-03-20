function game = initializeBasicGame(args)
%INITIALIZEBASICGAME Initialize a basic Game
    
    nPlayers = args{1};

    BaseBoard.initializeBoard;
    BaseBoard.InitializeTrainCardDeck;
    BaseBoard.InitializeDestinationTicketCards;

    players = DummyPlayer.empty;
    for ix=1:nPlayers
        players(ix) = DummyPlayer(ix);
    end

    game = Game(BOARD, players, DefaultRules(), TRAINS_DECK, DESTINATIONS_DECK);


end

