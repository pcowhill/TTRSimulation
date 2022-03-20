classdef DestinationsDeck < handle
    % The DestinationsDeck comprises of and keeps track of the 
    %  destination cards in the game

    properties
        allDestCards DestinationTicketCard = DestinationTicketCard.empty   % array containing all destination cards in play
        currentCardsInDeck DestinationTicketCard = DestinationTicketCard.empty   % array of DestinationTicketCard objects that are currently in the deck (not in a Player's hand)
    end
    
    methods
        function obj = DestinationsDeck(varargin)
            % DESTINATIONSDECK Construct an instance of this class
            % This constructor accepts arguments that are of class 
            % DestinationTicketCard and puts them into a deck. 
%             assert(string(class(varargin{:})) == "DestinationTicketCard", ...
%                     "Argument class mismatch: all arguments of the DestinationsDeck constructor must " + ...
%                     "be of the class DestinationTicketCard.");

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

        function numCardsLeft = getCardsLeft(obj)
            % getCardsLeft Returns number of cards remaining in the deck
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
                numCards {isinteger}
            end

            if numCards <= getCardsLeft(obj)
                cards = obj.currentCardsInDeck(1:numCards);
                obj.currentCardsInDeck(1:numCards) = [];
            elseif getCardsLeft(obj) > 0
                cards = obj.currentCardsInDeck(1:getCardsLeft(obj));
                obj.currentCardsInDeck = [];
            else
                strcat(['No destination cards left. ' ...
                    'The Player cannot draw a Destination card.']);
                cards = [];
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

            obj.currentCardsInDeck(getCardsLeft(obj)+1:getCardsLeft(obj)+length(cards)) = cards;
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
