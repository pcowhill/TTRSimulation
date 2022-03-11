classdef TrainCard
% TrainCard
% This type of card has a color and is used by the Player throughout the
% game to claim routes of the same color, or in the case of the locomotive,
% claim routes of any color.

    properties (SetAccess = immutable)
        color % the Color of the train card
    end
    methods
        function obj = TrainCard(inColor)
            % TrainCard Constructor
            % Creates a TrainCard object and sets its color

            % Check that for exactly one argument that is a member of the Color enumeration class
            assert(and(nargin == 1, string(class(inFirstLocation)) == "Color"),  "The TrainCard constructor must have exactly " + ...
                "one input argument that is a member of the Color enumeration class.")
            
            % Assign the color
            obj.color = inColor;            
        end
    end
end