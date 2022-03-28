classdef LongRoutePlayer < VariableUtilityPlayer
    %Long Route Player class
    %   Player that is just trying to claim long routes.


    methods (Access = public)
        function obj = LongRoutePlayer(playerNumber, lengthWeight, longestRouteWeight, destinationTicketWeight)
            obj@VariableUtilityPlayer(playerNumber, lengthWeight, longestRouteWeight, destinationTicketWeight);
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            % choose smallest point value
            [~, sortedIndices] = sort([destinationCards.pointValue]);
            keptCardIndices=sortedIndices(1);
        end

        function drawCards = shouldDrawDestinationCards(player,board)
            drawCards=0;
        end

    end
end