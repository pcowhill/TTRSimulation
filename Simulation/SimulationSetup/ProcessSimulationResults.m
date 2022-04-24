function ProcessSimulationResults(allSimResults, nPlayers, finalAxes, saveResults, nIterations, rngSeed, nWorkers, players, ruleClass)   
    % Combine the runs from all the iterations that were run in parallel
    % into a single table for pcessing
    [combinedSimResults, summaryResults] = combineResultsStruct(allSimResults, nIterations);

    % Calculate Average Scores, Number of Trains Played, Number of Train
    % Cards Left, Number of Destination Cards Completed, Number of Turns
    % per Player, and Number of Routes Claimed
    scoresCols = 1:nPlayers;
    numTrainsCols = nPlayers+1:2*nPlayers;
    numTrainCardCols = 2*nPlayers+1:3*nPlayers;
    numDestCardCols = 3*nPlayers+1:4*nPlayers;
    turnsCols = 4*nPlayers+1:5*nPlayers;
    routesCols = 5*nPlayers+1:6*nPlayers;
    avgRouteLengthCols=6*nPlayers+1:7*nPlayers;
    longestRouteCols=7*nPlayers+1:8*nPlayers;
    numTurnsAheadCols=8*nPlayers+1:9*nPlayers;
    numTurnsAheadLongCols=9*nPlayers+1:10*nPlayers;

    playerNames = "Player " + [1:nPlayers];

    % Process, plot, and print statistics related to Averages and Standard
    % Deviations
    summaryResults = processAvgsAndSDs(nPlayers, playerNames, nIterations, combinedSimResults, scoresCols,numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols, avgRouteLengthCols, longestRouteCols, numTurnsAheadCols, numTurnsAheadLongCols, finalAxes, summaryResults);

    % Insert metrics about the statistical significance of the win
    % rates -- Chi-Square Significance Test
    summaryResults = processWinRates(nIterations, playerNames, combinedSimResults, scoresCols, nPlayers, summaryResults);

    % Print information about correlations between key statistics
    summaryResults = processCorrelationStats(combinedSimResults, nPlayers, summaryResults, nIterations);

    % Present a few other simple "closeness" measures
    summaryResults = calculateClosenessMetrics(nPlayers, playerNames, combinedSimResults, scoresCols, nIterations, summaryResults);

    % Save results if requested by the user
    if saveResults
        saveResultsToFile(summaryResults, nPlayers, rngSeed, nIterations, nWorkers, players, ruleClass);
    end

end

%% Combines results from several iterations into a single object of results, combinedSimResults
function [combinedSimResults, summaryResults] = combineResultsStruct(allSimResults, nIterations)
    combinedSimResults = allSimResults(1).summary;
    winningRoutes = cell2mat(allSimResults(1).winningRoutesTbl{2});
    if nIterations > 1
        for i = 2:nIterations
            combinedSimResults = [combinedSimResults; allSimResults(i).summary];
            winningRoutes = winningRoutes + cell2mat(allSimResults(i).winningRoutesTbl{2});
        end
    end
    
    summaryResults.combinedSimResults = combinedSimResults;
    
    % Winning Routes Table
    routeNames = allSimResults(1).winningRoutesTbl{1};
    frequencyOfRoutesClaimedInWins = [routeNames, num2cell(winningRoutes)];
    frequencyOfRoutesClaimedInWins
    summaryResults.winningRoutesTbl = frequencyOfRoutesClaimedInWins;
end

%% Calculate player means and standard deviations, which shall be used through the ProcessSimulationResults Matlab file
function [avgMeans, stdDevs] = CalculatePlayerMeansSDs(combinedSimResults, columns, nIters)
    % Calculate Average Scores, Number of Trains Played, Number of Cards
    % Left, and Number of Turns
    if nIters > 1
        avgMeans = mean(combinedSimResults(:,columns));
        stdDevs = std(combinedSimResults(:,columns));
    else % Just copy the actual values for the mean, and sd = 0
        avgMeans = combinedSimResults(:,columns);
        stdDevs = zeros(1,length(columns));
    end
end


