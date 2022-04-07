function game = initializeBasicGame(args)
%INITIALIZEBASICGAME Initialize a basic Game
    
    nPlayers = args{1};

    BaseBoard.initializeBoard;
    BaseBoard.InitializeTrainCardDeck;
    BaseBoard.InitializeDestinationTicketCards;

    players=Player.empty;
    players(1) = DestinationTicketPlayer(1);
    players(2) = LongRoutePlayer(2);
%     players(3) = DeviantPlayer(3);
%     for ix=2:nPlayers
%         players(ix) = DestinationTicketPlayer(ix);
% %         players(ix) = DummyPlayer(ix);
%     end

    game = Game(BOARD, players, DefaultRules(), TRAINS_DECK, DESTINATIONS_DECK);


end

