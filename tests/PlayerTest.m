classdef PlayerTest < matlab.unittest.TestCase
    % RulesTest
    % Tests the capabilities of the Player class to ensure it functions as
    % intended.
    
    
    properties

    end
    
    methods(TestMethodSetup)

    end

    methods(TestMethodTeardown)
    end

    methods(Test)
        function PlayerActionsTest(obj)
            % PlayerActionsTest
            % Checks that actions are carried out correctly
            board = Board(Route(Location.Atlanta, Location.Charleston, Color.blue, 4));
            trainsDeckBlue = TrainsDeck(int8(0),int8(0),int8(100),int8(0),int8(0),int8(0),int8(0),int8(0),int8(0));
            trainsDeckBlue.init(1,1,1);
            trainsDeckMulti = TrainsDeck(int8(0),int8(0),int8(0),int8(0),int8(0),int8(0),int8(0),int8(0),int8(100));
            trainsDeckMulti.init(1,1,1);
            destinationsDeck = DestinationsDeck(DestinationTicketCard("Atlanta","Charleston",10),...
                DestinationTicketCard("Atlanta","Charleston",10),...
                DestinationTicketCard("Atlanta","Charleston",10));
            destinationsDeck.init();
            rules = PlayerStubs.RulesStub();
            player = PlayerStubs.PlayerStub(1);
            rules.action=1;
            logFileName = "logFile.txt";
            if isfile(logFileName)
                delete(logFileName);
            end
            logger = log4m.getLogger(logFileName);
            player.takeTurn(rules,board,trainsDeckBlue,destinationsDeck, logger);
            obj.verifyEqual(player.trainCardsHand,[TrainCard("blue")], "Draw Card");
            for ix=1:4
                player.takeTurn(rules,board,trainsDeckBlue,destinationsDeck, logger);
            end
            obj.verifyEqual(player.trainCardsHand,repmat(TrainCard("blue"),1,5), "Draw 5 Cards");

            rules.action=0;
            player.takeTurn(rules,board,trainsDeckBlue,destinationsDeck, logger);
            obj.verifyEqual(player.trainCardsHand,[TrainCard("blue")], "Claim route with blue");
            obj.verifyEqual(player.victoryPoints,5,"Claim route with blue");

            rules.action=1;
            player.takeTurn(rules,board,trainsDeckBlue,destinationsDeck, logger);
            player.takeTurn(rules,board,trainsDeckBlue,destinationsDeck, logger);
            rules.action=3;
            player.takeTurn(rules,board,trainsDeckMulti,destinationsDeck, logger);
            player.takeTurn(rules,board,trainsDeckMulti,destinationsDeck, logger);
            rules.action=0;
            player.takeTurn(rules,board,trainsDeckMulti,destinationsDeck, logger);
            obj.verifyEqual(player.trainCardsHand,[TrainCard("multicolored")], "Claim route with multicolored");
            obj.verifyEqual(player.victoryPoints,10,"Claim route with multicolored");

            rules.action=2;
            player.takeTurn(rules,board,trainsDeckMulti,destinationsDeck, logger);
            obj.verifyEqual(player.destinationCardsHand,[DestinationTicketCard("Atlanta","Charleston",10), DestinationTicketCard("Atlanta","Charleston",10)], "Draw destination tickets");
 
            delete(logFileName);            
        end


    end
end



