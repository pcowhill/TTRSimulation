function ProcessSimulationResults(allSimResults, nPlayers, finalAxes, saveResults, nIterations, rngSeed, nWorkers, players, ruleClass)
    summaryResults.allSimResults = allSimResults
    nIters = size(allSimResults,1);    
    
    % Calculate Average Scores, Number of Trains Played, Number of Train
    % Cards Left, Number of Destination Cards Completed, Number of Turns
    % per Player, and Number of Routes Claimed
    scoresCols = 1:nPlayers;
    numTrainsCols = nPlayers+1:2*nPlayers;
    numTrainCardCols = 2*nPlayers+1:3*nPlayers;
    numDestCardCols = 3*nPlayers+1:4*nPlayers;
    turnsCols = 4*nPlayers+1:5*nPlayers;
    routesCols = 5*nPlayers+1:6*nPlayers;

    % Process, plot, and print statistics related to Averages and Standard
    % Deviations
    summaryResults = processAvgsAndSDs(nPlayers, nIters, allSimResults, scoresCols,numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols, finalAxes);

    % Insert metrics about the statistical significance of the win
    % rates -- Chi-Square Significance Test
    summaryResults = processWinRates(nIters, allSimResults, scoresCols, nPlayers, summaryResults);
    
    % Print information about correlations between key statistics
    summaryResults = processCorrelationStats(allSimResults, nPlayers, summaryResults, nIters); 
   
    % Present a few other simple "closeness" measures
    summaryResults = calculateClosenessMetrics(allSimResults, scoresCols, nIters, summaryResults);

    % Save results if requested by the user
    if saveResults
        saveResultsToFile(summaryResults, nPlayers, rngSeed, nIterations, nWorkers, players, ruleClass);
    end

end

%% Calculate player means and standard deviations, which shall be used through the ProcessSimulationResults Matlab file
function [avgMeans, stdDevs] = CalculatePlayerMeansSDs(allSimResults, columns, nIters)
    % Calculate Average Scores, Number of Trains Played, Number of Cards
    % Left, and Number of Turns
    if nIters > 1
        avgMeans = mean(allSimResults(:,columns));
        stdDevs = std(allSimResults(:,columns));
    else % Just copy the actual values for the mean, and sd = 0
        avgMeans = allSimResults(:,columns);
        stdDevs = zeros(1,length(columns));
    end        
end


%% processAvgsAndSDs Functions: processAvgsAndSDs, plotPlayerStats, BuildPlot, PlotSettings, dispConfidenceIntervals, and meanConfInterval
function summaryResults = processAvgsAndSDs(nPlayers, nIters, allSimResults, scoresCols, numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols, finalAxes)
    % Calculate means and standard deviations
    [avgPlayerScores, scoreSDs] = CalculatePlayerMeansSDs(allSimResults,scoresCols, nIters);
    [avgNumTrainsPlayed, trainSDs] = CalculatePlayerMeansSDs(allSimResults, numTrainsCols, nIters);
    [avgNumTrainCardsLeft, trainCardSDs] = CalculatePlayerMeansSDs(allSimResults, numTrainCardCols, nIters);
    [avgNumDestCardsCompleted, destCardsSDs] = CalculatePlayerMeansSDs(allSimResults, numDestCardCols, nIters);
    [avgTurnCount, turnSDs] = CalculatePlayerMeansSDs(allSimResults, turnsCols, nIters);
    [avgRoutesCount, routesSDs] = CalculatePlayerMeansSDs(allSimResults, routesCols, nIters);
        
    % Plots Stats by Player
    plotPlayerStats(nPlayers, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs, finalAxes);
    
    % Print Summary table
    playerNames = "Player " + [1:nPlayers];
    varNames = {'Avg Score', 'SD Score', 'Avg Trains Played', 'SD Trains Played', 'Avg Train Cards Left', 'SD Train Cards Left', 'Avg Dest Cards Completed', 'SD Dest Cards Completed', 'Avg Turns', 'SD Turns', 'Avg Routes', 'SD Routes'};
    summaryResults.playerStatsTbl = table(avgPlayerScores', scoreSDs',avgNumTrainsPlayed', ...
        trainSDs', avgNumTrainCardsLeft', trainCardSDs', ...
        avgNumDestCardsCompleted', destCardsSDs', avgTurnCount', turnSDs',...
        avgRoutesCount', routesSDs','RowNames', playerNames, 'VariableNames', varNames)
    summaryResults.playerStatsTbl

    % Confidence Intervals on Averages
    summaryResults.playerConfIntTbl = dispConfidenceIntervals(nIters, playerNames, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs);
end

