classdef DummyPlayer < Player
    %Dummy Player class
    %   Player that plays routes as soon as their able to and only draws
    %   random cards


    methods (Access = public)
        function obj = DummyPlayer(color, trainsDeck, destinationsDeck)
            arguments
                color Color
                trainsDeck TrainsDeck
                destinationsDeck DestinationsDeck
            end
            obj@Player(color, trainsDeck, destinationsDeck);
        end

        function [route, card, destination] = chooseActionImpl(player, board, claimableRoutes, drawableCards, drawDestinationCards)
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

        function keptCardIndices = chooseDestinationCardsImpl(player, board, destinationCards)
            keptCardIndices = 1;
        end
    end
end