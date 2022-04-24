function CompareResults(varargin)
    % This function reads in .MAT files generated from the simulation. 
    % It compiles the results tables of each simulation to run to allow 
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

    % Store the number of files in the program
    nFiles = size(compareStruct.file,2);

    % Save the number of players in each game for ease of comparison by #
    % of players later -- several functions will use nPlayers to help
    % separate results by nPlayers (2, 3, or 4)
    for i = 1:nFiles
        nPlayersAllSims(i,1) = compareStruct.file(i).settings.nPlayers;
    end

    % Consolidate settings for all files being compared into 1 table for
    % side-by-side comparison
    compareStruct = compileSimSettingsIntoTable(compareStruct, "settings");

    % Consolidate the playerStatsTbl and playerConfIntTbl for all files
    % being compared
    compareStruct = compilePlayerSimData(compareStruct, "playerStatsTbl", false, nFiles, nPlayersAllSims, true);
    compareStruct = compilePlayerSimData(compareStruct, "playerConfIntTbl", true, nFiles, nPlayersAllSims, true);
    
    % Consolidate the pairwise win rate statistical significance test data
    compareStruct = compilePlayerSimData(compareStruct, "winRates", false, nFiles, nPlayersAllSims, false);
    compareStruct = compileWinRatesStatSigResults(compareStruct, "winRatesStatResultsTbl", nPlayersAllSims);
    
    % Consolidate Metrics that Measure "Closeness" (Avg. Diff Per Rank and player
    % rankings) into tables
    compareStruct = compileAvgDifferencesPerRank(compareStruct, "avgDiffPerRank", nPlayersAllSims);
    compareStruct = compilePlayerSimData(compareStruct, "playerRankings", false, nFiles, nPlayersAllSims, false);

    % Consolidate correlation data (measures of balance and power) into a
    % table
    compareStruct = compileCorrelationTables(compareStruct, "R", "R");
    compareStruct = compileCorrelationTables(compareStruct, "p-value", "p");
    compareStruct = compileCorrelationTables(compareStruct, "R LCL", "RLCL");
    compareStruct = compileCorrelationTables(compareStruct, "R UCL"', "RUCL");
    compareStruct = compileCorrelationTables(compareStruct, "R^2", "RSq");
    compareStruct = compileCorrelationTables(compareStruct, "R^2 LCL", "RSqLCL");
    compareStruct = compileCorrelationTables(compareStruct, "R^2 UCL", "RSqUCL");
    compareStruct = compileCorrelationTables(compareStruct, "R^2 Range", "RSqRange");

    % Consolidate winning routes data into a comparison table
    compareStruct = compileWinningRoutesTables(compareStruct, nPlayersAllSims);

    % Save the Comparison Results
    fileName = strcat('Comparison File ', num2str(now), '.mat');
    save(fileName, '-struct', 'compareStruct');
    disp("The comparison results were saved to the file '" + fileName + "'.");
end

%%  runFileChecks - This function checks whether the files provided as arguments 
% are in the correct format for comparison processing
function runFileChecks(varargin)
    assert(nargin > 1, "You must include at least two files to compare.")

    % Check each file
    for i = 1:nargin
        str = varargin{i};
        assert(str(end-3:end) == ".mat", strcat("Argument ", ...
            num2str(i), " is not a .mat file."));
        assert(exist(varargin{i}) == 2, strcat("Argument ", ...
            num2str(i), " does not exist or cannot be found."));
    end  
end

%% compileSimSettingsIntoTable - This function compiles the simulation parameters/settings
% used in each file.
function compareStruct = compileSimSettingsIntoTable(compareStruct, compareField)
% This function compiles the settings from all simulations (files) into one
% table for easy comparison.
    compareStruct.(compareField) = struct2table(compareStruct.file(1).(compareField));
    for i = 2:size(compareStruct.file,2)
        compareStruct.(compareField) = [compareStruct.(compareField); struct2table(compareStruct.file(i).(compareField))];
    end

    compareStruct.(compareField) = [table(compareStruct.fileID.', 'VariableNames', "Sim ID"), compareStruct.(compareField)];
    compareStruct.(compareField)
end

%% compilePlayerSimData - This function compiles player simulation 
% compiles the results of different individual player metrics for each file. 
% Since several of the tables are formatted similarly, this was reused to form the 
% playerStatsTbl, playerConfIntTbl, and playerRankings tables.
function compareStruct = compilePlayerSimData(compareStruct, compareField, iterationsApply, nFiles, nPlayersAllSims, averagesApply)

    % Initialize table for comparing player simulation statistics
    compareStruct.(compareField).runData.nPlayersAll = table.empty;
    compareStruct.(compareField).runData.nPlayers2 = table.empty;
    compareStruct.(compareField).runData.nPlayers3 = table.empty;
    compareStruct.(compareField).runData.nPlayers4 = table.empty;

    % Loop through the files to construct the player statistics tables --
    % with all the results and also separated by # of players
    for i = 1:nFiles
        % Some metrics were only reported if nIterations was > 1. This
        % if condition checks whether this restriction applies to the given
        % metric being compiled into the table and, if so, whether there 
        % was at least > 1 iteration during that simulation run.
        nGameIterations(i,1) = compareStruct.file(i).settings.nIterations;
        ruleSet(i,1) = compareStruct.file(i).settings.ruleSet;
        if or(iterationsApply == false, nGameIterations(i,1) > 1)
            playerLabels = compareStruct.file(i).(compareField).Properties.RowNames;
            playerTypes = compareStruct.file(i).settings.playerTypes(1:nPlayersAllSims(i));
            simNumber = repmat(compareStruct.fileID(i),nPlayersAllSims(i),1); 
            ruleSetRep = repmat(ruleSet(i,1), nPlayersAllSims(i), 1);
            % Take averages of game statistic averages and standard deviations to allow for easier
            % comparison of different games
            avgPlayerVal(i,:) = mean(table2array(compareStruct.file(i).(compareField)(:,:)));
            
            % Build the compiled run data table (all # players) and the
            % table separated out by # players
            compareStruct = buildRunDataTable(compareStruct, compareField, "nPlayersAll", simNumber, playerLabels, playerTypes, ruleSetRep, i);
            playerField = strcat("nPlayers", num2str(nPlayersAllSims(i)));
            compareStruct = buildRunDataTable(compareStruct, compareField, playerField, simNumber, playerLabels, playerTypes, ruleSetRep, i);
        end
    end
    % Display all simulation individual player data
    compareStruct.(compareField).runData.nPlayersAll
    compareStruct.(compareField).runData.nPlayers2
    compareStruct.(compareField).runData.nPlayers3
    compareStruct.(compareField).runData.nPlayers4  

    % If we want to calculate overall averages/player for certain metrics,
    % we can do that here. Certain ones, such as average win rate/player of
    % average % first/% last would not apply here since the answer would be
    % trivial: 1/nPlayers
    if averagesApply
        compareStruct = buildAvgsTables(compareStruct, compareField, iterationsApply, nFiles, nPlayersAllSims, nGameIterations, ruleSet, avgPlayerVal);
    elseif compareField == "winRates"
        % For the win rates struct field, since we cannot measure averages directly, 
        % we will make an easier way to compare win rates by measuring the 
        % absolute deviation of each player's score from the "ideal" score 
        % (1/nPlayers).
        % The greater the disparity, the less balanced the game?
        varNames = horzcat('Sim #', '# Players', '# Iterations', 'Rule Set', 'Target Deviation', compareStruct.file(1).(compareField)(:,:).Properties.VariableNames + "_Deviation");
        compareStruct = calcDifferencesFromBaselineWinRate(compareStruct, compareField, nPlayersAllSims, nGameIterations, ruleSet, varNames);
    end
end

%% buildRunDataTable -- This function builds the runData table for the specified field.
function compareStruct = buildRunDataTable(compareStruct, compareField, playerField, simNumber, playerLabels, playerTypes, ruleSetRep, i)
    compareStruct.(compareField).runData.(playerField) = [compareStruct.(compareField).runData.(playerField); table(simNumber, playerLabels, playerTypes.', ruleSetRep, 'VariableNames', {'Sim #', 'Player #', 'Player Type', 'Rule Set'}), compareStruct.file(i).(compareField)];
    compareStruct.(compareField).runData.(playerField).Properties.RowNames = {}; % Delete the old name for the rows, since now we are constructing a table with all simulations compiled
end

%% buildAvgsTables -- This function puts averages per player for all simulations (regardless of players) as well as simulations based on # of players
% into tables.
function compareStruct = buildAvgsTables(compareStruct, compareField, iterationsApply, nFiles, nPlayersAllSims, nGameIterations, ruleSet, avgPlayerVal)
    % Construct Summary Table with Averages of Each Simulation
    varNames = horzcat('Sim #', '# Players', '# Iterations', 'Rule Set', compareStruct.file(1).(compareField)(:,:).Properties.VariableNames);

    % Summarize all results together (including games of different numbers
    % of players)
    if iterationsApply == false
        compareStruct.(compareField).summary.nPlayersAll = array2table([(1:nFiles).', nPlayersAllSims, nGameIterations, ruleSet, avgPlayerVal], 'VariableNames',varNames);
    else
        % only save results for simulations where the iterations were > 1
        % This condition would be a necessary check for things like
        % confidence intervals, which only make sense if we're looking at
        % more than one iteration of data.
        idx = find(nGameIterations > 1);
        compareStruct.(compareField).summary.nPlayersAll = array2table([idx, nPlayersAllSims(idx), nGameIterations(idx), ruleSet(idx), avgPlayerVal(idx,:)], 'VariableNames',varNames);
    end
    compareStruct.(compareField).summary.nPlayersAll

    % Separating simulation results out by # of players; store them 
    % in their own summary fields          
    for n = 2:MAX_PLAYERS

        % If there is at least one game with n players (2, 3, or 4),
        % then compile all games with n players into a table.
        nGamesWithNPlayers = sum(nPlayersAllSims == n);
        if nGamesWithNPlayers > 0 
            
            % Find which simulations had n players
            if iterationsApply == false
                idx = find(nPlayersAllSims == n);
            else
                idx = find(and(nPlayersAllSims == n,nGameIterations > 1));
            end
            
            % Combine the game results together of all simulations that have n players in them
            nPlayersfieldName = "nPlayers" + n;
            compareStruct.(compareField).summary.(nPlayersfieldName) = array2table([idx, nPlayersAllSims(idx,1), nGameIterations(idx,1), ruleSet(idx,1), avgPlayerVal(idx,:)], 'VariableNames', varNames);     
            compareStruct.(compareField).summary.(nPlayersfieldName)
        end
    end
end

%% calcDifferencesFromBaselineWinRate
% This function measures the absolute deviation of each player's score from
% the "ideal" score (1/nPlayers) and reports it in a table for easier
% comparison later between games of equal # of players.
% The greater the disparity, the less balanced the game.
function compareStruct = calcDifferencesFromBaselineWinRate(compareStruct, compareField, nPlayersAllSims, nGameIterations, ruleSet, varNames)
    for n = 2:MAX_PLAYERS
        if sum(nPlayersAllSims == n)
            compareStruct.(compareField).deviations.("nPlayers" + n) = table.empty;
            % ideal baseline for comparing win rates
            baseline = 1/n; 
            idx = find(nPlayersAllSims == n);
            
            % For all the sims with n players, take the average absolute
            % deviation from the baseline for each player
            avgPlayerVal = zeros(length(idx),1);
            for i = 1:length(idx)
                avgPlayerVal(i,1) = mean(abs(table2array(compareStruct.file(idx(i)).(compareField)) - 0.25));
            end

            % Form and print out table
            nPlayersfieldName = "nPlayers" + n;
            compareStruct.(compareField).deviations.(nPlayersfieldName) = array2table([idx, nPlayersAllSims(idx,1), nGameIterations(idx,1), ruleSet(idx,1), zeros(length(idx),1), avgPlayerVal(:)], 'VariableNames', varNames);     
            compareStruct.(compareField).deviations.(nPlayersfieldName)
        end
    end
end

%% compileAvgDifferencesPerRank - This function compiles the results of the average 
% differences in ranks for each file.
function compareStruct = compileAvgDifferencesPerRank(compareStruct, compareField, nPlayersAllSims)   
    compareStruct.(compareField).runData.nPlayersAll = table.empty;
    for i = 1:size(compareStruct.file,2)
        % Replicate the simulation number for as many rows of data as needed
        nPlayers = compareStruct.file(i).settings.nPlayers;
        nPlayersRep = repmat(nPlayers, nPlayers-1, 1);
        simNumberRep = repmat(compareStruct.fileID(i),nPlayers-1,1); 
        nIterationsRep = repmat(compareStruct.file(i).settings.nIterations, nPlayers-1, 1);
        compareStruct.(compareField).runData.nPlayersAll = [compareStruct.(compareField).runData.nPlayersAll; table(simNumberRep, nPlayersRep, nIterationsRep, 'VariableNames', {'Sim #', '# Players', '# Iters'}), compareStruct.file(i).(compareField)];
    end
    compareStruct.(compareField).runData.nPlayersAll

    % Construct tables summarizing the run data and average difference between each of
    % the rankings for each # of players.
    compareStruct = processNPlayersDiffInRankData(compareStruct, nPlayersAllSims, compareField);
end

%% processNPlayersDiffInRankData -- This function processes the run data and summary average difference in ranks data
% and reports it for simulations of equal # of players
function compareStruct = processNPlayersDiffInRankData(compareStruct, nPlayersAllSims, compareField)
    % Construct tables summarizing the average difference between each of
    % the rankings.
    for n = 2:MAX_PLAYERS
    
        % If there is at least one game with n players (2, 3, or 4),
        % then compile all games with n players into a table.
        nGamesWithNPlayers = sum(nPlayersAllSims == n);
    
        if nGamesWithNPlayers > 0 
            
            % Find which simulations had n players
            idx = find(nPlayersAllSims == n);

            % Combine the game results together of all simulations that have n players in them
            nPlayersFieldName = "nPlayers" + n;
            compareStruct.(compareField).runData.(nPlayersFieldName) = table.empty;
            compareStruct.(compareField).summary.(nPlayersFieldName) = table.empty;

            differencesBetweenRanks = zeros(n-1,length(idx));
            for f = 1:length(idx)
    
                nPlayersInI = compareStruct.file(idx(f)).settings.nPlayers;
                nPlayersRep = repmat(nPlayersInI, nPlayersInI-1, 1);
                simNumberRep = repmat(compareStruct.fileID(idx(f)),nPlayersInI-1,1); 
                nIterationsRep = repmat(compareStruct.file(idx(f)).settings.nIterations,nPlayersInI-1,1);
                differencesBetweenRanks(:,f) = compareStruct.file(idx(f)).(compareField){:,2};
                compareStruct.(compareField).runData.(nPlayersFieldName) = [compareStruct.(compareField).runData.(nPlayersFieldName); table(simNumberRep, nPlayersRep, nIterationsRep, 'VariableNames', {'Sim #', '# Players', '# Iters'}), compareStruct.file(idx(f)).(compareField)];
            end
            compareStruct.(compareField).runData.(nPlayersFieldName)

            % Now that all the files have been processed and their rankings
            % gathered, let's take the average of each rank.
            avgDiffInRanksAllSims = mean(differencesBetweenRanks.', 1);
            sdDiffInRanksAllSims = std(differencesBetweenRanks.', 0, 1);
            switch n
                case 2
                    rankNames = {'1st and 2nd'};
                case 3
                    rankNames = {'1st and 2nd'; '2nd and 3rd'};
                case 4
                    rankNames = {'1st and 2nd'; '2nd and 3rd'; '3rd and 4th'};
            end
            
            % Format labels
            avgLabel = horzcat('Avg Difference-', nPlayersFieldName);
            sdLabel = horzcat('Std Dev-', nPlayersFieldName);

            compareStruct.(compareField).summary.(nPlayersFieldName) = table(nPlayersRep, rankNames, avgDiffInRanksAllSims.', sdDiffInRanksAllSims.', 'VariableNames', {'# Players', 'Rank', horzcat(avgLabel{:}), horzcat(sdLabel{:})});
            compareStruct.(compareField).summary.(nPlayersFieldName)
        end
    end
end

%% compileWinRatesStatsSigResults - This function compiles the results of the pairwise
% statistical significance tests for win rates for each file.
function compareStruct = compileWinRatesStatSigResults(compareStruct, compareField, nPlayersAllSims) 
    varNames = {'Sim #', '# Players', '# Iters', 'Player A Type', 'Player B Type'};
    
    % Build the compiled win rates results table for all simulations (all #
    % of players)
    nSimulations = size(compareStruct.file,2);
    idx = 1:nSimulations;
    compareStruct = buildPairwiseCompareTables(compareStruct, compareField, "nPlayersAll", nSimulations, idx, varNames);
  
    % Build the win rates results tables for simulations broken out by # of
    % players
    for n = 2:MAX_PLAYERS

        % If there is at least one game with n players (2, 3, or 4),
        % then compile all games with n players into a table.
        nGamesWithNPlayers = sum(nPlayersAllSims == n);
        if nGamesWithNPlayers > 0 
            
            % Find which simulations had n players
            idx = find(nPlayersAllSims == n);
            nSimulations = length(idx);

            % Combine the game results together of all simulations that have n players in them
            nPlayersFieldName = "nPlayers" + n;           
            compareStruct = buildPairwiseCompareTables(compareStruct, compareField, nPlayersFieldName, nSimulations, idx, varNames);
        end
    end
end

%% buildPairwiseCompareTables -- this builds the pairwise comparison tables
% for a particular nPlayersFieldName -- idx would contain all files for the
% nPlayersAll field and would contain only the relevant simulations for the
% nPlayers2, nPlayers3, and nPlayers4 fields
function compareStruct = buildPairwiseCompareTables(compareStruct, compareField, nPlayersFieldName, nSimulations, idx, varNames)
    compareStruct.(compareField).(nPlayersFieldName) = table.empty;

    % For each file submitted for comparison in idx
    for f = 1:nSimulations
        % Replicate the simulation number and # of players for as many rows 
        % of data as needed, i.e., nchoosek(nPlayers,2), because we want to
        % compare all possible pairings of players to see pairwise
        % differences
        nPlayers = compareStruct.file(idx(f)).settings.nPlayers;
        nIterations(idx(f),1) = compareStruct.file(idx(f)).settings.nIterations;
        simNumberRep = repmat(idx(f),nchoosek(nPlayers,2),1);
        numPlayersRep = repmat(nPlayers, nchoosek(nPlayers,2),1);
        numItersRep = repmat(nIterations(idx(f),1), nchoosek(nPlayers,2),1);

        playerAType = "";
        playerBType = "";
        pair = 1;

        % Loop through each player pair nPlayers in simulation idx(f)
            for a = 1:nPlayers - 1
                for b = a+1:nPlayers
                    playerAType(pair,1) = compareStruct.file(idx(f)).settings.playerTypes(a);
                    playerBType(pair,1) = compareStruct.file(idx(f)).settings.playerTypes(b);
                    pair = pair + 1;
                end
            end
         
        compareStruct.(compareField).(nPlayersFieldName) = [compareStruct.(compareField).(nPlayersFieldName); table(simNumberRep, numPlayersRep, numItersRep, playerAType, playerBType, 'VariableNames', varNames), compareStruct.file(idx(f)).(compareField)];     
    end    
    compareStruct.(compareField).(nPlayersFieldName)
end

%% compileCorrelationTables - This function compiles the correlation results from each file.
function compareStruct = compileCorrelationTables(compareStruct, corrMetric, newName)   
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
     
    if fileWithCorrelationsFound
        % Initialize correlation tables
        compareStruct.corrTbl.(newName).runData.nPlayersAll = table.empty;
        for i = 2:MAX_PLAYERS
            playerField = "nPlayers" + i;
            compareStruct.corrTbl.(newName).runData.(playerField) = table.empty;
            compareStruct.corrTbl.(newName).deviations.(playerField) = table.empty;
        end   

        % Process the data to form the correlation tables
        compareStruct = processFilesWithCorrelationData(compareStruct, corrMetric, newName);

        % Display results
        compareStruct.corrTbl.(newName).runData.nPlayersAll
        for i = 2:MAX_PLAYERS
            playerField = "nPlayers" + i;
            compareStruct.corrTbl.(newName).runData.(playerField)
            compareStruct.corrTbl.(newName).deviations.(playerField)
        end
    end

end

%% processFilesWithCorrelationData - This function prepares the data for input 
% into the correlation comparison tables:
% 1. Raw Data Results together
% 2. Raw Data Results broken out by # of players
% 3. Deviations from average broken out by # of players
function compareStruct = processFilesWithCorrelationData(compareStruct, corrMetric, newName)
    varNames = {'Sim #', '# Players', '# Iters', 'Rule Set', 'Metric', 'scores and trains', 'scores and cards left', ...
            'scores and dests completed', 'scores and turns', 'scores and routes', 'scores and avg length', ...
            'scores and longest route', 'scores and # turns ahead', 'scores and # turns ahead w/ long route', ...
            'trains and cards left', 'trains and dests completed', 'trains and turns', ...
            'trains and routes', 'trains and avg length','trains and longest route', ...
            'trains and # turns ahead', 'trains and # turns ahead w/ long route', ...
            'cards and dests completed', 'cards and turns', 'cards and routes', 'cards and avg length', ...
            'cards and longest route', 'cards and # turns ahead', 'cards and # turns ahead w/ long route', ...
            'dests completed and turns', 'dests completed and routes', 'dests completed and avg length', ...
            'dests completed and longest route', 'dests completed and # turns ahead', 'dests completed and # turns ahead w/ long route', ...
            'turns and routes', 'turns and avg length', 'turns and longest route', 'turns and # turns ahead', 'turns and # turns ahead w/ long route', ...
            'routes and avg length', 'routes and longest route', 'routes and # turns ahead', 'routes and # turns ahead w/ long route', ...
            'avg length and longest route', 'avg length and # turns ahead', 'avg length # turns ahead w/ long route', ...
            'longest route and # turns ahead', 'longest route and # turns ahead w/ long route', ...
            '# turns ahead and # turns ahead w/ long route'};

    % For use later in finding the average of the correlation statistic
    % and then determining the deviation of each sim run from that
    % average
    dataSums = zeros(45,4);
    numSimsWithData = zeros(4,1);
    for i = 1:size(compareStruct.file,2)

        % If there is more than one iteration in a run, then we ran
        % correlation statistics on it. We don't want to create any runs
        % for runs that do not have correlation statistics.
        if compareStruct.file(i).settings.nIterations > 1

            nPlayers = compareStruct.file(i).settings.nPlayers;
            data = compareStruct.file(i).corrTbl.(corrMetric);
            dataSums(:,nPlayers) = dataSums(:,nPlayers) + data;
            numSimsWithData(nPlayers) = numSimsWithData(nPlayers) + 1;
            nIterations = compareStruct.file(i).settings.nIterations;
            ruleSet = compareStruct.file(i).settings.ruleSet;

            % Construct tables summarizing raw data from all sims and broken
            % out by players
            compareStruct = buildCorrelationTables(compareStruct, newName, "runData", "nPlayersAll", i, nPlayers, nIterations, ruleSet, corrMetric, data, varNames);
            playerFieldName = "nPlayers" + nPlayers;
            compareStruct = buildCorrelationTables(compareStruct,newName, "runData", playerFieldName, i, nPlayers, nIterations, ruleSet, corrMetric, data, varNames);
        end
    end

    % Build the tables for measuring deviation between correlation metrics
    % and the average for simulations of equal number of players
    compareStruct = processCorrelDeviationData(compareStruct, corrMetric, newName, dataSums, numSimsWithData, varNames);
end

%% processCorrelDeviationData -- This function calculates by how much the correlation coefficient calculated for each simulation differences from the average for that metric 
% for simulations of the same number of players.
function compareStruct = processCorrelDeviationData(compareStruct, corrMetric, newName, dataSums, numSimsWithData, varNames)
    for n = 2:MAX_PLAYERS
        if numSimsWithData(n) > 0
            avgCorrMetric(:, n) = dataSums(:,n)./numSimsWithData(n);
            playerFieldName = "nPlayers" + n;            
            compareStruct = buildCorrelationTables(compareStruct, newName, "deviations", playerFieldName, 0, n, 0, corrMetric + "-Average Value", corrMetric, avgCorrMetric(:,n), varNames);
        end
    end

    for i = 1:size(compareStruct.file,2)

        if compareStruct.file(i).settings.nIterations > 1
            deviations = "";
            data = compareStruct.file(i).corrTbl.(corrMetric);
            nPlayers = compareStruct.file(i).settings.nPlayers;
            nIterations = compareStruct.file(i).settings.nIterations;
            ruleSet = compareStruct.file(i).settings.ruleSet;

            playerFieldName = "nPlayers" + nPlayers;            
            deviations = data - avgCorrMetric(:,nPlayers);
            compareStruct = buildCorrelationTables(compareStruct, newName, "deviations", playerFieldName, i, nPlayers, nIterations, ruleSet, corrMetric, deviations, varNames);
        end
    end  
end

%% buildCorrelationTables -- This function builds a correlation table for
% corrMetric, comparing each pair of 10 variables (45 comparisons).
function compareStruct = buildCorrelationTables(compareStruct,newName, detailFieldName, playerFieldName, i, nPlayers, nIterations, ruleSet, corrMetric, data, varNames)
    compareStruct.corrTbl.(newName).(detailFieldName).(playerFieldName) = [compareStruct.corrTbl.(newName).(detailFieldName).(playerFieldName); table(i, nPlayers, nIterations, ruleSet, corrMetric, data(1), data(2), data(3), data(4), data(5), data(6), data(7), data(8), data(9), data(10), data(11), data(12), data(13), data(14), data(15), ...
        data(16), data(17), data(18), data(19), data(20), data(21), data(22), data(23), data(24), data(25), data(26), data(27), data(28), data(29), data(30), data(31), data(32), data(33), data(34), data(35), data(36), ...
        data(37), data(38), data(39), data(40), data(41), data(42), data(43), data(44), data(45), 'VariableNames', varNames)];
end

%% compileWinningRoutesTables - This function compiles the winning routes from all the simulations to be compared into a single table, which summarizes the # and % of games the routes showed up in each simulation and across all simulations being compared
function compareStruct = compileWinningRoutesTables(compareStruct, nPlayersAllSims)   
    % Initialize the Compare.winningRoutesTbl field with the first file's
    % data and initialize values to be utilized when building the
    % comparison table
    idx = 1:size(compareStruct.file,2);
    fieldName = "nPlayersAll";
    nSimulations = length(idx);

    % First, create a table with all data (regardless of # of players)
    compareStruct = buildWinningRoutesTables(compareStruct, fieldName, nSimulations, idx);

    % Separating simulation results out by # of players now; store them 
    % in their own winningRoutesTbl fields  
    for n = 2:MAX_PLAYERS
        numSimsWithNPlayers = sum(find(nPlayersAllSims == n));
        
        % Only display tables for simulations where there were at least
        % n players
        if numSimsWithNPlayers > 0

            % Initialize values for each field that will store the table
            % for the winning routes grouped by number of players
            idx = find(nPlayersAllSims == n);
            fieldName = "nPlayers" + n;
            nSimulations = length(idx);
            compareStruct = buildWinningRoutesTables(compareStruct, fieldName, nSimulations, idx);
        end
    end
end

%% buildWinningRoutesTables -- This function Constructs a winning routes table
function compareStruct = buildWinningRoutesTables(compareStruct, fieldName, nSimulations, idx)
    
    compareStruct.winningRoutesTbl.(fieldName) = [compareStruct.file(idx(1)).winningRoutesTbl, num2cell(cell2mat(compareStruct.file(idx(1)).winningRoutesTbl(:,3))./compareStruct.file(idx(1)).settings.nIterations)];
    totalGamesAcrossSimulations = cell2mat(compareStruct.winningRoutesTbl.(fieldName)(:,3));
    totalIterations = compareStruct.file(idx(1)).settings.nIterations;
    header = {'Location 1', 'Location 2', strcat('Sim', num2str(idx(1)), ' # Games'), strcat('Sim', num2str(idx(1)), ' % Games')};

    % Loop through the rest of the files if there are more to form the table
    if nSimulations > 1               
        for i = 2:nSimulations
            header = horzcat(header, strcat('Sim', num2str(idx(i)), ' # Games'), strcat('Sim', num2str(idx(i)), ' % Games'));
            totalGamesAcrossSimulations = totalGamesAcrossSimulations + cell2mat(compareStruct.file(idx(i)).winningRoutesTbl(:,3));
            totalIterations = totalIterations + compareStruct.file(idx(i)).settings.nIterations;
            compareStruct.winningRoutesTbl.(fieldName) = [compareStruct.winningRoutesTbl.(fieldName), compareStruct.file(idx(i)).winningRoutesTbl(:,3), num2cell(cell2mat(compareStruct.file(idx(i)).winningRoutesTbl(:,3))./compareStruct.file(idx(i)).settings.nIterations)];
        end
    end
    header = horzcat(header, 'Total # Games-' + fieldName, 'Total % Games-'+ fieldName);

    compareStruct.winningRoutesTbl.(fieldName) = [compareStruct.winningRoutesTbl.(fieldName), num2cell(totalGamesAcrossSimulations), num2cell(totalGamesAcrossSimulations./totalIterations)];
    compareStruct.winningRoutesTbl.(fieldName) = cell2table(compareStruct.winningRoutesTbl.(fieldName), 'VariableNames', header);
    compareStruct.winningRoutesTbl.(fieldName)
end

%% A function for storing the constant MAX_PLAYERS
function N = MAX_PLAYERS
    N = 4;
end