function plotPlayerStats(nPlayers, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs, finalAxes)
    BuildPlot(nPlayers, avgPlayerScores, scoreSDs, finalAxes.FinalScores);
    PlotSettings("Player Final Scores", "Players", "Final Score", finalAxes.FinalScores);

    BuildPlot(nPlayers, avgNumTrainsPlayed, trainSDs, finalAxes.TrainsPlayed);
    PlotSettings("Player Trains Played", "Players", "Trains Played", finalAxes.TrainsPlayed);

    BuildPlot(nPlayers, avgNumTrainCardsLeft, trainCardSDs, finalAxes.TrainCardsLeft);
    PlotSettings("Player Train Cards Left", "Players", "Cards Left", finalAxes.TrainCardsLeft);

    BuildPlot(nPlayers, avgNumDestCardsCompleted, destCardsSDs, finalAxes.DestinationCardsComplete);
    PlotSettings("Player Destination Cards Completed", "Players", "Cards Completed", finalAxes.DestinationCardsComplete);
    
    BuildPlot(nPlayers, avgTurnCount, turnSDs, finalAxes.Turns);
    PlotSettings("Players' Turns", "Players", "Turns Taken", finalAxes.Turns);
 
    BuildPlot(nPlayers, avgRoutesCount, routesSDs, finalAxes.RoutesClaimed);
    PlotSettings("Players' Routes Claimed", "Players", "Routes", finalAxes.RoutesClaimed);
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

