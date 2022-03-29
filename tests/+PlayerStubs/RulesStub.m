classdef RulesStub < Rules

    properties
        action = 0;
    end
    methods
        function initGameState(rules)

        end

        function [claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards] = ...
            getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, routesClaimed, cardsDrawn, drawnDestinations)
            drawableCards = TrainCard.empty;
            drawDestinationCards=0;
            [claimableRoutes, claimableRouteColors] = rules.getClaimableRoutes(player, board);  
            switch rules.action
                case 0
                    claimableRoutes = [Route(Location.Atlanta, Location.Charleston, Color.blue, 4)];
                    drawableCards = [];
                    drawDestinationCards=0;
                case 1
                    claimableRoutes = [];
                    drawableCards = [TrainCard(Color.blue)];
                    drawDestinationCards=0;
                case 2
                    claimableRoutes = [];
                    drawableCards = [];
                    drawDestinationCards=1;
                case 3
                    claimableRoutes = [];
                    drawableCards = [TrainCard(Color.multicolored)];
                    drawDestinationCards=0;
            end
        end

        function over =  isTurnOver(rules, claimableRoutes, drawableCards, drawDestinationCards, routesClaimed, cardsDrawn, destinations)
            over = ~isempty(routesClaimed) || ~isempty(cardsDrawn) || destinations;
        end

        function points = getRoutePoints(rules, route)
            points=5;
        end

        function updateGameState(rules, board, players, trainsDeck, destinationsDeck)

        end

        function over = isGameOver(rules)
            over = 0;
        end

        function updateEndgameScores(rules, board, players)
        end

    end

end