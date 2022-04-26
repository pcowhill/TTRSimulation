function game = initializeBasicGame(args)
%INITIALIZEBASICGAME Initialize a basic Game
    
    BaseBoard.initializeBoard;
    BaseBoard.InitializeTrainCardDeck;
    BaseBoard.InitializeDestinationTicketCards;
    args{7} = BOARD;
    args{8} = TRAINS_DECK;
    args{9} = DESTINATIONS_DECK;

    game = initializeGame(args);

end

