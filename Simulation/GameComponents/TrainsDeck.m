classdef TrainsDeck
    %TRAINSDECK Train card deck
    %   Maintain the state of the train cards deck including the discard
    %   pile and the face up cards
    
    properties
        %TODO
        Property1
    end
    
    methods
        function obj = TrainsDeck(inputArg1,inputArg2)
            %TRAINSDECK Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
            %TODO
        end
        
        function cards = init(deck, numOfStartingCards)
            %init Shuffle deck for a new game, return the given number of
            %cards from the top of the shuffled deck to initialize player
            %hands, then turn up the first 5 face up cards
            % TODO
        end

        function card = drawCard(deck, cardIndex)
            %drawCard Draw face up card at the given cardIndex and replace
            %it. If the cardIndex is greater than the number of face up
            %cards, draw from the deck
            %TODO
        end

        function discard(deck, card)
            %discard Puts the card back inn the discard pile
            arguments
                deck TrainsDeck
                card TrainCard
            end
            %TODO
        end

        function cards = getFaceUpCards(deck)
            %getFaceUpCards Returns the set of currently face up cards

            %TODO
        end
    end
end

