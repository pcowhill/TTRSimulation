classdef Color
    % Color
    % Represents a color for the various trains, players, cards, routes, etc.

    properties (SetAccess = immutable)
        name       % The primary name used to identify the object
        validNames % All valid references to the same color (primarily for capitalization)
    end

    methods
        function obj = Color(varargin)
            % Color Constructor
            % Creates a Color object and defines the name and any possible
            % valid names for the same color.

            % Ensure at least one name was given
            assert(nargin > 0, "Color must be created with at least one name.")

            obj.validNames = strings(nargin,1);

            % Ensure all inputs are strings or character arrays
            for iArg = 1:nargin
                argument = varargin{iArg};

                % Change character arrays into strings
                if string(class(argument)) == "char"
                    argument = string(argument);
                end

                assert(string(class(argument)) == "string", ...
                    "Color cannot be created with non-string name. '" + ...
                    string(class(argument)) + "' type was given.")

                % The first argument is the primary name
                if iArg == 1
                    obj.name = argument;
                end

                % All names given (including the primary name) populate the
                % valid names property
                obj.validNames(iArg) = argument;
            end
        end

        function isSame = isColor(obj,inColor)
            % isColor Method
            % Checks if argument inColor is the same color as this obj
            
            % Ensure exactly one color was given
            assert(nargin == 2, ...
                "isColor requires a color argument to compare against")

            % Compare based off type
            colorType = string(class(inColor));
            if colorType == "Color"
                isSame = any(ismember(inColor.validNames, obj.validNames));
                return
            elseif colorType == "string"
                isSame = ismember(inColor, obj.validNames);
                return
            elseif colorType == "char"
                isSame = ismember(string(inColor), obj.validNames);
                return
            else
                error("isColor requires the color argument to " + ...
                    "be of type 'Color', 'string', or 'char'. '" + ...
                    colorType + "' was given.")
            end
        end

        function isEqual = eq(aColor,bColor)
            % == Overload
            % Overloads equality operator with isColor

            % Ensure one of the arguments is a Color (This should never
            % trigger)
            assert(or(string(class(aColor))=="Color", string(class(bColor))=="Color"), ...
               "Color equality overload was called when neither argument is of type " + ...
               "Color. This should not have been triggered and was likely caused by " + ...
               "a bug in the software. This equality check was attempted with types '" + ...
               string(class(aColor)) + "' and '" + string(class(bColor)) + "'.")

            % Check for equality
            if string(class(aColor))=="Color"
                isEqual = aColor.isColor(bColor);
                return
            else
                isEqual = bColor.isColor(aColor);
            end
        end
    end
end