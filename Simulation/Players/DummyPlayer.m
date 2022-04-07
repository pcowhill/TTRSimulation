classdef DummyPlayer < Player
    %Dummy Player class
    %   Player that plays routes as soon as their able to and only draws
    %   random cards


    methods (Access = public)
        function obj = DummyPlayer(playerNumber)
            obj@Player(playerNumber);
        end

        function chosenActions = chooseAction(player, board, possibleActions)
            arguments
                player Player
                board Board
                possibleActions struct
            end

            chosenActions = struct();

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

        function tf = cannotTakeAction(player, possibleActions)
            arguments
                player Player
                possibleActions struct
            end
            tf = (isempty(possibleActions.claimableRoutes) && ...
                  isempty(possibleActions.drawableCards) && ...
                  ~possibleActions.canDrawDestinationCards);
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