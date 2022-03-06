classdef Location
    % Location
    % Represents a city on the board and destination ticket cards
    
    properties (SetAccess = immutable)
        name       % The primary name used to identify the city
        validNames % All valid references to the same city
    end
    
    methods
        function obj = Location(varargin)
            % Location Constructor
            % Creates a Location object and defines thename and any
            % possible valid names for the same city.

            % Ensure at least one name was given
            assert(nargin > 0, "Location must be created with at least one name.")

            obj.validNames = strings(nargin,1);

            % Ensure all inputs are strings or character arrays
            for iArg = 1:nargin
                argument = varargin{iArg};

                % Change character arrays into strings
                if string(class(argument)) == "char"
                    argument = string(argument);
                end

                assert(string(class(argument)) == "string", ...
                    "Location cannot be created with non-string name. '" + ...
                    string(class(argument)) + ". type was given.")

                % The first argument is the primary name
                if iArg == 1
                    obj.name = argument;
                end

                % All names given (including the primary name) populate the
                % valid names property
                obj.validNames(iArg) = argument;
            end
        end

        function isSame = isLocation(obj, inLocation)
            % isLocation Method
            % Checks if argument inLocation is the same location as this obj
            
            % Ensure exactly one location was given
            assert(nargin == 2, ...
                "isLocation requires a location argument to compare against")

            % Compare based off type
            locationType = string(class(inLocation));
            if locationType == "Location"
                isSame = any(ismember(inLocation.validNames, obj.validNames));
                return
            elseif locationType == "string"
                isSame = ismember(inLocation, obj.validNames);
                return
            elseif locationType == "char"
                isSame = ismember(string(inLocation), obj.validNames);
                return
            else
                error("isLocation requires the location argument to " + ...
                    "be of type 'Location', 'string', or 'char'. '" + ...
                    locationType + "' was given.")
            end
        end

        function isEqual = eq(aLocation,bLocation)
            % == Overload
            % Overloads equality operator with isLocation

            % Ensure one of the arguments is a Location (This should never
            % trigger)
            assert(or(string(class(aLocation))=="Location", string(class(bLocation))=="Location"), ...
               "Location equality overload was called when neither argument is of type " + ...
               "Location. This should not have been triggered and was likely caused by " + ...
               "a bug in the software. This equality check was attempted with types '" + ...
               string(class(aLocation)) + "' and '" + string(class(bLocation)) + "'.")

            % Check for equality
            if string(class(aLocation))=="Location"
                isEqual = aLocation.isLocation(bLocation);
                return
            else
                isEqual = bLocation.isLocation(aLocation);
            end
        end
    end
end

