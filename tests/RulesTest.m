classdef RulesTest < matlab.unittest.TestCase
    % RulesTest
    % Tests the capabilities of the Rules class to ensure it functions as
    % intended.
    
    
    properties

    end
    
    methods(TestMethodSetup)

    end

    methods(TestMethodTeardown)
    end

    methods(Test)
        function GetClaimableRoutesTest(obj)
            % GetClaimableRoutesTest
            % Checks that claimable routes are returned correctly

            ROUTE_ATLANTA_TO_CHARLESTON = Route(Location.Atlanta, Location.Charleston, Color.gray, 2);
            ROUTE_ATLANTA_TO_MIAMI = Route(Location.Atlanta, Location.Miami, Color.blue, 5);
            ROUTE_BOSTON_TO_NEW_YORK_A = Route(Location.Boston, Location.New_York, Color.yellow, 2);
            ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B = Route(Location.Kansas_City, Location.Saint_Louis, Color.blue, 2);
            ROUTE_MONTREAL_TO_NEW_YORK = Route(Location.Montreal, Location.New_York, Color.blue, 3);

            board = Board(ROUTE_ATLANTA_TO_CHARLESTON, ... %gray 2
            ROUTE_ATLANTA_TO_MIAMI, ... %blue 5
            ROUTE_BOSTON_TO_NEW_YORK_A, ... % yellow 2
            ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...%blue 2
            ROUTE_MONTREAL_TO_NEW_YORK); %blue 3        
            
            board.claim(ROUTE_MONTREAL_TO_NEW_YORK, Color.red);
            
            trainsDeck = TrainsDeck(1,1,1,1,1,1,1,1,1);
            destinationsDeck = DestinationsDeck(DestinationTicketCard("Atlanta","Charleston",0));
            rules = RulesStub();
            player = PlayerStub();
            player.color = Color.green;

            player.trainCardsHand = TrainCard.empty;
            checkRoutes(Route.empty, Color.empty, "No cards in hand");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.yellow)];
            checkRoutes([ROUTE_ATLANTA_TO_CHARLESTON, ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B], [Color.blue, Color.blue], "2 blue");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.yellow), TrainCard(Color.yellow)];
            checkRoutes([ROUTE_ATLANTA_TO_CHARLESTON, ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...
                ROUTE_ATLANTA_TO_CHARLESTON, ROUTE_BOSTON_TO_NEW_YORK_A],...
                [Color.blue, Color.blue, Color.yellow, Color.yellow], "2 blue, 2 yellow");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.multicolored), TrainCard(Color.yellow), TrainCard(Color.yellow)];
            checkRoutes([ROUTE_ATLANTA_TO_CHARLESTON, ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...
                ROUTE_ATLANTA_TO_CHARLESTON, ROUTE_BOSTON_TO_NEW_YORK_A],...
                [Color.blue, Color.blue, Color.yellow, Color.yellow], "Locomotive");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.multicolored), TrainCard(Color.multicolored), TrainCard(Color.blue), TrainCard(Color.yellow)];
            checkRoutes([ROUTE_ATLANTA_TO_CHARLESTON, ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...
                ROUTE_ATLANTA_TO_MIAMI, ROUTE_ATLANTA_TO_CHARLESTON, ROUTE_BOSTON_TO_NEW_YORK_A, ROUTE_ATLANTA_TO_CHARLESTON],...
                [Color.blue, Color.blue, Color.blue, Color.yellow, Color.yellow, Color.multicolored], "2 Locomotive");
            
            function checkRoutes(expectedRoutes, expectedColors, diagnostic)
                [claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards] = ...
                    rules.getPossibleActions(player, board, trainsDeck, destinationsDeck, ...
                    Route.empty, TrainCard.empty, 0);
                obj.verifyTrue(length(claimableRoutes)==length(expectedRoutes),diagnostic);
                obj.verifyTrue(length(claimableRouteColors)==length(expectedColors),diagnostic);
                for ix=1:length(expectedRoutes)
                    found = false;
                    for rIx=1:length(claimableRoutes)
                        if(claimableRoutes(rIx).id == expectedRoutes(ix).id && ...
                                claimableRouteColors(rIx) == expectedColors(ix))
                            found=true;
                        end
                    end
                    obj.verifyTrue(found, diagnostic);
                end
                
            end
        end

    end
end



