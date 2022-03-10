classdef Board
    % Board
    % Represents the game board. There should be a single instance of this
    % class (for a single game), and it will keep track of the ownership of
    % the routes by the players. This object can be queried to receive
    % relevant information, evaluations, and calculations regarding the
    % state of the board.
    
    properties (SetAccess = private)
        locationsMap % Map from location name ('Atlanta') to location object (Location.Atlanta) that contains all locations on the board
        routesMap    % Map from route id (1) to route object (ATLANTA_TO_CHARLESTON) that contains every route on the board
        ownershipMap % Map from route id (1) to color object (GREEN) which is the color of the owner of the route.  Unowned routes are not contained in this map.
    end
    
    methods
        function obj = Board(varargin)
            % Board Constructor
            % Creates a Board object from the list of Route objects.
            
            % Initialize the maps
            obj.routesMap = containers.Map('KeyType','double','ValueType','any');
            obj.locationsMap = containers.Map('KeyType','char','ValueType','any');
            obj.ownershipMap = containers.Map('KeyType','double','ValueType','any');

            for iArg = 1:nargin

                % Ensure the input argument is a route
                assert(string(class(varargin{iArg})) == "Route", ...
                    "Board cannot be created with non-Route argument. '" + ...
                    string(class(varargin{iArg})) + "' type was given.")
                
                % Ensure the route id does not match any existing route
                if isKey(obj.routesMap,varargin{iArg}.id)
                    error("The Route ID '" + string(varargin{iArg}.id) + "' " + ...
                    "is shared by more than one route sent to Board. " + ...
                    "The two routes are '" + varargin{iArg}.name + ...
                    "' and '" + obj.routesMap(varargin{iArg}.id).name + "'.")
                end
                
                % Add the new route to the routesMap
                obj.routesMap(varargin{iArg}.id) = varargin{iArg};

                % Extract the Locations from the route
                for location = varargin{iArg}.locations
                    % Check if the location is already in the locations map
                    if ~isKey(obj.locationsMap, char(location.string()))
                        obj.locationsMap(char(location.string())) = location;
                    end
                end
            end
        end

        function tf = isOwned(obj, route)
            % isOwned method
            % Returns whether or not a specific route is owned by any
            % player

            % Ensure an argument was passed
            assert(nargin == 2, "No route was given to find the owner of.")

            % Ensure the argument is a route
            assert(string(class(route)) == "Route", "Board method isOwned " + ...
                "requires an argument of type 'Route'. '" + ...
                string(class(route)) + "' was given.")

            tf = isKey(obj.ownershipMap, route.id);
        end

        function color = owner(obj, route)
            % owner method
            % Returns the current owner of the route

            % Ensure an argument was passed
            assert(nargin == 2, "No route was given to find the owner of.")

            % Ensure the argument is a route
            assert(string(class(route)) == "Route", "Board method owner " + ...
                "requires an argument of type 'Route'. '" + ...
                string(class(route)) + "' was given.")

            % Ensure the route exists in the routeMap
            assert(isKey(obj.routesMap, route.id), "The ID of the given " + ...
                "route does not match with any existing route on the board. " + ...
                "The given route ID is '" + string(route.id) + "' and the " + ...
                "given route's name is '" + route.name + "'.")

            % Return the color of the owner or gray if there is no owner
            if isKey(obj.ownershipMap, route.id)
                color = obj.ownershipMap(route.id);
                return
            else
                color = Color.gray;
            end
        end

        function claim(obj, route, color)
            % claim method
            % Sets the current owner of a route to the given color
            % This does NOT check to see if the player has enough plastic
            % trains to complete the route.
            % This DOES overwrite the current owner if there is one.

            % Ensure the correct number of arguments were passed
            assert(nargin == 3, "Insufficient number of arguments " + ...
                "for claiming a route. Both a 'Route' type and " + ...
                "'Color' type is required.")

            % Ensure the route is of Route type
            assert(string(class(route)) == "Route", "Board method claim " + ...
                "requires an argument of type 'Route'. '" + ...
                string(class(route)) + "' was given.")

            % Ensure the color is of Color type
            assert(string(class(color)) == "Color", "Board method claim " + ...
                "requires an argument of type 'Color'. '" + ...
                string(class(route)) + "' was given.")

            % Set the current owner of the route to the player color
            obj.ownershipMap(route.id) = color;
        end

        function obj = resetRouteOwners(obj)
            % resetRouteOwners method
            % Resets the ownership map
            obj.ownershipMap = containers.Map('KeyType','double','ValueType','any');
        end
    end
end

