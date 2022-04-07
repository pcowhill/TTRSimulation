classdef DummyPlayer < Player
    %Dummy Player class
    %   Player that plays routes as soon as their able to and only draws
    %   random cards


    methods (Access = public)
        function obj = DummyPlayer(playerNumber)
            obj@Player(playerNumber);
        end

        function [route, card, drawDestinationCards] = chooseAction(player, board, claimableRoutes, claimableRouteColors, drawableCards, canDrawDestinationCards)
            arguments
                player Player
                board Board
                claimableRoutes Route
                claimableRouteColors Color
                drawableCards TrainCard
                canDrawDestinationCards
            end
            if ~isempty(claimableRoutes)
                % claim longest claimable route
                [~, sortedIndices] = sort([claimableRoutes.length], 'descend');
                route = sortedIndices(1);
                card = 0;
                drawDestinationCards = false;
            else
                route = 0;
                % draw random cards
                card = length(drawableCards);
                drawDestinationCards = false;
            end
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end
            keptCardIndices = 1;
        end

        function initPlayerSpecific(player, startingHand, board, destinationsDeck, nStartingTrains)
            arguments
                player Player
                startingHand TrainCard
                board Board
                destinationsDeck DestinationsDeck
                nStartingTrains
            end
            % Intentionally does nothing.
        end
    end
end