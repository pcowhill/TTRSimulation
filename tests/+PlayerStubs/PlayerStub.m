classdef PlayerStub < Player
    methods(Access = public)
        function [route, card, destination] = chooseAction(player, board, claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards)
            route=0;
            card=0;
            destination=0;
            if ~isempty(claimableRoutes)
                route=1;
            elseif ~isempty(drawableCards)
                card=1;
            else
                destination=1;
            end
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            keptCardIndices = 1;
        end

        function initPlayerSpecific(player, startingHand, board, destinationsDeck, nStartingTrains)
        end
    end
end