classdef MoreActionsRules < DefaultRules
    %MoreActionsRules
    %   Allows more player actions per turn

    methods
        function possibleActions = ...
                getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, takenActions)
            arguments
                rules Rules
                player Player
                board Board
                trainsDeck TrainsDeck
                destinationsDeck DestinationsDeck
                takenActions struct
            end

            possibleActions = struct();

            if rules.isTurnOver(possibleActions, takenActions)
                possibleActions.claimableRoutes = Route.empty;
                possibleActions.claimableRouteColors = Color.empty;
                possibleActions.drawableCards = TrainCard.empty;
                possibleActions.canDrawDestinationCards = false;
            else
                possibleActions.drawableCards = TrainCard.empty;
                if trainsDeck.drawable()
                    possibleActions.drawableCards = [trainsDeck.getFaceUpCards() TrainCard(Color.unknown)];
                end
                possibleActions.canDrawDestinationCards=false;
                if destinationsDeck.getNumCardsLeft() > 0 && isempty(takenActions.routesClaimed) && isempty(takenActions.cardsDrawn)
                    possibleActions.canDrawDestinationCards = true;                
                end
                [possibleActions.claimableRoutes, possibleActions.claimableRouteColors] = rules.getClaimableRoutes(player, board);
            end
        end

        function over =  isTurnOver(rules, possibleActions, takenActions)
            % if the player drew destination cards or performed three other
            % actions, the turn is over
            over = false;
            if length(takenActions.routesClaimed) + length(takenActions.cardsDrawn) > 2 || takenActions.destinationsDrawn
                over = true;
            end
        end
    end
end