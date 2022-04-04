classdef DeviantPlayer < VariableUtilityPlayer
    %DEVIANTPLAYER Player that tries to ruin the strategies of other
    %players
    
    methods (Access = public)
        function obj = DeviantPlayer(playerNumber)
            obj@VariableUtilityPlayer(playerNumber, 0.1, 0, 1);
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

    end
end

