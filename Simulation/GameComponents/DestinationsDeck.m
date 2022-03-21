classdef DestinationsDeck < handle
    % The DestinationsDeck comprises of and keeps track of the 
    %  destination cards in the game

    properties (SetAccess = immutable)
        allDestCards DestinationTicketCard = DestinationTicketCard.empty    % array containing all destination cards in play -- this will not change throughout the game; there is a designated property for all the cards in order to allow us to reset the deck after each game
    end

    properties (SetAccess = private)
        currentCardsInDeck DestinationTicketCard = DestinationTicketCard.empty  % array of DestinationTicketCard objects that are currently in the deck (not in a Player's hand)
    end
    
    methods
        function obj = DestinationsDeck(varargin)
            % DESTINATIONSDECK Construct an instance of this class
            % This constructor accepts arguments that are of class 
            % DestinationTicketCard and puts them into a deck. 
            for i=1:nargin
                assert(string(class(varargin{i})) == "DestinationTicketCard", ...
                    "Argument class mismatch: all arguments of the DestinationsDeck constructor must " + ...
                    "be of the class DestinationTicketCard.");
            end

            obj.allDestCards = [varargin{:}];
        end
        
        function init(obj)
            % init Initializes/resets deck for a new game
            % This function puts ALL the cards in the deck and shuffles it. 
            % Assumption: For the cards that are dealt, the number of cards 
            % may vary between each player, so that method shall be 
            % handled by the abstract player classes.
            % TODO: Ask Rachel and Patrick to confirm my assumption^^
            arguments
                obj DestinationsDeck
            end

            obj.currentCardsInDeck = obj.allDestCards;
            shuffle(obj);
        end

        function numCardsLeft = getNumCardsLeft(obj)
            % getNumCardsLeft Returns number of cards remaining in the deck
            arguments
                obj DestinationsDeck
            end

            numCardsLeft = length(obj.currentCardsInDeck);
        end

        function cards = draw(obj, numCards)
            % draw numCards from top of deck
            % If numCards is more than what is left in the deck, draw all
            % the remaining cards
            arguments
                obj DestinationsDeck
                numCards {mustBeInteger}
            end

            if numCards <= getNumCardsLeft(obj)
                cards = obj.currentCardsInDeck(1:numCards);
                obj.currentCardsInDeck(1:numCards) = [];
            elseif getNumCardsLeft(obj) > 0
                cards = obj.currentCardsInDeck;
                obj.currentCardsInDeck = DestinationTicketCard.empty;
            else
                disp("No destination cards left. The Player cannot " + ...
                    "draw a Destination card.");
                cards = DestinationTicketCard.empty;
            end
        end

        function returnCards(obj, cards)
            % returnCards Puts cards (from a Player) on the bottom of the 
            % deck. Note: Higher indices are at the bottom of the deck.
            % This occurs when players draw cards and need to decide which
            % cards to keep and which to return to the deck. 
            arguments
                obj DestinationsDeck
                cards DestinationTicketCard % array of DestinationTicketCards 
                                            % being returned by the Player
            end

            obj.currentCardsInDeck = [obj.currentCardsInDeck cards];
        end
        
        function shuffle(obj)
            arguments
                obj DestinationsDeck
            end

            % Randomize the order of the DestinationTicketCards
            newOrderIdx = randperm(length(obj.currentCardsInDeck));
    
            % Put the cards in their new order
            obj.currentCardsInDeck(newOrderIdx) = obj.currentCardsInDeck;
        end
            
    end
end