%% processAvgsAndSDs Functions: processAvgsAndSDs, plotPlayerStats, BuildPlot, PlotSettings, dispConfidenceIntervals, and meanConfInterval
function summaryResults = processAvgsAndSDs(nPlayers, playerNames, nIters, combinedSimResults, scoresCols,numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols, avgRouteLengthCols, longestRouteCols, numTurnsAheadCols, numTurnsAheadLongCols, finalAxes, summaryResults)
    % Calculate means and standard deviations
    [avgPlayerScores, scoreSDs] = CalculatePlayerMeansSDs(combinedSimResults, scoresCols, nIters);
    [avgNumTrainsPlayed, trainSDs] = CalculatePlayerMeansSDs(combinedSimResults, numTrainsCols, nIters);
    [avgNumTrainCardsLeft, trainCardSDs] = CalculatePlayerMeansSDs(combinedSimResults, numTrainCardCols, nIters);
    [avgNumDestCardsCompleted, destCardsSDs] = CalculatePlayerMeansSDs(combinedSimResults, numDestCardCols, nIters);
    [avgTurnCount, turnSDs] = CalculatePlayerMeansSDs(combinedSimResults, turnsCols, nIters);
    [avgRoutesCount, routesSDs] = CalculatePlayerMeansSDs(combinedSimResults, routesCols, nIters);
    [avgAvgRouteLength, avgRouteLengthSDs] = CalculatePlayerMeansSDs(combinedSimResults, avgRouteLengthCols, nIters);
    [avgLongestRoute, longestRouteSDs] = CalculatePlayerMeansSDs(combinedSimResults, longestRouteCols, nIters);
    [avgNumTurnsAhead, numTurnsAheadSDs] = CalculatePlayerMeansSDs(combinedSimResults, numTurnsAheadCols, nIters);
    [avgNumTurnsAheadLong, numTurnsAheadLongSDs] = CalculatePlayerMeansSDs(combinedSimResults, numTurnsAheadLongCols, nIters);

    % Plots Stats by Player
    plotPlayerStats(nPlayers, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs, avgAvgRouteLength, avgRouteLengthSDs, avgLongestRoute, longestRouteSDs, avgNumTurnsAhead, numTurnsAheadSDs, avgNumTurnsAheadLong, numTurnsAheadLongSDs, finalAxes);

    % Print Summary table
    varNames = {'Avg Score', 'SD Score', 'Avg Trains Played', 'SD Trains Played', 'Avg Train Cards Left', 'SD Train Cards Left', 'Avg Dest Cards Completed', 'SD Dest Cards Completed', 'Avg Turns', 'SD Turns', 'Avg Routes', 'SD Routes', 'Avg Route Length', 'Avg Route Length SD', 'Avg Longest Route', 'Longest Route SD', 'Avg # Turns Ahead', 'Turns Ahead SD', 'Avg # Turns Ahead w/ Long Route', 'Turns Ahead w/ Long Route SD'};
    summaryResults.playerStatsTbl = table(avgPlayerScores', scoreSDs',avgNumTrainsPlayed', ...
        trainSDs', avgNumTrainCardsLeft', trainCardSDs', ...
        avgNumDestCardsCompleted', destCardsSDs', avgTurnCount', turnSDs',...
        avgRoutesCount', routesSDs',avgAvgRouteLength', avgRouteLengthSDs', avgLongestRoute', longestRouteSDs', avgNumTurnsAhead', numTurnsAheadSDs',avgNumTurnsAheadLong', numTurnsAheadLongSDs', 'RowNames', playerNames, 'VariableNames', varNames);
    summaryResults.playerStatsTbl

    % if the number of iterations is greater than one, calculate the
    % confidence intervals for player metrics -- will only calculate 
    % confidence intervals for simulations with at least 2 games
    summaryResults.playerConfIntTbl = dispConfidenceIntervals(nIters, playerNames, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs, avgAvgRouteLength, avgRouteLengthSDs, avgLongestRoute, longestRouteSDs, avgNumTurnsAhead, numTurnsAheadSDs, avgNumTurnsAheadLong, numTurnsAheadLongSDs);
end

