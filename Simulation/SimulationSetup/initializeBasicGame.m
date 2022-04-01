function game = initializeBasicGame(args)
%INITIALIZEBASICGAME Initialize a basic Game
    
    nPlayers = args{1};
    playerStrategies = args{3};
    ruleset = args{4};

    BaseBoard.initializeBoard;
    BaseBoard.InitializeTrainCardDeck;
    BaseBoard.InitializeDestinationTicketCards;

    players = DummyPlayer.empty;
    for ix=1:nPlayers
        if string(playerStrategies{ix}) == "Dummy Player"
            players(ix) = DummyPlayer(ix);
        else
            error("The following player strategy is not defined in " + ...
                  "initializeBasicGame: " + string(playerStrategies{ix}));
        end
    end

    if string(ruleset) == "Default Rules"
        rules = DefaultRules();
    else
        error("The following ruleset is not defined in " + ...
              "initializeBasicGame: " + string(ruleset));
    end

    game = Game(BOARD, players, rules, TRAINS_DECK, DESTINATIONS_DECK);


end

