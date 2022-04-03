classdef BoardTest < matlab.unittest.TestCase
    % BoardTest
    % Tests the capabilities of the Board class to ensure it functions as
    % intended.
    
    properties
        theBoard % The board that the tests are run on.
    end
    
    methods(TestMethodSetup)
        function createBoard(obj)
            BaseBoard.initializeBoard;
            obj.theBoard = BOARD;
        end
    end

    methods(TestMethodTeardown)
    end

    methods(Test)
        function resetRouteOwnersWorks(obj)
            % resetRouteOwnersWorks
            % Ensures reseting the owners of Board via init works properly

            % Add color and route names
            BaseBoard.initializeRoutes;
            initializeColors;

            % Reset the ownership map
            obj.theBoard.init();

            % Check that no routes are owned
            obj.verifyEqual(309, obj.theBoard.getNumOfTrains(Color.gray))

            % Claim some routes
            obj.theBoard.claim(ROUTE_DENVER_TO_OMAHA, YELLOW);
            obj.theBoard.claim(ROUTE_DALLAS_TO_OKLAHOMA_CITY_A, YELLOW);
            obj.theBoard.claim(ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B, RED);

            % Check that the claimed routes are owned
            obj.verifyEqual(300, obj.theBoard.getNumOfTrains(Color.gray))
            obj.verifyEqual(6, obj.theBoard.getNumOfTrains(Color.yellow))
            obj.verifyEqual(3, obj.theBoard.getNumOfTrains(Color.red))

            % Reset the ownership map
            obj.theBoard.resetRouteOwners();

            % Check that no routes are owned
            obj.verifyEqual(309, obj.theBoard.getNumOfTrains(Color.gray))
        end

        function claimerOfRouteBecomesOwner(obj)
            % claimerOfRouteBecomesOwner
            % Ensures a route is unowned prior to being claimed, becomes
            % owned once it is claimed, and the owner is correctly returned
            % when queried.

            % Add color and route names
            addpath('..')
            BaseBoard.initializeRoutes;
            initializeColors;

            % Check that certain routes are not owned
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_DENVER_TO_OMAHA));
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_DALLAS_TO_OKLAHOMA_CITY_A));
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B));
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_SEATTLE_TO_VANCOUVER_B));

            % Each of four players claim a route
            obj.theBoard.claim(ROUTE_DENVER_TO_OMAHA, YELLOW);
            obj.theBoard.claim(ROUTE_DALLAS_TO_OKLAHOMA_CITY_A, BLUE);
            obj.theBoard.claim(ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B, ORANGE);
            obj.theBoard.claim(ROUTE_SEATTLE_TO_VANCOUVER_B, RED);

            % Check that the routes are now owned
            obj.verifyTrue(obj.theBoard.isOwned(ROUTE_SEATTLE_TO_VANCOUVER_B));
            obj.verifyTrue(obj.theBoard.isOwned(ROUTE_DALLAS_TO_OKLAHOMA_CITY_A));
            obj.verifyTrue(obj.theBoard.isOwned(ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B));
            obj.verifyTrue(obj.theBoard.isOwned(ROUTE_DENVER_TO_OMAHA));

            % Check that various other routes are still unowned
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_SEATTLE_TO_VANCOUVER_A));
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_DALLAS_TO_OKLAHOMA_CITY_B));
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_HELENA_TO_SEATTLE));
            obj.verifyFalse(obj.theBoard.isOwned(ROUTE_DENVER_TO_OKLAHOMA_CITY));

            % Check that the route owners are correct
            % Patrick Note: verifyEqual did not work on type Color
            obj.verifyTrue(obj.theBoard.owner(ROUTE_DALLAS_TO_OKLAHOMA_CITY_A) == BLUE);
            obj.verifyTrue(obj.theBoard.owner(ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B) == ORANGE);
            obj.verifyTrue(obj.theBoard.owner(ROUTE_SEATTLE_TO_VANCOUVER_B) == RED);
            obj.verifyTrue(obj.theBoard.owner(ROUTE_DENVER_TO_OMAHA) == YELLOW);
            obj.verifyTrue(obj.theBoard.owner(ROUTE_EL_PASO_TO_SANTA_FE) == GRAY);
        end
    end
end

