function game = initializeBasicGame(args)
%INITIALIZEBASICGAME Initialize a basic Game
    
    nPlayers = args{1};
    % Second argument is number of iterations, implementation is in another
    % branch at the time of writting.
    playerStrategies = args{3};
    ruleset = args{4};
    randomSeedSelection = args{5};

    if string(randomSeedSelection) == "Shuffle"
        rng('shuffle');
    elseif string(randomSeedSelection) == "Consistent"
        rng('default');
    end

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

