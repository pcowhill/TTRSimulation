classdef PlayerStub < Player
    methods(Access = public)
        function chosenActions = chooseAction(player, board, possibleActions)
            chosenActions = struct();
            chosenActions.route=0;
            chosenActions.card=0;
            chosenActions.drawDestinationCards=0;
            if ~isempty(possibleActions.claimableRoutes)
                chosenActions.route=1;
            elseif ~isempty(possibleActions.drawableCards)
                chosenActions.card=1;
            else
                chosenActions.drawDestinationCards=true;
            end
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            keptCardIndices = 1;
        end

        function initPlayerSpecific(player, startingHand, board, destinationsDeck, nStartingTrains)
        end

        function tf = canTakeAction(player, possibleActions)
            arguments
                player Player
                possibleActions struct
            end
            tf = (isempty(possibleActions.claimableRoutes) && ...
                  isempty(possibleActions.drawableCards) && ...
                  ~possibleActions.canDrawDestinationCards);
        end
    end
end