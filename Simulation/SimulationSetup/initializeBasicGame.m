function game = initializeBasicGame(args)
%INITIALIZEBASICGAME Initialize a basic Game
    
    nPlayers = args{1};
    playerStrategies = args{3};
    ruleset = args{4};
    finalAxes = args{6};

    BaseBoard.initializeBoard;
    BaseBoard.InitializeTrainCardDeck;
    BaseBoard.InitializeDestinationTicketCards;

    players=Player.empty;
    for ix=1:nPlayers
        switch playerStrategies{ix}
            case "Dummy Player"
                players(ix) = DummyPlayer(ix);
            case "Long Route Player"
                players(ix) = LongRoutePlayer(ix);
            case "Destination Ticket Player"
                players(ix) = DestinationTicketPlayer(ix);
            case "Deviant Player"
                players(ix) = DeviantPlayer(ix);
            otherwise
                error("The following player strategy is not defined" + ...
                    "in initializeBasicGame: " + string(playerStrategies{ix}));
        end
    end

    switch string(ruleset)
        case "Default Rules"
            rules = DefaultRules();
        otherwise
            error("The following ruleset is not defined in " + ...
                 "initializeBasicGame: " + string(ruleset));
    end

    game = Game(BOARD, players, rules, TRAINS_DECK, DESTINATIONS_DECK);

end

