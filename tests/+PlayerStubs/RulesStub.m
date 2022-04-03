classdef RulesStub < Rules

    properties
        action = 0;
    end
    methods
        function initGameState(rules)

        end

        function possibleActions = ...
            getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, takenActions)
            possibleActions.drawableCards = TrainCard.empty;
            possibleActions.canDrawDestinationCards=false;
            [possibleActions.claimableRoutes, possibleActions.claimableRouteColors] = rules.getClaimableRoutes(player, board);  
            switch rules.action
                case 0
                    possibleActions.claimableRoutes = [Route(Location.Atlanta, Location.Charleston, Color.blue, 4)];
                    possibleActions.drawableCards = [];
                    possibleActions.canDrawDestinationCards=false;
                case 1
                    possibleActions.claimableRoutes = [];
                    possibleActions.drawableCards = [TrainCard(Color.blue)];
                    possibleActions.canDrawDestinationCards=false;
                case 2
                    possibleActions.claimableRoutes = [];
                    possibleActions.drawableCards = [];
                    possibleActions.canDrawDestinationCards=true;
                case 3
                    possibleActions.claimableRoutes = [];
                    possibleActions.drawableCards = [TrainCard(Color.multicolored)];
                    possibleActions.canDrawDestinationCards=false;
            end
        end

        function over =  isTurnOver(rules, possibleActions, takenActions)
            over = ~isempty(takenActions.routesClaimed) || ~isempty(takenActions.cardsDrawn) || takenActions.destinationsDrawn;
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