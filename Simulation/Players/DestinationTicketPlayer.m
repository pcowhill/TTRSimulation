classdef DestinationTicketPlayer < VariableUtilityPlayer
    %Long Route Player class
    %   Player that is just trying to claim long routes.


    methods (Access = public)
        function obj = DestinationTicketPlayer(playerNumber)
            obj@VariableUtilityPlayer(playerNumber, 0.1, 1);
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            % choose largest point value
            [~, sortedIndices] = sort([destinationCards.pointValue], 'descend');
            
            % if it's the beginning of the game, take all cards
            if isempty(player.destinationCardsHand)
                keptCardIndices=sortedIndices;
            else
                % keep highest point value
                keptCardIndices=sortedIndices(1);
            end
            
        end

        function drawCards = shouldDrawDestinationCards(player,board)
            if all(player.destinationsCompleted) && player.potentialDiscount >= 0.8
                drawCards = true;
            else
                drawCards=false;
            end
        end

    end
end