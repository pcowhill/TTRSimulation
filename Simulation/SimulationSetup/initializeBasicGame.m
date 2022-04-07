function game = initializeBasicGame(args)
%INITIALIZEBASICGAME Initialize a basic Game
    
    nPlayers = args{1};
    playerStrategies = args{3};
    ruleset = args{4};

    BaseBoard.initializeBoard;
    BaseBoard.InitializeTrainCardDeck;
    BaseBoard.InitializeDestinationTicketCards;

    players=Player.empty;
    players(1) = LongRoutePlayer(1);
    for ix=2:nPlayers
        players(ix) = DestinationTicketPlayer(ix);
%         players(ix) = DummyPlayer(ix);

    end

    if string(ruleset) == "Default Rules"
        rules = DefaultRules();
    else
        error("The following ruleset is not defined in " + ...
              "initializeBasicGame: " + string(ruleset));
    end

    game = Game(BOARD, players, rules, TRAINS_DECK, DESTINATIONS_DECK);


end

