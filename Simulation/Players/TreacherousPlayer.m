classdef TreacherousPlayer < Player
    %Treacherous Player class
    %   Utilizes the Treacherous Ruleset

    methods (Access = public)
        function obj = TreacherousPlayer(playerNumber)
            obj@Player(playerNumber);
        end

        function chosenActions = chooseAction(player, board, possibleActions)
            arguments
                player Player
                board Board
                possibleActions struct
            end

            chosenActions = struct();

            if (isfield(possibleActions, 'canSacrificeTrain') && possibleActions.canSacrificeTrain)
                % Always sacrifice a train for another card
                chosenActions.sacrificeTrain = true;
            end

            if ~isempty(possibleActions.claimableRoutes)
                % claim longest claimable route
                [~, sortedIndices] = sort([possibleActions.claimableRoutes.length], 'descend');
                chosenActions.route = sortedIndices(1);
                chosenActions.card = 0;
                chosenActions.drawDestinationCards = false;
            else
                chosenActions.route = 0;
                % draw random cards
                chosenActions.card = length(possibleActions.drawableCards);
                chosenActions.drawDestinationCards = false;
            end
        end

        function tf = canTakeAction(player, possibleActions)
            arguments
                player Player
                possibleActions struct
            end
            tf = (isempty(possibleActions.claimableRoutes) && ...
                  isempty(possibleActions.drawableCards) && ...
                  ~possibleActions.canDrawDestinationCards) || ...
                  (isfield(possibleActions, 'canSacrificeTrain') && possibleActions.canSacrificeTrain);
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            keptCardIndices = 1;
        end
    end
end