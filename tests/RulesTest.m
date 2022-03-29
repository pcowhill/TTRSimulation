classdef RulesTest < matlab.unittest.TestCase
    % RulesTest
    % Tests the capabilities of the Rules class to ensure it functions as
    % intended.
    
    
    properties
        board Board
        ROUTE_ATLANTA_TO_CHARLESTON
        ROUTE_ATLANTA_TO_MIAMI
        ROUTE_BOSTON_TO_NEW_YORK_A
        ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B
        ROUTE_MONTREAL_TO_NEW_YORK     
        ROUTE_CHARLESTON_TO_MIAMI
        ROUTE_DENVER_TO_KANSAS_CITY_A
        ROUTE_DENVER_TO_OMAHA
        ROUTE_NEW_YORK_TO_PITTSBURGH_A
        ROUTE_NASHVILLE_TO_PITTSBURGH
        ROUTE_ATLANTA_TO_NEW_ORLEANS_A
    end
    
    methods(TestMethodSetup)
        function initializeBoard(obj)
            obj.ROUTE_ATLANTA_TO_CHARLESTON = Route(Location.Atlanta, Location.Charleston, Color.gray, 2);
            obj.ROUTE_ATLANTA_TO_MIAMI = Route(Location.Atlanta, Location.Miami, Color.blue, 5);
            obj.ROUTE_BOSTON_TO_NEW_YORK_A = Route(Location.Boston, Location.New_York, Color.yellow, 2);
            obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B = Route(Location.Kansas_City, Location.Saint_Louis, Color.blue, 2);
            obj.ROUTE_MONTREAL_TO_NEW_YORK = Route(Location.Montreal, Location.New_York, Color.blue, 3);
            obj.ROUTE_CHARLESTON_TO_MIAMI = Route(Location.Charleston,Location.Miami, Color.purple, 4);
            obj.ROUTE_DENVER_TO_KANSAS_CITY_A = Route(Location.Denver, Location.Kansas_City, Color.orange, 4);
            obj.ROUTE_DENVER_TO_OMAHA = Route(Location.Denver, Location.Omaha, Color.purple, 4);
            obj.ROUTE_NEW_YORK_TO_PITTSBURGH_A = Route(Location.New_York, Location.Pittsburgh, Color.white, 2);
            obj.ROUTE_NASHVILLE_TO_PITTSBURGH = Route(Location.Nashville, Location.Pittsburgh, Color.yellow, 4);
            obj.ROUTE_ATLANTA_TO_NEW_ORLEANS_A = Route(Location.Atlanta, Location.New_Orleans, Color.orange, 4);
            
    
            obj.board = Board(obj.ROUTE_ATLANTA_TO_CHARLESTON, ... %gray 2
                obj.ROUTE_ATLANTA_TO_MIAMI, ... %blue 5
                obj.ROUTE_BOSTON_TO_NEW_YORK_A, ... % yellow 2
                obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...%blue 2
                obj.ROUTE_MONTREAL_TO_NEW_YORK,... %blue 3      
                obj.ROUTE_CHARLESTON_TO_MIAMI,...%purple 4
                obj.ROUTE_DENVER_TO_KANSAS_CITY_A, ...%orange 4
                obj.ROUTE_DENVER_TO_OMAHA, ... %purple 4
                obj.ROUTE_NEW_YORK_TO_PITTSBURGH_A,...%white 2
                obj.ROUTE_NASHVILLE_TO_PITTSBURGH, ...%yellow 4
                obj.ROUTE_ATLANTA_TO_NEW_ORLEANS_A...%orange 4
            );
            
            
        end
    end

    methods(TestMethodTeardown)
    end

    methods(Test)
        function GetClaimableRoutesTest(obj)
            % GetClaimableRoutesTest
            % Checks that claimable routes are returned correctly
            obj.board.claim(obj.ROUTE_MONTREAL_TO_NEW_YORK, Color.red);

            trainsDeck = TrainsDeck(int8(1),int8(1),int8(1),int8(1),int8(1),int8(1),int8(1),int8(1),int8(1));
            destinationsDeck = DestinationsDeck(DestinationTicketCard("Atlanta","Charleston",0));
            rules = RulesStubs.RulesStub();
            player = RulesStubs.PlayerStub();
            player.color = Color.green;

            player.trainCardsHand = TrainCard.empty;
            checkRoutes(Route.empty, Color.empty, "No cards in hand");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.yellow)];
            checkRoutes([obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B], [Color.blue, Color.blue], "2 blue");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.yellow), TrainCard(Color.yellow)];
            checkRoutes([obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...
                obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_BOSTON_TO_NEW_YORK_A],...
                [Color.blue, Color.blue, Color.yellow, Color.yellow], "2 blue, 2 yellow");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.multicolored), TrainCard(Color.yellow), TrainCard(Color.yellow)];
            checkRoutes([obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...
                obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_BOSTON_TO_NEW_YORK_A],...
                [Color.blue, Color.blue, Color.yellow, Color.yellow], "Locomotive");

            player.trainCardsHand = [TrainCard(Color.blue), TrainCard(Color.blue), TrainCard(Color.multicolored), TrainCard(Color.multicolored), TrainCard(Color.blue), TrainCard(Color.yellow)];
            checkRoutes([obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...
                obj.ROUTE_ATLANTA_TO_MIAMI, obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_BOSTON_TO_NEW_YORK_A,...
                obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_BOSTON_TO_NEW_YORK_A,obj.ROUTE_NEW_YORK_TO_PITTSBURGH_A],...
                [Color.blue, Color.blue, Color.blue, Color.yellow, Color.yellow, Color.multicolored, Color.multicolored, Color.multicolored, Color.multicolored], "2 Locomotive");

            player.trainCardsHand = [TrainCard(Color.multicolored), TrainCard(Color.multicolored)];
            checkRoutes([obj.ROUTE_ATLANTA_TO_CHARLESTON, obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B,...
                obj.ROUTE_NEW_YORK_TO_PITTSBURGH_A, obj.ROUTE_BOSTON_TO_NEW_YORK_A],...
                [Color.multicolored, Color.multicolored, Color.multicolored, Color.multicolored], "All Locomotive");
            
            function checkRoutes(expectedRoutes, expectedColors, diagnostic)
                [claimableRoutes, claimableRouteColors, drawableCards, drawDestinationCards] = ...
                    rules.getPossibleActions(player, obj.board, trainsDeck, destinationsDeck, ...
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

        function getTicketsCompletedTest(obj)
            player = RulesStubs.PlayerStub();
            player.destinationCardsHand = [DestinationTicketCard("Omaha","Saint_Louis",1),...
                DestinationTicketCard("Atlanta","Charleston",2),...
                DestinationTicketCard("Nashville","Boston",3),...
                DestinationTicketCard("Nashville","Montreal",4)...
                DestinationTicketCard("Nashville","Miami",5)];
            rules = RulesStubs.RulesStub();
            ticketsCompleted = rules.getTicketsCompletedTest(obj.board, player);
            obj.verifyEqual(ticketsCompleted, logical([0 0 0 0 0]), "No routes claimed");

            obj.board.claim(obj.ROUTE_ATLANTA_TO_MIAMI, Color.red);
            obj.board.claim(obj.ROUTE_BOSTON_TO_NEW_YORK_A, Color.red);
            obj.board.claim(obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, Color.red);
            obj.board.claim(obj.ROUTE_MONTREAL_TO_NEW_YORK, Color.red);
            obj.board.claim(obj.ROUTE_CHARLESTON_TO_MIAMI, Color.red);
            obj.board.claim(obj.ROUTE_DENVER_TO_KANSAS_CITY_A, Color.red);
            obj.board.claim(obj.ROUTE_DENVER_TO_OMAHA, Color.red);
            obj.board.claim(obj.ROUTE_NEW_YORK_TO_PITTSBURGH_A, Color.red);
            obj.board.claim(obj.ROUTE_NASHVILLE_TO_PITTSBURGH, Color.red);
            ticketsCompleted = rules.getTicketsCompletedTest(obj.board, player);
            obj.verifyEqual(ticketsCompleted, logical([1 1 1 1 0]), "All routes claimed");

            obj.board.claim(obj.ROUTE_ATLANTA_TO_MIAMI, Color.gray);
            ticketsCompleted = rules.getTicketsCompletedTest(obj.board, player);
            obj.verifyEqual(ticketsCompleted, logical([1 0 1 1 0]), "Broken link");

            obj.board.claim(obj.ROUTE_BOSTON_TO_NEW_YORK_A, Color.gray);
            ticketsCompleted = rules.getTicketsCompletedTest(obj.board, player);
            obj.verifyEqual(ticketsCompleted, logical([1 0 0 1 0]), "Broken link 2");

        end

        function getLongestRouteTest(obj)
            players = [RulesStubs.PlayerStub() RulesStubs.PlayerStub()];
            players(2).color = Color.yellow;
            rules = RulesStubs.RulesStub();

            longestRouteLengths = rules.getLongestRouteTest(obj.board, players);
            obj.verifyEqual(longestRouteLengths, [0 0], "No routes claimed");

            obj.board.claim(obj.ROUTE_ATLANTA_TO_NEW_ORLEANS_A, Color.red);
            obj.board.claim(obj.ROUTE_ATLANTA_TO_CHARLESTON, Color.red);
            obj.board.claim(obj.ROUTE_ATLANTA_TO_MIAMI, Color.red);
            obj.board.claim(obj.ROUTE_BOSTON_TO_NEW_YORK_A, Color.yellow);
            obj.board.claim(obj.ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, Color.yellow);
            obj.board.claim(obj.ROUTE_MONTREAL_TO_NEW_YORK, Color.yellow);
            obj.board.claim(obj.ROUTE_CHARLESTON_TO_MIAMI, Color.red);
            obj.board.claim(obj.ROUTE_DENVER_TO_KANSAS_CITY_A, Color.yellow);
            obj.board.claim(obj.ROUTE_DENVER_TO_OMAHA, Color.yellow);
            obj.board.claim(obj.ROUTE_NEW_YORK_TO_PITTSBURGH_A, Color.yellow);
            obj.board.claim(obj.ROUTE_NASHVILLE_TO_PITTSBURGH, Color.yellow);
            longestRouteLengths = rules.getLongestRouteTest(obj.board, players);
            obj.verifyEqual(longestRouteLengths, [15 10], "All routes claimed");

            obj.board.claim(obj.ROUTE_ATLANTA_TO_NEW_ORLEANS_A, Color.yellow);
            longestRouteLengths = rules.getLongestRouteTest(obj.board, players);
            obj.verifyEqual(longestRouteLengths, [11 10], "Cycle");

            obj.board.claim(obj.ROUTE_ATLANTA_TO_NEW_ORLEANS_A, Color.red);
            obj.board.claim(obj.ROUTE_ATLANTA_TO_MIAMI, Color.yellow);
            longestRouteLengths = rules.getLongestRouteTest(obj.board, players);
            obj.verifyEqual(longestRouteLengths, [10 10], "Un-Cycle");

            obj.board.claim(obj.ROUTE_DENVER_TO_KANSAS_CITY_A, Color.red);
            longestRouteLengths = rules.getLongestRouteTest(obj.board, players);
            obj.verifyEqual(longestRouteLengths, [10 9], "Broken path");

        end
    end
end



