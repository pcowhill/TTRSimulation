function ProcessSimulationResults(allSimResults, nPlayers, finalAxes)
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
    avgRouteLengthCols=6*nPlayers+1:7*nPlayers;
    longestRouteCols=7*nPlayers+1:8*nPlayers;

    % Process, plot, and print statistics related to Averages and Standard
    % Deviations
    processAvgsAndSDs(nPlayers, nIters, allSimResults, scoresCols,numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols, avgRouteLengthCols, longestRouteCols, finalAxes)

    % Insert metrics about the statistical significance of the win
    % rates
    % Chi-Square Significance Test
    winRates = CalcWinRates(nIters, allSimResults, scoresCols, nPlayers)
    reportStatSignificanceWinRates(nPlayers, winRates, nIters);
end

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

function PlotSettings(inTitle, xLab, yLab, axes)
    title(inTitle, 'Parent', axes)
    xlabel(xLab, 'Parent', axes)
    ylabel(yLab, 'Parent', axes)
end


function BuildPlot(nPlayers, avg, sd, axes)
    bar(1:nPlayers,avg, 'Parent', axes);
    hold(axes, 'on');
    errorbar(avg, sd, 'LineStyle', 'none', 'Parent', axes);
    hold(axes, 'off');
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

function reportStatSignificanceWinRates(nPlayers, winRates,nIters)

    % at 0.05 confidence level -- determine the chi-square critical value
    % TODO: I do not have the Statistical Toolbox installed on my version of
    % Matlab, so I couldn't use the inverse chi-square to find these. I'll
    % see if there is a way I can get it, so I don't have to hardcode these
    % numbers in here.
    switch nPlayers
        case 2
            criticalVal = 3.84145882;
        case 3 
            criticalVal = 5.99146455;
        case 4
            criticalVal = 7.8147279;
    end

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
    
    winRatesStatResultTbl = table(playerA, playerB, pairDifference, criticalRange, isStatSignificant)   
end

function processAvgsAndSDs(nPlayers, nIters, allSimResults, scoresCols, numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols, avgRouteLengthCols, longestRouteCols, finalAxes)
    % Calculate means and standard deviations
    [avgPlayerScores, scoreSDs] = CalculatePlayerMeansSDs(allSimResults,scoresCols, nIters);
    [avgNumTrainsPlayed, trainSDs] = CalculatePlayerMeansSDs(allSimResults, numTrainsCols, nIters);
    [avgNumTrainCardsLeft, trainCardSDs] = CalculatePlayerMeansSDs(allSimResults, numTrainCardCols, nIters);
    [avgNumDestCardsCompleted, destCardsSDs] = CalculatePlayerMeansSDs(allSimResults, numDestCardCols, nIters);
    [avgTurnCount, turnSDs] = CalculatePlayerMeansSDs(allSimResults, turnsCols, nIters);
    [avgRoutesCount, routesSDs] = CalculatePlayerMeansSDs(allSimResults, routesCols, nIters);
    [avgAvgRouteLength, avgRouteLengthSDs] = CalculatePlayerMeansSDs(allSimResults, avgRouteLengthCols, nIters);
    [avgLongestRoute, longestRouteSDs] = CalculatePlayerMeansSDs(allSimResults, longestRouteCols, nIters);
        
    % We could replace these with the specific type of Player by taking the
    % class of each player in the players array. 
    playerNames = "Player " + [1:nPlayers];

    % Plots vs. Iteration/Trial #
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

    BuildPlot(nPlayers, avgAvgRouteLength, avgRouteLengthSDs, finalAxes.AvgRouteLength);
    PlotSettings("Players' Average Route Length", "Players", "Length", finalAxes.AvgRouteLength);

    BuildPlot(nPlayers, avgLongestRoute, longestRouteSDs, finalAxes.LongestRoute);
    PlotSettings("Players' Longest Route", "Players", "Length", finalAxes.LongestRoute);
   
    % Print Summary table
    varNames = {'Avg Score', 'SD Score', 'Avg Trains Played', 'SD Trains Played', 'Avg Train Cards Left', 'SD Train Cards Left', 'Avg Dest Cards Completed', 'SD Dest Cards Completed', 'Avg Turns', 'SD Turns', 'Avg Routes', 'SD Routes', 'Avg Route Length', 'Avg Route Length SD', 'Avg Longest Route', 'Longest Route SD'};
    playerStatsTbl = table(avgPlayerScores', scoreSDs',avgNumTrainsPlayed', ...
        trainSDs', avgNumTrainCardsLeft', trainCardSDs', ...
        avgNumDestCardsCompleted', destCardsSDs', avgTurnCount', turnSDs',...
        avgRoutesCount', routesSDs',avgAvgRouteLength', avgRouteLengthSDs', avgLongestRoute', longestRouteSDs', 'RowNames', playerNames, 'VariableNames', varNames)
end