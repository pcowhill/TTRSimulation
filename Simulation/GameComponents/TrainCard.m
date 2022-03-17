classdef TrainCard
% TrainCard
% This type of card has a color and is used by the Player throughout the
% game to claim routes of the same color, or in the case of the locomotive,
% claim routes of any color.

    properties (SetAccess = immutable)
        color Color % the Color of the train card
    end

    methods
        function obj = TrainCard(inColor)
            % TrainCard Constructor
            % Creates a TrainCard object and sets its color
            arguments
                inColor Color
            end
    
            % Assign the color
            obj.color = inColor;            
        end
    end
end