function playerConfIntTbl = dispConfidenceIntervals(nIters, playerNames, avgPlayerScores, scoreSDs, avgNumTrainsPlayed, trainSDs, avgNumTrainCardsLeft, trainCardSDs, avgNumDestCardsCompleted, destCardsSDs, avgTurnCount, turnSDs, avgRoutesCount, routesSDs)
    % if the number of iterations is greater than one, calculate the
    % confidence intervals for player metrics -- will only calculate 
    % confidence intervals for simulations with at least 2 games. 
    % Otherwise it will just assign 0
    varNames2 = {'Avg Score', 'Score LCL', 'Score UCL', 'Avg Trains Played', 'Trains LCL', 'Trains UCL', 'Avg Train Cards Left', 'Train Cards LCL', 'Train Cards UCL', 'Avg Dest Cards Completed', 'Dest Cards LCL', 'Dest Cards UCL', 'Avg Turns', 'Turns LCL', 'Turns UCL', 'Avg Routes', 'Routes LCL', 'Routes UCL'};
    if nIters > 1
        alpha = 0.05;
        criticalVal = tinv(1-alpha/2,nIters-1);
        [scoreLCL, scoreUCL] = meanConfInterval(avgPlayerScores, scoreSDs, criticalVal, nIters, false);
        [trainsLCL, trainsUCL] = meanConfInterval(avgNumTrainsPlayed, trainSDs, criticalVal, nIters, true);
        [trainCardsLCL, trainCardsUCL] = meanConfInterval(avgNumTrainCardsLeft, trainCardSDs, criticalVal, nIters, true);
        [destCardsLCL, destCardsUCL] = meanConfInterval(avgNumDestCardsCompleted, destCardsSDs, criticalVal, nIters, true);
        [turnLCL, turnUCL] = meanConfInterval(avgTurnCount, turnSDs, criticalVal, nIters, true);
        [routeLCL, routeUCL] = meanConfInterval(avgRoutesCount, routesSDs, criticalVal, nIters, true);
    
        varNames2 = {'Avg Score', 'Score LCL', 'Score UCL', 'Avg Trains Played', 'Trains LCL', 'Trains UCL', 'Avg Train Cards Left', 'Train Cards LCL', 'Train Cards UCL', 'Avg Dest Cards Completed', 'Dest Cards LCL', 'Dest Cards UCL', 'Avg Turns', 'Turns LCL', 'Turns UCL', 'Avg Routes', 'Routes LCL', 'Routes UCL'};
       playerConfIntTbl = table(avgPlayerScores', scoreLCL', scoreUCL', ...
            avgNumTrainsPlayed', trainsLCL', trainsUCL', ...
            avgNumTrainCardsLeft', trainCardsLCL', trainCardsUCL', ...
            avgNumDestCardsCompleted', destCardsLCL', destCardsUCL', ...
            avgTurnCount', turnLCL', turnUCL', ...
            avgRoutesCount', routeLCL', routeUCL', ...
            'RowNames', playerNames', 'VariableNames', varNames2)
    else
        playerConfIntTbl = table(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 'VariableNames',varNames2);
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
function summaryResults = processWinRates(nIters, allSimResults, scoresCols, nPlayers, summaryResults)
    summaryResults.winRates = CalcWinRates(nIters, allSimResults, scoresCols, nPlayers);
    summaryResults.winRatesStatResultsTbl = reportStatSignificanceWinRates(nPlayers, summaryResults.winRates, nIters); 
end

function winRates = CalcWinRates(nIters, allSimResults, scoresCols, nPlayers)

    for p = 1:nPlayers
        wins = 0;
        for i = 1:nIters
            wins = wins + (max(allSimResults(i,scoresCols)) == allSimResults(i,p));
        end
    winRates(1,p) = wins/nIters;
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
            criticalRange(pair,1) = sqrt(criticalVal)*sqrt((winRates(i)*(1 - winRates(j)) + winRates(j)*(1 - winRates(j))) / nIters);
            if pairDifference(pair,1) <= criticalRange(pair,1)
                isStatSignificant(pair,1) = "No";
            else
                isStatSignificant(pair,1) = "Yes";
            end
        end
    end
    
    winRatesStatResultTbl = table(playerA, playerB, pairDifference, criticalRange, isStatSignificant)   
end


%% processCorrelation Stats functions: processCorrelationStats, buildCorrelationMatrix, dispCorrelationMatrix, and generateCorrelationTable
function summaryResults = processCorrelationStats(allSimResults, nPlayers, summaryResults, nIters)
    nMetrics = size(allSimResults,2) / nPlayers;
    X = buildCorrelationMatrix(allSimResults, nPlayers, nMetrics);
    dispCorrelationMatrix(X, nMetrics);

    %https://www.mathworks.com/help/matlab/ref/corrcoef.html
    % Correlation coefficient, p-value, and 95% confidence interval
    [R, p_value, RL, RU] = corrcoef(X);

    % Correlations between Key Metrics
    summaryResults.corrTbl = generateCorrelationTable(nIters, R, p_value, RL, RU, nMetrics);
end

function X = buildCorrelationMatrix(allSimResults, nPlayers, nMetrics)
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
            buildColumn = [buildColumn; allSimResults(:,(metric-1)*nPlayers+p)];
        end
        X = [X, buildColumn];
    end
end

function dispCorrelationMatrix(X, nMetrics)
    labels = ["Final Scores", "Trains Played", "Cards Left", "Dests Completed", "Turns Taken", "Routes"];
    [~, axis] = plotmatrix(X,X);
    for i = 1:nMetrics
        ylabel(axis(i,1),labels(i), 'Rotation', 0, 'HorizontalAlignment', 'right');
        xlabel(axis(nMetrics,i),labels(i), 'Rotation', 90,'HorizontalAlignment', 'right');
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
    
        varComboNames = {'scores/trains', 'scores/cards left', ...
            'scores/dests completed', 'scores/turns', 'scores/routes', ...
            'trains/cards left', 'trains/dests completed', 'trains/turns', ...
            'trains/routes', 'cards left/dests completed', 'cards/turns', ...
            'cards/routes', 'dests completed/turns', ...
            'dests completed/routes', 'turns/routes'};
    
        corrTable = table(finalR, finalP, finalRL, finalRU, rSquared, rSquaredLCL, rSquaredUCL, rSquaredRng,  ...
            'RowNames', varComboNames, 'VariableNames', corrVarNames) 
    else
        corrTable = table(0, 0, 0, 0, 0, 0, 0, 0, ...
            'VariableNames', corrVarNames);
    end

end


%% calculateClosenessMetrics function
function summaryResults = calculateClosenessMetrics(allSimResults, scoresCols, nIters, summaryResults)
    % "Close" Games are more fun than blowouts -- Calculate the closeness of
    % player's scores to one another each game. Check that:
    % A player does not consistently lose
    
    % Sort results of game in order to measure "Closeness" vs. Blowouts -- may
    % only need to measure difference between winner and runner-up
    [sortedElements, ~] = sort(allSimResults(:,scoresCols),2);
    differencesInOrderedScores = diff(sortedElements,1,2)
    if nIters > 1
        avgDiffPerRank = mean(differencesInOrderedScores,1) % average difference in score between each of the ranks
    else
        avgDiffPerRank = differencesInOrderedScores
    end
    
    % This may be redundant with the win rates metric; we may not need to know
    % the number of times in first vs. last place -- measure of Challenge
    numTimesLast = sum(allSimResults(:,scoresCols) == min(allSimResults(:,scoresCols),[],2),1)
    numTimesFirst = sum(allSimResults(:,scoresCols) == max(allSimResults(:,scoresCols),[],2),1)

    summaryResults.avgDiffPerRank = avgDiffPerRank; 
    summaryResults.numTimesLast = numTimesLast;
    summaryResults.numTimesFirst = numTimesFirst;
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