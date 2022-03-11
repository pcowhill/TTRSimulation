classdef BoardTest < matlab.unittest.TestCase
    % BoardTest
    % Tests the capabilities of the Board class to ensure it functions as
    % intended.
    
    properties
        theBoard % The board that the tests are run on.
    end
    
    methods(TestMethodSetup)
        function createBoard(obj)
            addpath('..')
            initializeBoard;
            obj.theBoard = BOARD;
        end
    end

    methods(TestMethodTeardown)
    end

    methods(Test)
        function resetRouteOwnersWorks(obj)
            % resetRouteOwnersWorks
            % Ensures the resetRouteOwners method of Board works properly

            % Add color and route names
            addpath('..')
            initializeRoutes;
            initializeColors;

            % Reset the ownership map
            obj.theBoard.resetRouteOwners();

            % Check that no routes are owned
            obj.verifyTrue(0 == obj.theBoard.ownershipMap.Count)

            % Claim some routes
            obj.theBoard.claim(DENVER_TO_OMAHA, YELLOW);
            obj.theBoard.claim(DALLAS_TO_OKLAHOMA_CITY_A, YELLOW);
            obj.theBoard.claim(LOS_ANGELES_TO_SAN_FRANCISCO_B, RED);

            % Check that the claimed routes are owned
            obj.verifyTrue(3 == obj.theBoard.ownershipMap.Count)

            % Reset the ownership map
            obj.theBoard.resetRouteOwners();

            % Check that no routes are owned
            obj.verifyTrue(0 == obj.theBoard.ownershipMap.Count)
        end

        function claimerOfRouteBecomesOwner(obj)
            % claimerOfRouteBecomesOwner
            % Ensures a route is unowned prior to being claimed, becomes
            % owned once it is claimed, and the owner is correctly returned
            % when queried.

            % Add color and route names
            addpath('..')
            initializeRoutes;
            initializeColors;

            % Check that certain routes are not owned
            obj.verifyFalse(obj.theBoard.isOwned(DENVER_TO_OMAHA));
            obj.verifyFalse(obj.theBoard.isOwned(DALLAS_TO_OKLAHOMA_CITY_A));
            obj.verifyFalse(obj.theBoard.isOwned(LOS_ANGELES_TO_SAN_FRANCISCO_B));
            obj.verifyFalse(obj.theBoard.isOwned(SEATTLE_TO_VANCOUVER_B));

            % Each of four players claim a route
            obj.theBoard.claim(DENVER_TO_OMAHA, YELLOW);
            obj.theBoard.claim(DALLAS_TO_OKLAHOMA_CITY_A, BLUE);
            obj.theBoard.claim(LOS_ANGELES_TO_SAN_FRANCISCO_B, ORANGE);
            obj.theBoard.claim(SEATTLE_TO_VANCOUVER_B, RED);

            % Check that the routes are now owned
            obj.verifyTrue(obj.theBoard.isOwned(SEATTLE_TO_VANCOUVER_B));
            obj.verifyTrue(obj.theBoard.isOwned(DALLAS_TO_OKLAHOMA_CITY_A));
            obj.verifyTrue(obj.theBoard.isOwned(LOS_ANGELES_TO_SAN_FRANCISCO_B));
            obj.verifyTrue(obj.theBoard.isOwned(DENVER_TO_OMAHA));

            % Check that various other routes are still unowned
            obj.verifyFalse(obj.theBoard.isOwned(SEATTLE_TO_VANCOUVER_A));
            obj.verifyFalse(obj.theBoard.isOwned(DALLAS_TO_OKLAHOMA_CITY_B));
            obj.verifyFalse(obj.theBoard.isOwned(HELENA_TO_SEATTLE));
            obj.verifyFalse(obj.theBoard.isOwned(DENVER_TO_OKLAHOMA_CITY));

            % Check that the route owners are correct
            % Patrick Note: verifyEqual did not work on type Color
            obj.verifyTrue(obj.theBoard.owner(DALLAS_TO_OKLAHOMA_CITY_A) == BLUE);
            obj.verifyTrue(obj.theBoard.owner(LOS_ANGELES_TO_SAN_FRANCISCO_B) == ORANGE);
            obj.verifyTrue(obj.theBoard.owner(SEATTLE_TO_VANCOUVER_B) == RED);
            obj.verifyTrue(obj.theBoard.owner(DENVER_TO_OMAHA) == YELLOW);
            obj.verifyTrue(obj.theBoard.owner(EL_PASO_TO_SANTA_FE) == GRAY);
        end
    end
end