function plotPlayerStats(nPlayers, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs, avgAvgRouteLength, avgRouteLengthSDs, avgLongestRoute, longestRouteSDs, avgNumTurnsAhead, numTurnsAheadSDs, avgNumTurnsAheadLong, numTurnsAheadLongSDs, finalAxes)
    
    xAxisLabel = "Players";
    BuildPlot(nPlayers, avgPlayerScores, scoreSDs, finalAxes.FinalScores);
    PlotSettings("Player Final Scores", xAxisLabel, "Final Score", finalAxes.FinalScores);

    BuildPlot(nPlayers, avgNumTrainsPlayed, trainSDs, finalAxes.TrainsPlayed);
    PlotSettings("Player Trains Played", xAxisLabel, "Trains Played", finalAxes.TrainsPlayed);

    BuildPlot(nPlayers, avgNumTrainCardsLeft, trainCardSDs, finalAxes.TrainCardsLeft);
    PlotSettings("Player Train Cards Left", xAxisLabel, "Cards Left", finalAxes.TrainCardsLeft);

    BuildPlot(nPlayers, avgNumDestCardsCompleted, destCardsSDs, finalAxes.DestinationCardsComplete);
    PlotSettings("Player Destination Cards Completed", xAxisLabel, "Cards Completed", finalAxes.DestinationCardsComplete);

    BuildPlot(nPlayers, avgTurnCount, turnSDs, finalAxes.Turns);
    PlotSettings("Players' Turns", xAxisLabel, "Turns Taken", finalAxes.Turns);

    BuildPlot(nPlayers, avgRoutesCount, routesSDs, finalAxes.RoutesClaimed);
    PlotSettings("Players' Routes Claimed", xAxisLabel, "Routes", finalAxes.RoutesClaimed);

    BuildPlot(nPlayers, avgAvgRouteLength, avgRouteLengthSDs, finalAxes.AvgRouteLength);
    PlotSettings("Players' Average Route Length", xAxisLabel, "Length", finalAxes.AvgRouteLength);

    BuildPlot(nPlayers, avgLongestRoute, longestRouteSDs, finalAxes.LongestRoute);
    PlotSettings("Players' Longest Route", xAxisLabel, "Length", finalAxes.LongestRoute);

    BuildPlot(nPlayers, avgNumTurnsAhead, numTurnsAheadSDs, finalAxes.NumTurnsAhead);
    PlotSettings("Players' # of Turns Ahead", xAxisLabel, "Turns", finalAxes.NumTurnsAhead);

    BuildPlot(nPlayers, avgNumTurnsAheadLong, numTurnsAheadLongSDs, finalAxes.NumTurnsAheadWithLongRoute);
    PlotSettings("Players' # of Turns Ahead w/ Long Route", xAxisLabel, "Turns", finalAxes.NumTurnsAheadWithLongRoute);
end

function BuildPlot(nPlayers, avg, sd, axes)
    bar(1:nPlayers,avg, 'Parent', axes);
    hold(axes, 'on');
    errorbar(avg, sd, 'LineStyle', 'none', 'Parent', axes);
    hold(axes, 'off');
end

function PlotSettings(inTitle, xLab, yLab, axes)
    title(inTitle, 'Parent', axes)
    xlabel(xLab, 'Parent', axes)
    ylabel(yLab, 'Parent', axes)
end

