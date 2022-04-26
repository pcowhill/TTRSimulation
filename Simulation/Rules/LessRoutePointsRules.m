classdef LessRoutePointsRules < DefaultRules
    %LessRotuePointsRules
    %   Awards less points for claimed routes

    methods
        function points = getRoutePoints(rules, route)
            %getRoutePoints Return the number of victory points the given
            %route is worth
            if route.length == 1
                points = 1;
            elseif route.length == 2
                points = 2;
            elseif route.length == 3
                points = 3;
            elseif route.length == 4
                points = 5;
            elseif route.length == 5
                points = 7;
            else
                points = 10;
            end
        end
    end
end