classdef DestinationTicketPlayer < VariableUtilityPlayer
    %Long Route Player class
    %   Player that is just trying to claim long routes.


    methods (Access = public)
        function obj = DestinationTicketPlayer(playerNumber, lengthWeight, longestRouteWeight, destinationTicketWeight)
            obj@VariableUtilityPlayer(playerNumber, lengthWeight, longestRouteWeight, destinationTicketWeight);
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            % choose largest point value
            [~, sortedIndices] = sort([destinationCards.pointValue], 'descend');
            keptCardIndices=sortedIndices(1);
        end

        function drawCards = shouldDrawDestinationCards(player,board)
            if all(player.destinationsCompleted)
                drawCards = 1;
            else
                drawCards=0;
            end
        end

    end
end