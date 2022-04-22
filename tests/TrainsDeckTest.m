classdef TrainsDeckTest  < matlab.unittest.TestCase
    %TRAINSDECKTEST Tests the capabilities of the TrainsDeck class to 
    % ensure it functions as intended.
    
    methods(TestMethodSetup)

    end

    methods(TestMethodTeardown)
    end

    methods(Test)
        function initTest(obj)
            trainsDeckBlue = TrainsDeck(int8(0),int8(0),int8(100),int8(0),int8(0),int8(0),int8(0),int8(0),int8(0));
            starting = trainsDeckBlue.init(10,3,2,RandStream('mt19937ar'));
            obj.verifyEqual(length(starting),10);
            obj.verifyEqual(length(trainsDeckBlue.drawPile),87);
            obj.verifyEqual(length(trainsDeckBlue.faceUpCards),3);
            obj.verifyEqual(length(trainsDeckBlue.discardPile),0);
            obj.verifyEqual(length(trainsDeckBlue.allCards),100);

        end
        function DrawTest(obj)
            trainsDeckBlue = TrainsDeck(int8(0),int8(0),int8(13),int8(0),int8(0),int8(0),int8(0),int8(0),int8(0));
            starting = trainsDeckBlue.init(10,0,2,RandStream('mt19937ar'));

            % draw
            card = trainsDeckBlue.drawCard(TrainCard("unknown"), RandStream('mt19937ar'));
            obj.verifyEqual(card, TrainCard("blue"));
            obj.verifyEqual(length(trainsDeckBlue.drawPile),2);
            obj.verifyEqual(length(trainsDeckBlue.faceUpCards),0);
            obj.verifyEqual(length(trainsDeckBlue.discardPile),0);

            % discard
            card = trainsDeckBlue.drawCard(TrainCard("unknown"), RandStream('mt19937ar'));
            trainsDeckBlue.discard(TrainCard("blue"), RandStream('mt19937ar'));
            trainsDeckBlue.discard(TrainCard("blue"), RandStream('mt19937ar'));
            obj.verifyEqual(length(trainsDeckBlue.drawPile),1);
            obj.verifyEqual(length(trainsDeckBlue.discardPile),2);

            % reshuffle discard
            card = trainsDeckBlue.drawCard(TrainCard("unknown"), RandStream('mt19937ar'));
            obj.verifyEqual(length(trainsDeckBlue.drawPile),2);
            obj.verifyEqual(length(trainsDeckBlue.discardPile),0);

            % re-init
            starting = trainsDeckBlue.init(10,0,2, RandStream('mt19937ar'));
            obj.verifyEqual(length(trainsDeckBlue.drawPile),3);
            obj.verifyEqual(length(trainsDeckBlue.faceUpCards),0);
            obj.verifyEqual(length(trainsDeckBlue.discardPile),0);

        end

    end
end

