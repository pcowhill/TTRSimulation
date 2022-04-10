function RunSimulation(initFunc, varargin)
    gameObj = initFunc(varargin);
    
    nPlayers = varargin{1};
    nIterations = varargin{2};
    rngSeed = varargin{5};
    finalAxes = varargin{6};
    nMetrics = 6;
    nWorkers = varargin{7};

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
   
    results=zeros(nIterations,nPlayers*nMetrics);

    finalGameObj=Game.empty;
    % Run nIterations of the game
    parfor (iter = 1:nIterations, nWorkers)
        % Instantiate logger -- "The logger will be "globally available as a
        % singleton instance.  This is because a single instance of Logger must
        % manage the log file being written to.  You can access the logger from multiple 
        % places in your code given its unique name.  (There is no need to pass around the 
        % logger's object handle throughout your code!)"
        LOG_FILE_NAME= strcat("logfile",num2str(iter),".txt");
        if isfile(LOG_FILE_NAME)
            delete(LOG_FILE_NAME);
        end
        logger = log4m.getLogger(LOG_FILE_NAME);
        logger.writeGameNumber("RunSimulation","Game # " + iter + " was started.");
        results(iter,:) = gameObj.simulateGame(logger);
        fclose('all');
        if isfile(LOG_FILE_NAME)
            delete(LOG_FILE_NAME);
        end
        
        if iter==nIterations
            assignin('base', 'gameObj', gameObj);
            evalin('base', "save('gameObj')")            
        end
    end

    %For some reason sometimes log files won't actually get deleted in the
    %parfor loop
    for iter=1:nIterations
        LOG_FILE_NAME= strcat("logfile",num2str(iter),".txt");
        if isfile(LOG_FILE_NAME)
            delete(LOG_FILE_NAME);
        end
    end

    % Display figure of the board colored based on the owners of the
    % routes at the end of the game.
    load("gameObj.mat");
    edgeOwners=gameObj.board.routeGraph.Edges.Owner;
    edgeColors = repmat([0 0 0], length(edgeOwners), 1);    
    tmp=find(edgeOwners=='red');
    edgeColors(tmp, :)=repmat([1 0 0], length(tmp),1);
    tmp=find(edgeOwners=='yellow');
    edgeColors(tmp, :)=repmat([1 1 0], length(tmp),1);
    tmp=find(edgeOwners=='green');
    edgeColors(tmp, :)=repmat([0 1 0], length(tmp),1);
    tmp=find(edgeOwners=='blue');
    edgeColors(tmp, :)=repmat([0 0 1], length(tmp),1);
    plot(gameObj.board.routeGraph, 'EdgeColor', edgeColors, 'Parent', finalAxes.Board);
    assignin('base', 'gameObj', gameObj);
    delete('gameObj.mat');   

    % Analyze the results of all the trials
    ProcessSimulationResults(results, nPlayers, finalAxes);
end