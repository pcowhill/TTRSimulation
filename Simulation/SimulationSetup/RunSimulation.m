function RunSimulation(initFunc, varargin)
    gameObj = initFunc(varargin);
    
    nPlayers = varargin{1};
    nIterations = varargin{2};
    rngSeed = varargin{3};
    nMetrics = 6;

    % Note: "rng controls the global stream, which determines 
    % how rand, randi, randn, and randperm functions produce a 
    % sequence of random numbers" (Mathworks). Since this is 
    % global, this is the only generator we need. It does 
    % not need to be reseeded.
    switch rngSeed
        case "Shuffle"
            rng('shuffle'); % seeds the simulation with the current time
        case "Consistent"
            rng('default');
    end
   
    % Instantiate logger -- "The logger will be "globally available as a
    % singleton instance.  This is because a single instance of Logger must
    % manage the log file being written to.  You can access the logger from multiple 
    % places in your code given its unique name.  (There is no need to pass around the 
    % logger's object handle throughout your code!)"
    LOG_FILE_NAME = 'logfile.txt';
    logger = log4m.getLogger(LOG_FILE_NAME);

    % Run nIterations of the game
    for iter = 1:nIterations
        logger.writePlayerNameTurnNumber("RunSimulation","Game # " + iter + " was started.");
        results(iter,1:nPlayers*nMetrics) = gameObj.simulateGame();
        fclose('all');
        delete(LOG_FILE_NAME);
        assignin('base', "gameObj", gameObj);
    end

    % Analyze the results of all the trials
    ProcessSimulationResults(results, length(gameObj.players));
end
