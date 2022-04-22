function CompareResults(varargin)
    % This function reads in .MAT files generated from the simulation. 
    % It combines the results tables of each simulation to run to allow 
    % for easier side-by-side comparison.

    % Check that all arguments passed into the function are 
    % .MAT file character arrays (using '' instead of "") that are 
    % variables in the workspace

    % Sample Call (compares two results structs):
    %    CompareResults('738628.0539Consistent2DummyDummyDestinationTicketLongRoute6DefaultRules.mat', '738628.0432Shuffle1DummyDummy6DefaultRules.mat')

    % NOTE: From the command line, you can also pass an entire 
    % directory to the CompareResults function instead of entering 
    % file names individually.
    % ENTER: 
    %    fileDir = dir('*.mat');
    %    CompareResults(fileDir(:).name);
    
    runFileChecks(varargin{:});

    for i = 1:nargin
        % Load each file
        compareStruct.fileID(i) = i;
        compareStruct.file(i) = load(varargin{i}); 
    end

    % Consolidate settings for all files being compared into 1 table for
    % side-by-side comparison
    compareStruct = combineSimSettingsIntoTable(compareStruct, "settings");

    % Consolidate the playerStatsTbl and playerConfIntTbl for all files
    % being compared
    compareStruct = combinePlayerSimData(compareStruct, "playerStatsTbl", false);
    compareStruct = combinePlayerSimData(compareStruct, "playerConfIntTbl", true);
    
    % Consolidate the pairwise win rate statistical significance test data
    compareStruct = combinePlayerSimData(compareStruct, "winRates", false);
    compareStruct = combineWinRatesStatSigResults(compareStruct, "winRatesStatResultsTbl");
    
    % Consolidate Metrics that Measure "Closeness" (Avg. Diff Per Rank and player
    % rankings) into tables
    compareStruct = combineAvgDifferencesPerRank(compareStruct, "avgDiffPerRank");
    compareStruct = combinePlayerSimData(compareStruct, "playerRankings", false);

    % Consolidate correlation data (measures of balance and power) into a
    % table
    compareStruct = combineCorrelationTables(compareStruct, "R", "R");
    compareStruct = combineCorrelationTables(compareStruct, "p-value", "p");
    compareStruct = combineCorrelationTables(compareStruct, "R LCL", "RLCL");
    compareStruct = combineCorrelationTables(compareStruct, "R UCL"', "RUCL");
    compareStruct = combineCorrelationTables(compareStruct, "R^2", "RSq");
    compareStruct = combineCorrelationTables(compareStruct, "R^2 LCL", "RSqLCL");
    compareStruct = combineCorrelationTables(compareStruct, "R^2 UCL", "RSqUCL");
    compareStruct = combineCorrelationTables(compareStruct, "R^2 Range", "RSqRange");

    % Save the Comparison Results
    fileName = strcat('Comparison File ', num2str(now), '.mat');
    save(fileName, '-struct', 'compareStruct');
    disp("The comparison results were saved to the file '" + fileName + "'.");
end

%%  runFileChecks - This function checks whether the files provided as arguments 
% are in the correct format for comparison processing
function runFileChecks(varargin)
    assert(nargin > 1, "You must include at least two files to compare.")

    for i = 1:nargin
        str = varargin{i};
        assert(str(end-3:end) == ".mat", strcat("Argument ", ...
            num2str(i), " is not a .mat file."));
        assert(exist(varargin{i}) == 2, strcat("Argument ", ...
            num2str(i), " does not exist or cannot be found."));
    end
end

%% combineSimSettingsIntoTable - This function combines the simulation parameters/settings
% used in each file.
function compareStruct = combineSimSettingsIntoTable(compareStruct, compareField)
% This function combines the settings from all simulations (files) into one
% table for easy comparison.
    compareStruct.(compareField) = struct2table(compareStruct.file(1).(compareField));
    for i = 2:size(compareStruct.file,2)
        compareStruct.(compareField) = [compareStruct.(compareField); struct2table(compareStruct.file(i).(compareField))];
    end

    compareStruct.(compareField) = [table(compareStruct.fileID', 'VariableNames', "Sim ID"), compareStruct.(compareField)];
    compareStruct.(compareField)
end

%% combineCorrelationTables - This function combines player simulation 
% combines the results of different individual player metrics for each file. 
% Since several of the tables are formatted similarly, this was reused to form the 
% playerStatsTbl, playerConfIntTbl, and playerRankings tables.
function compareStruct = combinePlayerSimData(compareStruct, compareField, iterationsApply)


    compareStruct.(compareField) = table.empty;
    for i = 1:size(compareStruct.file,2)
        
        % Some metrics were only reported if nIterations was > 1. This
        % if condition checks whether this restriction applies to the given
        % metric being combined into the table and, if so, whether there 
        % was at least > 1 iteration during that simulation run.
        if or(iterationsApply == false, compareStruct.file(i).settings.nIterations > 1)
            playerLabels = compareStruct.file(i).(compareField).Properties.RowNames;
            playerTypes = compareStruct.file(i).settings.playerTypes(1:compareStruct.file(i).settings.nPlayers);
            simNumber = repmat(compareStruct.fileID(i),compareStruct.file(i).settings.nPlayers,1); 
            compareStruct.(compareField) = [compareStruct.(compareField); table(simNumber, playerLabels, playerTypes', 'VariableNames', {'Sim #', 'Player #', 'Player Type'}), compareStruct.file(i).(compareField)];
            compareStruct.(compareField).Properties.RowNames = {}; % Delete the old name for the rows, since now we are constructing a table with all simulations combined
        end
    end
    compareStruct.(compareField)
end

%% combineCorrelationTables - This function combines the results of the average 
% differences in ranks for each file.
function compareStruct = combineAvgDifferencesPerRank(compareStruct, compareField)
   
    compareStruct.(compareField) = table.empty;
    for i = 1:size(compareStruct.file,2)
        % Replicate the simulation number for as many rows of data as needed
        simNumber = repmat(compareStruct.fileID(i),compareStruct.file(i).settings.nPlayers-1,1); 
        compareStruct.(compareField) = [compareStruct.(compareField); table(simNumber, 'VariableNames', {'Sim #'}), compareStruct.file(i).(compareField)];
    end

    compareStruct.(compareField)
end

%% combineCorrelationTables - This function combines the results of the pairwise
% statistical significance tests for win rates for each file.
function compareStruct = combineWinRatesStatSigResults(compareStruct, compareField)
   
    compareStruct.(compareField) = table.empty;

    % For each file submitted for comparison, 
    for i = 1:size(compareStruct.file,2) 

        % Replicate the simulation number for as many rows of data as needed
        % nchoosek(nPlayers,2) because we want compare all possible
        % pairings of players to see pairwise difference
        nPlayers = compareStruct.file(i).settings.nPlayers;
        simNumber = repmat(compareStruct.fileID(i),nchoosek(nPlayers,2),1);

        % Loop through each pairwise comparison of each of the nPlayers
        playerAType = "";
        playerBType = "";
        pair = 1;
        for a = 1:nPlayers - 1
            for b = a+1:nPlayers
                playerAType(pair,1) = compareStruct.file(i).settings.playerTypes(a);
                playerBType(pair,1) = compareStruct.file(i).settings.playerTypes(b);
                pair = pair + 1;
            end
        end

        compareStruct.(compareField) = [compareStruct.(compareField); table(simNumber, playerAType, playerBType, 'VariableNames', {'Sim #', 'Player A Type', 'Player B Type'}), compareStruct.file(i).(compareField)];
    end

    compareStruct.(compareField)
end

%% combineCorrelationTables - This function combines the correlation results from each file.
function compareStruct = combineCorrelationTables(compareStruct, corrMetric, newName)
   
    nFilesWithCorrelations = 0;
    fileWithCorrelationsFound = false;
    for i = 1:size(compareStruct.file,2)
        if compareStruct.file(i).settings.nIterations > 1
            nFilesWithCorrelations = nFilesWithCorrelations + 1;
            if (fileWithCorrelationsFound == false)
                correlPairs = compareStruct.file(i).corrTbl.Properties.RowNames;
                fileWithCorrelationsFound = true;
            end
        end
    end
    
    simNumber = 1:nFilesWithCorrelations;
    varNames = {'Sim #', 'scores/trains', 'scores/cards left', 'scores/dests completed', 'scores/turns', 'scores/routes', 'trains/cards left', 'trains/dests completed', 'trains/turns', ...
'trains/routes', 'cards left/dests completed', 'cards/turns', 'cards/routes', 'dests completed/turns', 'dests completed/routes', 'turns/routes'};

    compareStruct.corrTbl.(newName) = table.empty;
    for i = 1:size(compareStruct.file,2)

        % If there is more than one iteration in a run, then we ran
        % corerlation statistics on it. We don't want to create any runs
        % for runs that do not have correlation statistics.
        if compareStruct.file(i).settings.nIterations > 1
            % Replicate the simulation number for as many rows of data as needed
            data = compareStruct.file(i).corrTbl.(corrMetric);
            compareStruct.corrTbl.(newName) = [compareStruct.corrTbl.(newName); table(i, data(1), data(2), data(3), data(4), data(5), data(6), data(7), data(8), data(9), data(10), data(11), data(12), data(13), data(14), data(15), 'VariableNames', varNames)];
        end
    end

    compareStruct.corrTbl.(newName)
end