classdef Board < handle
    % Board
    % Represents the game board. There should be a single instance of this
    % class (for a single game), and it will keep track of the ownership of
    % the routes by the players. This object can be queried to receive
    % relevant information, evaluations, and calculations regarding the
    % state of the board.
    
    properties (SetAccess = private)
        initialRoutes Route % An array containing all of the route objects passed to the constructor
        routeGraph          % MATLAB undirected multigraph object containing dynamic information about the routes
        discardedTrains containers.Map % A map containing train pieces that have been discarded by players
    end
    
    methods
        function obj = Board(varargin)
            % Board Constructor
            % Creates a Board object from the list of Route objects passed
            % to it.

            obj.initialRoutes = [varargin{:}];

            for iArg = 1:nargin

                % Ensure the input argument is a route
                assert(string(class(varargin{iArg})) == "Route", ...
                    "Board cannot be created with non-Route argument. '" + ...
                    string(class(varargin{iArg})) + "' type was given.")
                
                % Ensure the route id does not match any existing route
                if 1 < sum(obj.initialRoutes == varargin{iArg})
                    error("The Route ID '" + string(varargin{iArg}.id) + "' " + ...
                    "is shared by more than one route sent to Board. " + ...
                    "The two routes are '" + varargin{iArg}.name + ...
                    "' and '" + obj.initialRoutes(varargin{iArg}.id).name + "'.")
                end

            end

            % Initialize route Graph
            obj.routeGraph = obj.initializeRouteGraph();

            % Initialize the discard pile for train pieces
            obj.discardedTrains = containers.Map();

        end

        function routeGraph = initializeRouteGraph(obj)
            % initializeRouteGraph method
            % creates and then returns a MATLAB undirected multigraph that
            % represents the cities and routes/connections between them
            % while also tracking information such as route owners and
            % length.
            routeGraph = graph;

            for route = obj.initialRoutes
                try % This fails if the location is already in the graph
                    routeGraph = routeGraph.addnode(route.locations(1).string());
                end
                try % This fails if the location is already in the graph
                    routeGraph = routeGraph.addnode(route.locations(2).string());
                end
                
                aTable = table(route.id, route.length, Color.gray, route.length);
                aTable.Properties.VariableNames = {'id', 'Length', 'Owner', 'Weight'};
                routeGraph = routeGraph.addedge( ...
                    route.locations(1).string(), ...
                    route.locations(2).string(), ...
                    aTable);
            end
        end

        function init(board)
            % init method
            % Sets up the existing Board object for a new game.
            board.routeGraph = board.initializeRouteGraph();
            board.discardedTrains = containers.Map();
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

            % Return if it is owned
            edgeIndex = find(obj.routeGraph.Edges.('id') == route.id);
            
            tf = ~(Color.gray == obj.routeGraph.Edges.('Owner')(edgeIndex)); %#ok<FNDSB> 
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
            assert(any(obj.initialRoutes == route), "The ID of the given " + ...
                "route does not match with any existing route on the board. " + ...
                "The given route ID is '" + string(route.id) + "' and the " + ...
                "given route's name is '" + route.name + "'.")

            % Return the color of the owner or gray if there is no owner
            edgeIndex = find(obj.routeGraph.Edges.('id') == route.id);

            color = obj.routeGraph.Edges.('Owner')(edgeIndex); %#ok<FNDSB> 
            
        end

        function claim(obj, route, color)
            % claim method
            % Sets the current owner of a route to the given color
            % This does NOT check to see if the player has enough plastic
            % trains to complete the route.
            % This DOES overwrite the current owner if there is one.
            
            arguments
                obj Board
                route Route
                color Color
            end

            % Set the current owner of the route to the player color
            edgeIndex = find(obj.routeGraph.Edges.('id') == route.id);

            obj.routeGraph.Edges.('Owner')(edgeIndex) = color; %#ok<FNDSB>
        end
        
        function block(obj, route)
            % block method
            % Sets the current over of a route to unknown which signifies
            % that the route is not owned by any of the player, and nor is
            % it available to be claimed (since it is not gray).
            % This DOES overwrite the current owner if there is one.

            obj.claim(route, Color.unknown);
        end

        function discardTrain(board, color, amount)
            arguments
                board Board
                color Color
                amount {mustBeInteger}
            end

            if isKey(board.discardedTrains, color.string)
                board.discardedTrains(color.string) = board.discardedTrains(color.string) + amount;
            else
                board.discardedTrains(color.string) = amount;
            end
        end

        function obj = resetRouteOwners(obj)
            % resetRouteOwners method
            % Resets the ownership map
            obj.routeGraph = obj.initializeRouteGraph();
        end

        function numTrains = getNumOfTrains(board, color)
            %getNumOfTrains Get the number of trains on the board of the
            %given color

            numTrains = sum(board.routeGraph.Edges.Length(board.routeGraph.Edges.Owner==color));

            if isKey(board.discardedTrains, color.string)
                numTrains = numTrains + board.discardedTrains(color.string);
            end
        end

        function unclaimedRoutes = getUnclaimedRoutes(board)
            unclaimedEdges = board.routeGraph.Edges.Owner==Color.gray;
            routeIds = board.routeGraph.Edges.id(unclaimedEdges);
            [~,cols] = find(routeIds==[board.initialRoutes.id]);
            unclaimedRoutes = board.initialRoutes(cols);
        end

        function claimedRoutes = getClaimedRoutes(board)
            arguments
                board Board
            end
            claimedEdges = board.routeGraph.Edges.Owner~=Color.gray;
            routeIds = board.routeGraph.Edges.id(claimedEdges);
            [~, cols] = find(routeIds==[board.initialRoutes.id]);
            claimedRoutes = board.initialRoutes(cols);
        end
    end
end

