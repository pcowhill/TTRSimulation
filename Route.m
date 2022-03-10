classdef Route
    % Route
    % Represents a unique connection between two cities on the board.  If
    % two cities are connected by multiple routes, each route should be its
    % own object.
    
    properties (SetAccess = immutable)
        name      % The primary name to identify the route
        id        % unique number given to this route
        locations % Array with the from and to locations
        color     % Color of the route on the board
        length    % Number of trains required to complete the route
    end
    
    methods
        function obj = Route(inFirstLocation, ...
                inSecondLocation, inColor, inLength)
            % Route Constructor
            % Creates a Route object and defines the properties decribing
            % the route as it appears on the board.

            obj.id = IntCounter.setget();

            % Patrick Note: Originally, the name was an input parameter,
            % but I am choosing to generate the name from the locations
            % instead.

            % Save the locations
            firstLocationType = string(class(inFirstLocation));
            secondLocationType = string(class(inSecondLocation));
            assert(firstLocationType == "Location", "Route requires " + ...
                "inFirstLocation to be of type 'Location'. '" + ...
                firstLocationType + "' was given.")
            assert(secondLocationType == "Location", "Route requires " + ...
                "inSecondLocation to be of type 'Location'. '" + ...
                secondLocationType + "' was given.")
            obj.locations = [inFirstLocation, inSecondLocation];

            % Save the name
            obj.name = inFirstLocation.string() + "-" + inSecondLocation.string();
   
            % Save the color
            colorType = string(class(inColor));
            assert(colorType == "Color", "Route requires inColor to " + ...
                "be of type 'Color'. '" + colorType + "' was given.")
            obj.color = inColor;

            % Save the length (as a double since that is a MATLAB default)
            lengthType = string(class(inLength));
            assert(lengthType == "double", "Route requires inLength " + ...
                "to be of type 'double'. '" + lengthType + "' was given")
            obj.length = inLength;
        end

        function isSame = isColor(obj,inColor)
            isSame = obj.color.isColor(inColor);
        end
    end
end

