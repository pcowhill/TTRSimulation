classdef HybridPlayer < VariableUtilityPlayer
    %HybridPlayer class
    %   Player that tries to claim long routes and complete destination
    %   ticket cards.


    methods (Access = public)
        function obj = HybridPlayer(playerNumber)
            obj@VariableUtilityPlayer(playerNumber, 0.5, 0.5, 0);
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            % choose largest point value
            [~, sortedIndices] = sort([destinationCards.pointValue], 'descend');
            
            % if it's the beginning of the game, take 2 highest point cards
            if isempty(player.destinationCardsHand)
                keptCardIndices=sortedIndices(1:2);
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

        function getPotentialDiscount(player,board)
            playerTrains = Rules.getPlayerTrains(board, player.allPlayers, player.nStartingTrains);
            player.potentialDiscount=1-(min(playerTrains)/player.nStartingTrains-1)^6;
        end

    end
end