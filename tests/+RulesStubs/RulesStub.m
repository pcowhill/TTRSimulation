classdef RulesStub < Rules

    methods
        function initGameState(rules)

        end

        function [claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards] = ...
            getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, routesClaimed, cardsDrawn, drawnDestinations)
            drawableCards = TrainCard.empty;
            drawDestinationCards=0;
            [claimableRoutes, claimableRouteColors] = rules.getClaimableRoutes(player, board);               
        end

        function over =  isTurnOver(rules, claimableRoutes, drawableCards, drawDestinationCards, route, card, destinations)
            over = false;
        end

        function points = getRoutePoints(rules, route)
            points=0;
        end

        function updateGameState(rules, board, players, trainsDeck, destinationsDeck)

        end

        function over = isGameOver(rules)
            over = 0;
        end

        function updateEndgameScores(rules, board, players)
        end

        function ticketsCompleted=getTicketsCompletedTest(rules,board,player)
            ticketsCompleted=getTicketsCompleted(rules,board,player);
        end

        function longestRouteLengths=getLongestRouteTest(rules,board,players)
            longestRouteLengths=rules.getLongestRoute(board, players);
        end
    end
end