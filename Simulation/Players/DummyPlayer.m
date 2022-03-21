classdef DummyPlayer < Player
    %Dummy Player class
    %   Player that plays routes as soon as their able to and only draws
    %   random cards


    methods (Access = public)
        function obj = DummyPlayer(playerNumber)
            obj@Player(playerNumber);
        end

        function [route, card, destination] = chooseAction(player, board, claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards)
            arguments
                player Player
                board Board
                claimableRoutes Route
                claimableRouteColors Color
                drawableCards TrainCard
                drawDestinationCards
            end
            if ~isempty(claimableRoutes)
                % claim longest claimable route
                [~, sortedIndices] = sort([claimableRoutes.length], 'descend');
                route = sortedIndices(1);
                card = 0;
                destination = 0;
            else
                route = 0;
                % draw random cards
                card = length(drawableCards);
                destination = 0;
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
    end
end