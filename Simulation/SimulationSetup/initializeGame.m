function game = initializeGame(args)
%InitializeGame Initialize a Game
    
    nPlayers = args{1};
    playerStrategies = args{3};
    ruleset = args{4};
    finalAxes = args{6};
    board = args{7};
    trainsDeck = args{8};
    destinationsDeck = args{9};

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
            case "Treacherous Player"
                players(ix) = TreacherousPlayer(ix);
            case "Hybrid Player"
                players(ix) = HybridPlayer(ix);
            otherwise
                error("The following player strategy is not defined" + ...
                    "in initializeBasicGame: " + string(playerStrategies{ix}));
        end
    end

    switch string(ruleset)
        case "Default Rules"
            rules = DefaultRules();
        case "Treachery Rules"
            rules = TreacheryRules();
        case "Destination Ticket Bonus Rules"
            rules = DestinationTicketBonusRules();
        case "Less Route Points Rules"
            rules = LessRoutePointsRules();
        case "More Actions Rules"
            rules = MoreActionsRules();
        otherwise
            error("The following ruleset is not defined in " + ...
                 "initializeBasicGame: " + string(ruleset));
    end

    game = Game(board, players, rules, trainsDeck, destinationsDeck);

end

