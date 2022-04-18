classdef LongRoutePlayer < VariableUtilityPlayer
    %Long Route Player class
    %   Player that is just trying to claim long routes.


    methods (Access = public)
        function obj = LongRoutePlayer(playerNumber)
            obj@VariableUtilityPlayer(playerNumber, 1, 0, 0);
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            % choose smallest point values
            [~, sortedIndices] = sort([destinationCards.pointValue]);
            keptCardIndices=sortedIndices([1 2]);
        end

        function drawCards = shouldDrawDestinationCards(player,board)
            drawCards=false;
        end

        function getPotentialDiscount(player,board)
            playerTrains = Rules.getPlayerTrains(board, player.allPlayers, player.nStartingTrains);
            player.potentialDiscount=1-(min(playerTrains)/player.nStartingTrains-1)^4;
        end

    end
end