function playerConfIntTbl = dispConfidenceIntervals(nIters, playerNames, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs, avgAvgRouteLength, avgRouteLengthSDs, avgLongestRoute, longestRouteSDs, avgNumTurnsAhead, numTurnsAheadSDs, avgNumTurnsAheadLong, numTurnsAheadLongSDs)
    % if the number of iterations is greater than one, calculate the
    % confidence intervals for player metrics -- will only calculate
    % confidence intervals for simulations with at least 2 games.
    % Otherwise it will just assign 0
    varNames = {'Avg Score', 'Score LCL', 'Score UCL', 'Avg Trains Played', 'Trains LCL', 'Trains UCL', 'Avg Train Cards Left', 'Train Cards LCL', 'Train Cards UCL', 'Avg Dest Cards Completed', 'Dest Cards LCL', 'Dest Cards UCL', 'Avg Turns', 'Turns LCL', 'Turns UCL', 'Avg Routes', 'Routes LCL', 'Routes UCL', 'Avg Route Length', 'Route Length LCL', 'Route Length UCL', 'Avg Longest Route', 'Longest Route LCL', 'Longest Route UCL','Avg Turns Ahead', 'Turns Ahead LCL', 'Turns Ahead UCL', 'Avg Turns Ahead w/ Long Rte', 'Turns Ahead Long Rte LCL', 'Turns Ahead Long Rte UCL'};
    if nIters > 1
        alpha = 0.05;
        criticalVal = tinv(1-alpha/2,nIters-1);
        [scoreLCL, scoreUCL] = meanConfInterval(avgPlayerScores, scoreSDs, criticalVal, nIters, false);
        [trainsLCL, trainsUCL] = meanConfInterval(avgNumTrainsPlayed, trainSDs, criticalVal, nIters, true);
        [trainCardsLCL, trainCardsUCL] = meanConfInterval(avgNumTrainCardsLeft, trainCardSDs, criticalVal, nIters, true);
        [destCardsLCL, destCardsUCL] = meanConfInterval(avgNumDestCardsCompleted, destCardsSDs, criticalVal, nIters, true);
        [turnLCL, turnUCL] = meanConfInterval(avgTurnCount, turnSDs, criticalVal, nIters, true);
        [routeLCL, routeUCL] = meanConfInterval(avgRoutesCount, routesSDs, criticalVal, nIters, true);
        [routeLenLCL, routeLenUCL] = meanConfInterval(avgAvgRouteLength, avgRouteLengthSDs, criticalVal, nIters, true);
        [longRteLCL, longRteUCL] = meanConfInterval(avgLongestRoute, longestRouteSDs, criticalVal, nIters, true);
        [nTurnsAheadLCL, nTurnsAheadUCL] = meanConfInterval(avgNumTurnsAhead, numTurnsAheadSDs, criticalVal, nIters, true);
        [nTurnsAheadLongLCL, nTurnsAheadLongUCL] = meanConfInterval(avgNumTurnsAheadLong, numTurnsAheadLongSDs, criticalVal, nIters, true);

       playerConfIntTbl = table(avgPlayerScores', scoreLCL', scoreUCL', ...
            avgNumTrainsPlayed', trainsLCL', trainsUCL', ...
            avgNumTrainCardsLeft', trainCardsLCL', trainCardsUCL', ...
            avgNumDestCardsCompleted', destCardsLCL', destCardsUCL', ...
            avgTurnCount', turnLCL', turnUCL', ...
            avgRoutesCount', routeLCL', routeUCL', ...
            avgAvgRouteLength', routeLenLCL', routeLenUCL', ...
            avgLongestRoute', longRteLCL', longRteUCL', ...
            avgNumTurnsAhead', nTurnsAheadLCL', nTurnsAheadUCL', ...
            avgNumTurnsAheadLong', nTurnsAheadLongLCL', nTurnsAheadLongUCL', ...
            'RowNames', playerNames', 'VariableNames', varNames)
    else
        playerConfIntTbl = table(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 'VariableNames',varNames);
    end

end

function [lcl, ucl] = meanConfInterval(avg, sd, criticalVal, nIters, alwaysNonnegative)
        stdError = sd/sqrt(nIters);
        lcl = avg - criticalVal * stdError;
        ucl = avg + criticalVal * stdError;

        if (alwaysNonnegative == true)
            % For quantities that are always nonnegative, if the LCL
            % calculated is negative, set the LCL to 0
            lcl(lcl < 0) = 0;
        end
end


%% processWinRates functions: processWinRates, CalcWinRates, reportStatSignificanceWinRates
function summaryResults = processWinRates(nIters, playerNames, combinedSimResults, scoresCols, nPlayers, summaryResults)
    winRates = CalcWinRates(nIters, combinedSimResults, scoresCols, nPlayers);
    summaryResults.winRates = table(winRates, 'RowNames', playerNames);
    summaryResults.winRates

    % Statistical Significance Table
    summaryResults.winRatesStatResultsTbl = reportStatSignificanceWinRates(nPlayers, winRates, nIters);
    summaryResults.winRatesStatResultsTbl
end

function winRates = CalcWinRates(nIters, combinedSimResults, scoresCols, nPlayers)

    for p = 1:nPlayers
        wins = 0;
        for i = 1:nIters
            wins = wins + (max(combinedSimResults(i,scoresCols)) == combinedSimResults(i,p));
        end
    winRates(p,1) = wins/nIters;
    end
end

function winRatesStatResultTbl = reportStatSignificanceWinRates(nPlayers, winRates, nIters)

    % at 0.05 confidence level -- determine the chi-square critical value
    % and degrees of freedom
    signifLevel = 0.05;
    degFreedom = nPlayers - 1;
    criticalVal = chi2inv(1-signifLevel/2, degFreedom);

    % Test for statistical significance of win rate pairs
    pair = 0;
    for i = 1:nPlayers-1
        for j = i+1:nPlayers
            pair = pair + 1;
            playerA(pair,1) = i;
            playerB(pair,1) = j;
            pairDifference(pair,1) = abs(winRates(i) - winRates(j));

            % Calculate the critical range -- i.e., if difference of a
            % pair is greater than r (the critical range) for that pair,
            % then it is statistically significant
            % Source: https://www.itl.nist.gov/div898/handbook/prc/section4/prc464.htm
            criticalRange(pair,1) = sqrt(criticalVal)*sqrt((winRates(i)*(1 - winRates(i)) + winRates(j)*(1 - winRates(j))) / nIters);
            if pairDifference(pair,1) <= criticalRange(pair,1)
                isStatSignificant(pair,1) = "No";
            else
                isStatSignificant(pair,1) = "Yes";
            end
        end
    end

    winRatesStatResultTbl = table(playerA, playerB, pairDifference, criticalRange, isStatSignificant);
end


%% processCorrelation Stats functions: processCorrelationStats, buildCorrelationMatrix, dispCorrelationMatrix, and generateCorrelationTable
function summaryResults = processCorrelationStats(combinedSimResults, nPlayers, summaryResults, nIters)
    nMetrics = size(combinedSimResults,2) / nPlayers;
    X = buildCorrelationMatrix(combinedSimResults, nPlayers, nMetrics);
    dispCorrelationMatrix(X, nMetrics);

    %https://www.mathworks.com/help/matlab/ref/corrcoef.html
    % Correlation coefficient, p-value, and 95% confidence interval
    [R, p_value, RL, RU] = corrcoef(X);

    % Correlations between Key Metrics
    summaryResults.corrTbl = generateCorrelationTable(nIters, R, p_value, RL, RU, nMetrics);
end

function X = buildCorrelationMatrix(combinedSimResults, nPlayers, nMetrics)
    %https://www.mathworks.com/matlabcentral/answers/363444-how-can-i-add-xlabel-and-ylabel-to-the-individual-subplots-of-plotmatrix
    % Append the results of each player into a single column for each
    % metric, this is needed in order to represent the nMetrics
    % on a nMetrics x nMetrics scatterplot matrix
    % Metrics will be the columns

    % Correlation between key metrics may be used to gauge balance measures
    % -- how powerful is a given set of actions. We can see this by
    % comparing the correlation of final scores with various metrics such
    % as routes claimed and destinations completed
    X = [];
    for metric = 1:nMetrics
        buildColumn = [];
        for p = 1:nPlayers
            buildColumn = [buildColumn; combinedSimResults(:,(metric-1)*nPlayers+p)];
        end
        X = [X, buildColumn];
    end
end

function dispCorrelationMatrix(X, nMetrics)
    labels = {"Final Scores", "Trains Played", "Cards Left", "Dests \newline Completed", "Turns Taken", "Routes", "Avg Route \newline Length", "Longest Route", "Turns Ahead", 'Turns Ahead w/ \newline Long Route'};
    [~, axis] = plotmatrix(X,X);
    for i = 1:nMetrics
        ylabel(axis(i,1),labels(i), 'Rotation', 0, 'HorizontalAlignment', 'right');
        xlabel(axis(nMetrics,i),labels(i), 'Rotation', 30,'HorizontalAlignment', 'right');
    end
end

function corrTable = generateCorrelationTable(nIters, R, p_value, RL, RU, nMetrics)
    % Print results table, giving R, p-value, RL, and RU for each pair of
    % labels -- note: only need to use one half of the matrix that was
    % returned by corrcoef matrix

    corrVarNames = {'R', 'p-value', 'R LCL', 'R UCL', 'R^2', 'R^2 LCL', 'R^2 UCL', 'R^2 Range'};

    % Only report the correlations between key metrics if there were at
    % least two iterations run
    if nIters > 1
        tblRow = 1;
        for i = 1:nMetrics-1
            for j = i+1:nMetrics
                finalR(tblRow,1) = R(i,j);
                finalP(tblRow,1) = p_value(i,j);
                finalRL(tblRow,1) = RL(i,j);
                finalRU(tblRow,1) = RU(i,j);
                tblRow = tblRow + 1;
            end
        end

        rSquared = finalR.^2;
        rLCLSquared = finalRL.^2;
        rUCLSquared = finalRU.^2;
        rSquaredLCL =  min(rLCLSquared, rUCLSquared);
        rSquaredUCL =  max(rLCLSquared, rUCLSquared);
        rSquaredRng = rSquaredUCL - rSquaredLCL;

        varComboNames = {'scores and trains', 'scores and cards left', ...
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

        corrTable = table(finalR, finalP, finalRL, finalRU, rSquared, rSquaredLCL, rSquaredUCL, rSquaredRng,  ...
            'RowNames', varComboNames, 'VariableNames', corrVarNames)
    else
        corrTable = table(0, 0, 0, 0, 0, 0, 0, 0, ...
            'VariableNames', corrVarNames);
    end

end


%% calculateClosenessMetrics function
function summaryResults = calculateClosenessMetrics(nPlayers, playerNames, combinedSimResults, scoresCols, nIters, summaryResults)
    % "Close" Games are more fun than blowouts -- Calculate the closeness of
    % player's scores to one another each game. Check that:
    % A player does not consistently lose

    % Sort results of game in order to measure "Closeness" vs. Blowouts -- may
    % only need to measure difference between winner and runner-up
    [sortedElements, ~] = sort(combinedSimResults(:,scoresCols),2);
    differencesInOrderedScores = diff(sortedElements,1,2);
    if nIters > 1
        avgDiffPerRank = mean(differencesInOrderedScores,1); % average difference in score between each of the ranks
    else
        avgDiffPerRank = differencesInOrderedScores;
    end
    rank = "1 vs. 2";
    if nPlayers > 2
        for i = 2:nPlayers - 1
            rank = [rank; strcat(num2str(i)," vs. ",num2str(i+1))];
        end
    end
    summaryResults.avgDiffPerRank = table(rank, avgDiffPerRank', 'VariableNames', {'Rank', 'Avg Difference'});
    summaryResults.avgDiffPerRank

    % The number/percent of games in first vs. last place -- measure of Challenge
    % and balance
    numTimesLast = sum(combinedSimResults(:,scoresCols) == min(combinedSimResults(:,scoresCols),[],2),1);
    numTimesFirst = sum(combinedSimResults(:,scoresCols) == max(combinedSimResults(:,scoresCols),[],2),1);
    percentOfTimeLast = numTimesLast / nIters;
    percentOfTimeFirst = numTimesFirst / nIters;
    varNames = {'# Times 1st', '# Times Last', '% of Time 1st', '% of Time Last'};

    summaryResults.playerRankings = table(numTimesFirst', numTimesLast', ...
        percentOfTimeFirst', percentOfTimeLast', 'VariableNames', varNames, 'RowNames', playerNames);
    summaryResults.playerRankings

end


%% saveResultsToFile function
function saveResultsToFile(summaryResults, nPlayers, rngSeed, nIterations, nWorkers, players, ruleClass)

    % Save the parameter settings to the summaryResults struct (which we
    % will store in a .MAT file)
    summaryResults.settings.nPlayers = nPlayers;
    summaryResults.settings.nIterations = nIterations;
    summaryResults.settings.rngSeed = string(rngSeed);
    summaryResults.settings.nWorkers = nWorkers;

    summaryResults.settings.playerTypes ="";
    for i = 1:nPlayers
        summaryResults.settings.playerTypes(i) = class(players(i));
    end
    if nPlayers < 4
       summaryResults.settings.playerTypes(nPlayers+1:4) = "null";
    end
    summaryResults.settings.ruleSet = string(ruleClass);

    % Format the names of the players for the save file name
    classesStr = "";
    for i = 1:nPlayers
        playerClass = class(players(i));
        classesStr = strcat(classesStr, playerClass(1:end-6)); % Take "Player" out for conciseness
    end

    % Name the save file with the convention: time, seed, iterations,
    % player classes, number of workers, and rule class
    fileName = strcat(num2str(now), rngSeed, num2str(nIterations), classesStr, num2str(nWorkers), ruleClass,'.mat');

    save(fileName, '-struct', 'summaryResults');
    disp("The summary results struct of the simulation were saved to the file '" + fileName + "'.");

end