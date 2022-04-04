function ProcessSimulationResults(allSimResults, nPlayers)
    nIters = size(allSimResults,1);    
    
    % Calculate Average Scores, Number of Trains Left, Number of Cards
    % Left, and Number of Turns per Player
    scoresCols = 1:nPlayers;
    numTrainsCols = nPlayers+1:2*nPlayers;
    numTrainCardCols = 2*nPlayers+1:3*nPlayers;
    numDestCardCols = 3*nPlayers+1:4*nPlayers;
    turnsCols = 4*nPlayers+1:5*nPlayers;
    routesCols = 5*nPlayers+1:6*nPlayers;

    % Process, plot, and print statistics related to Averages and Standard
    % Deviations
    processAvgsAndSDs(nPlayers, nIters, allSimResults, scoresCols,numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols)

    % Insert metrics about the statistical significance of the win
    % rates
    % Chi-Square Significance Test
    winRates = CalcWinRates(nIters, allSimResults, scoresCols, nPlayers);
    reportStatSignificanceWinRates(nPlayers, winRates, nIters);
end

function [avgMeans, stdDevs] = CalculatePlayerMeansSDs(allSimResults, columns)
    % Calculate Average Scores, Number of Trains Left, Number of Cards
    % Left, and Number of Turns
    avgMeans = mean(allSimResults(:,columns));
    stdDevs = std(allSimResults(:,columns));
end

function BuildPlot(nPlayers, allSimResults, iters, columns, plotNum, avg, sd)
    for p = 1:nPlayers
        subplot(2,3,plotNum)
        plot(iters, allSimResults(:,columns(p)));
        hold on;

        
        txt = "";
        for p = 1:nPlayers
    
            txt = strcat('\rightarrow Player',' ', num2str(p),'-- Avg: ',num2str(avg(p)),', SD: ',num2str(sd(p)));
            text(0,avg(p),txt)
            hold on;
        end
        text(0,0,txt)
    end
end

function PlotSettings(inTitle, xLab, yLab, inLegend)
    title(inTitle)
    xlabel(xLab)
    ylabel(yLab)
    legend(inLegend)
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
            criticalRange(pair,1) = sqrt(criticalVal)*sqrt((winRates(i)*(1 - winRates(j)) + winRates(j)*(1 - winRates(j))) / nIters);
            if pairDifference(pair,1) < criticalRange(pair,1)
                isStatSignificant(pair,1) = "No";
            else
                isStatSignificant(pair,1) = "Yes";
            end
        end
    end
    
    winRatesStatResultTbl = table(playerA, playerB, pairDifference, criticalRange, isStatSignificant)   
end

function processAvgsAndSDs(nPlayers, nIters, allSimResults, scoresCols, numTrainsCols, numTrainCardCols, numDestCardCols, turnsCols, routesCols)
    % Calculate means and standard deviations
    [avgPlayerScores, scoreSDs] = CalculatePlayerMeansSDs(allSimResults,scoresCols);
    [avgNumTrainsLeft, trainSDs] = CalculatePlayerMeansSDs(allSimResults, numTrainsCols);
    [avgNumTrainCardsLeft, trainCardSDs] = CalculatePlayerMeansSDs(allSimResults, numTrainCardCols);
    [avgNumDestCardsLeft, destCardsSDs] = CalculatePlayerMeansSDs(allSimResults, numDestCardCols);
    [avgTurnCount, turnSDs] = CalculatePlayerMeansSDs(allSimResults, turnsCols);
    [avgRoutesCount, routesSDs] = CalculatePlayerMeansSDs(allSimResults, routesCols);
        
    % We could replace these with the specific type of Player by taking the
    % class of each player in the players array. 
    playerNames = "Player " + [1:nPlayers];

    % Plots vs. Iteration/Trial #
    iters = 1:nIters;
    figure(); % Open a separate figure to display the summary plots
    BuildPlot(nPlayers, allSimResults, iters, scoresCols, 1, avgPlayerScores, scoreSDs)
    PlotSettings("Player Final Scores", "Iterations", "Final Score", playerNames)

    BuildPlot(nPlayers, allSimResults, iters, numTrainsCols, 2, avgNumTrainsLeft, trainSDs)
    PlotSettings("Player Trains Left", "Iterations", "Trains Left", playerNames)

    BuildPlot(nPlayers, allSimResults, iters, numTrainCardCols, 3, avgNumTrainCardsLeft, trainCardSDs)
    PlotSettings("Player Train Cards Left", "Iterations", "Cards Left", playerNames)

    BuildPlot(nPlayers, allSimResults, iters, numDestCardCols, 4, avgNumDestCardsLeft, destCardsSDs)    
    PlotSettings("Player Destination Cards Left", "Iterations", "Cards Left", playerNames)
    
    BuildPlot(nPlayers, allSimResults, iters, turnsCols, 5, avgTurnCount, turnSDs)    
    PlotSettings("Players' Turns", "Iterations", "Turns Taken", playerNames)
 
    BuildPlot(nPlayers, allSimResults, iters, routesCols, 6, avgRoutesCount, routesSDs)    
    PlotSettings("Players' Routes Claimed", "Iterations", "Routes", playerNames)
   
    % Print Summary table
    varNames = {'Avg Score', 'SD Score', 'Avg Trains Left', 'SD Trains Left', 'Avg Train Cards Left', 'SD Train Cards Left', 'Avg Dest Cards Left', 'SD Dest Cards Left', 'Avg Turns', 'SD Turns', 'Avg Routes', 'SD Routes'};
    playerStatsTbl = table(avgPlayerScores', scoreSDs',avgNumTrainsLeft', ...
        trainSDs', avgNumTrainCardsLeft', trainCardSDs', ...
        avgNumDestCardsLeft', destCardsSDs', avgTurnCount', turnSDs',...
        avgRoutesCount', routesSDs','RowNames', playerNames, 'VariableNames', varNames)
end