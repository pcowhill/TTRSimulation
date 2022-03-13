classdef DestinationsDeck
    %DESTINATIONSDECK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = DestinationsDeck(inputArg1,inputArg2)
            %DESTINATIONSDECK Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
            %TODO
        end
        
        function init(deck)
            %init Initializes deck for a new game
            %   Detailed explanation goes here
            %TODO
        end

        function numCardsLeft = getCardsLeft(deck)
            %getCardsLeft Returns number of cards remaining in the deck
            %TODO
        end

        function cards = draw(deck, numCards)
            %draw numCards from top of deck
            % If numCards is more than what is left in the deck, draw all
            % the remaining cards
            %TODO
        end

        function returnCards(deck, cards)
            %returnCards Puts cards on the bottom of the deck
            arguments
                deck DestinationsDeck
                cards DestinationTicketCard
            end
            %TODO
        end
    end
end

