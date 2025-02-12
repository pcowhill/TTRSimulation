classdef TrainsDeck < handle
    % TRAINSDECK Train card deck
    % Maintain the state of the train cards deck including the discard
    % pile and the face up cards

    properties (SetAccess = immutable)
        allCards TrainCard = TrainCard.empty % array of TrainCard objects that consists of all train cards to be used in the game
                                % Once this property is initialized, it is
                                % not changed throughout the object's
                                % instantiation. This shall be used to
                                % "reset" our deck in order to run multiple
                                % games.
    end
    properties (SetAccess = private)
        drawPile TrainCard = TrainCard.empty    % array of TrainCard objects in the TrainsDeck that represent the initial deck, and once the game begins, the draw pile
        discardPile TrainCard = TrainCard.empty % array of TrainCard objects in TrainsDeck that represents cards that have been discarded by players during gameplay
        faceUpCards TrainCard = TrainCard.empty % array of TrainCard objects that represent the face up cards that players may choose to take during gameplay
        nFaceUpCardsNeeded {mustBeInteger}               % total number of face-up cards allowed in the game
        maxMulticoloredFaceUpAllowed {mustBeInteger} % total number of multicolored cards allowed face-up during the game
    end
    
    methods (Access = public)
        %% Constructor Method
        function obj = TrainsDeck(varargin)
            % A variable number of arguments may be accepted in order to
            % allow implementers the flexibility to build a custom
            % TrainsDeck. The easiest way to build a standard deck would be
            % to specify the number of each type of card in a predefined
            % order: purple, white, blue, yellow, orange, black, red,
            % green, and multicolored, which will occur if given 9 
            % arguments, 1 for each color. 
            % However, to allow ourselves to not be
            % restricted by this, a variety of arguments may be input: 
            % if given an even number of inputs (where odd inputs are of 
            % class Color, and even inputs are the number of that type of
            % Color, this can allow us to create a custom deck).

            % Base case: 9 numbers indicating the number of each type of colored card are given to the constructor; this expects 9 inputs of either type int8 or int16 

            if (nargin == 9)  
                for i = 1:9
                    assert(string(class(varargin{i})) == "int8", "The input arguments for 9 argument Trains Deck constructor must all be of type int8.");
                end
            
                v = [TrainCard(Color.purple), TrainCard(Color.white), TrainCard(Color.blue), TrainCard(Color.yellow), TrainCard(Color.orange), TrainCard(Color.black), TrainCard(Color.red), TrainCard(Color.green), TrainCard(Color.multicolored)];
                obj.allCards = repelem(v,[varargin{1}, varargin{2}, varargin{3}, varargin{4}, varargin{5}, varargin{6}, varargin{7}, varargin{8}, varargin{9}]);


            % Build a custom deck (with varying numbers of each type of
            % card
            % This case allows the user to specify which color cards and
            % how many of each to add. There must be an even number of
            % arguments: the first argument must be the color of the card and the
            % argument immediately following should be the number of that
            % card. The third argument must be the color of the card and
            % the fourth must be the number of that card, etc.
            % e.g., TrainsDeck(Color.blue, int8(5), Color.yellow, int8(6), Color.white, int8(11))
            else
                % Check for an even number of arguments. 
                assert(rem(nargin,2) == 0, "You must supply exactly 9 argument " + ...
                    "indicating the number of each Color card to add in this " + ...
                    "order: purple, white, blue, yellow, orange, black, red, " + ...
                    "green, and multicolored. Or you must supply an even number " + ...
                    "of arguments to create a custom deck. If you choose to " + ...
                    "create a custom deck, the odd arguments must specify " + ...
                    "the color of the cards. The even arguments must specify " + ...
                    "the number of the previous type of card to add.")

                % Check that the odd-numbered arguments are Colors and the
                % even-numbered arguments are integers
                v = TrainCard.empty;
                n = int8.empty;
                for i = 1:nargin
                    if (rem(i,2) == 1) % odd-numbered arguments (1st, 3rd, 5th, ...) arguments should be of class Color
                        assert(string(class(varargin{i})) == "Color", "Odd-numbered arguments in a custom deck must be of class Color.");
                        v = [v TrainCard(varargin{i})]; % create a template for the color cards we're adding to the deck
                    else % even-number arguments (2nd, 4th, 6th, ...) arguments should be an integer
                        assert(string(class(varargin{i})) == "int8", "Even-numbered arguments in a custom deck must be an int8 variable.")
                        n = [n varargin{i}];
                    end               
                end

                obj.allCards = repelem(v,n);
            end
        end

        %% Functions that may be called from other classes
        % Some are used internally by the TrainsDeck class as well
        function startingHands = init(obj, nStartCards, inputNFaceUpCards, inputNMulticoloredCardsAllowed, randStream)         
            % init 
            % Initialize/reset TrainsDeck based on rules.
            % Shuffle deck for a new game, return the given number of
            % cards from the top of the shuffled deck to initialize player
            % hands, then turn up the first 5 face up cards            
            arguments
                obj TrainsDeck
                nStartCards {mustBeInteger}
                inputNFaceUpCards {mustBeInteger}
                inputNMulticoloredCardsAllowed {mustBeInteger}
                randStream
            end
            
            % Initialize/Reset the drawPile, discardPile, and faceUpCards
            obj.drawPile = obj.allCards; 
            obj.discardPile = TrainCard.empty;
            obj.faceUpCards = TrainCard.empty;

            % Check to ensure we are not dealing more cards than we have
            % available in the deck
            assert(length(obj.drawPile) >= nStartCards,"Not enough train cards in the game to deal the requested number of start cards")

            % Shuffle deck and deal to players from drawPile
            % Appending of the three TrainDeck arrays will ensure all cards are in
            % one pile (e.g., in case a game has already been played, and
            % we don't want to create a new TrainsDeck object); we just want to put 
            % all the cards in one deck.
            shuffle(obj, randStream);
            startingHands = obj.drawPile(1:nStartCards);
            obj.drawPile(1:nStartCards) = [];        

            % Initialize nFaceUpCardsNeeded and maxMulticoloredFaceUpAllowed
            % properties from game rules 
            obj.nFaceUpCardsNeeded = inputNFaceUpCards;
            obj.maxMulticoloredFaceUpAllowed = inputNMulticoloredCardsAllowed;

            if drawable(obj) == true && obj.nFaceUpCardsNeeded > 0          
            % Add the number of cards that is equal to the allowed # of 
            % multicolored face-up cards. Then, use the addAndCheckFaceUpCards
            % helper function to check that we are not adding too many 
            % multicoloreds. Note: Only adding the number of cards equal to the 
            % allowed # of multicolored cards before checking is safe and cuts 
            % down on the checking of every single card.
                obj.faceUpCards(1:obj.maxMulticoloredFaceUpAllowed) = obj.drawPile(1:obj.maxMulticoloredFaceUpAllowed);
                obj.drawPile(1:obj.maxMulticoloredFaceUpAllowed) = [];
                obj.checkDrawPile(1, randStream);
                addAndCheckFaceUpCards(obj, randStream);
            else
            % else leave all cards in the drawPile -- we don't have enough
            % to have face-up cards.
                disp("The game was initialized without face-up cards.")
            end
        end

        function drawnCard = drawCard(obj, desiredCard, randStream)
            % drawCard 
            % Draw given face up card
            % If the card color is unknown, draw from the deck.
            arguments
                obj TrainsDeck
                desiredCard TrainCard
                randStream
            end

            drawnCard = TrainCard.empty;

            % get index of card in face up pile
            cardIndex = find([obj.faceUpCards.color] == desiredCard.color);
            if ~isempty(cardIndex)
                % card is face up, grab first instance
                cardIndex = cardIndex(1);
            else
                % card is not in face up pile, draw from deck
                cardIndex = -1;
            end

            if ~obj.drawable()
                checkDrawPile(obj, 1, randStream);
            else
                % If the index is <= the number of face-up cards, draw the 
                % indexed face-up card
                if (cardIndex > 0 && cardIndex <= length(obj.faceUpCards))          
                    % Return the face-up card specified by the Player 
                    % via the cardIndex argument
                    drawnCard = obj.faceUpCards(cardIndex);
                    obj.faceUpCards(cardIndex) = [];    
                    if obj.drawable()
                        obj.faceUpCards(obj.nFaceUpCardsNeeded) = obj.drawPile(1);
                        obj.drawPile(1) = [];
                    end
    
                    % If the drawPile is drawable and empty, make sure 
                    % it gets shuffled. Then, make sure to check for valid face up
                    % cards (< maxMulticoloredFaceUpAllowed).
                    checkDrawPile(obj, 1, randStream);
                    obj.addAndCheckFaceUpCards(randStream);
                elseif(cardIndex < 0 && obj.drawable())
                    % Draw the top card from the drawPile - the player 
                    % wishes to draw a card from the draw pile
                    checkDrawPile(obj, 1, randStream);
                    drawnCard = obj.drawPile(1); 
                    obj.drawPile(1) = [];
    
                    % If the drawPile is drawable and empty, make sure 
                    % it gets shuffled. 
                    checkDrawPile(obj, 1, randStream);
                else
                    error("Index given for drawing a card from the draw " + ...
                        "pile or face-up cards was out of range.")
                end
            end
        end

        function card = dealCard(obj, randStream)
            card = obj.drawCard(TrainCard(Color.unknown), randStream);
        end

        function discard(obj, card, randStream)
            % discard Puts the card back in the discard pile
            arguments
                obj TrainsDeck
                card TrainCard
                randStream
            end

            obj.discardPile = [obj.discardPile, card];
            
            % In the rare event that the state of our TrainsDeck obj 
            % is not drawable, addAndCheckFaceUpCards is called in case 
            % discard makes the deck drawable again, in which case, we 
            % will need to add to the FaceUpCards pile.
            % If the deck was already drawable prior to the discard, there 
            % should already be all the nFaceUpCardsNeeded, so this 
            % call would have no effect on the state of the cards 
            % face-up cards.
            addAndCheckFaceUpCards(obj, randStream);
        end

        function cards = getFaceUpCards(obj)
           %getFaceUpCards Returns the set of currently face up cards
            arguments
                obj TrainsDeck
            end

            cards = obj.faceUpCards;
        end       

        function tf = drawable(obj)                           
            % This returns true if we are able to draw cards from the TrainDeck 
            % (either from the face-up cards or the drawPile).
            
            % In at least 2 (RARE) cases, the Player will not be able to 
            % draw a card. This function checks for those exceptional 
            % cases:
            % - if the number of face-up and drawable pile is less than 
            %   or equal to the total face-up cards needed displayed (i.e., 
            %   Players have MANY cards in their hands)
            % - the number of "regular" cards needed to keep the
            %   multicoloreds below the threshold of maxMulticoloredFaceUpAllowed 
            %   is more than the number of regular cards available
            % THEN
            % the state of the TrainDeck is not drawable -- players may not
            % a draw a card from either the face-up cards or the drawPile
            drawablePileCards = [obj.drawPile, obj.discardPile, obj.faceUpCards];
            if (length(drawablePileCards) <= (obj.nFaceUpCardsNeeded + 1) || (sum([drawablePileCards.color] ~= Color.multicolored)) < (obj.nFaceUpCardsNeeded - obj.maxMulticoloredFaceUpAllowed))
                tf = false;
            else
                tf = true;
            end

        end
    end
    methods(Access=private)
        %% Private Helper Functions
        % used mainly for running the TrainDeck class and doing 
        % internal checking of the TrainDeck state. These are not to be 
        % called by other classes.
        function shuffle(obj, randStream)
            arguments
                obj TrainsDeck
                randStream
            end
            % Append the discardPile to the drawPile array, this will allow 
            % us to reorder them in the same array. Note: even though the 
            % discardPile is empty at the beginning of the game and the 
            % drawPile can be empty when it's cards are exhausted in the 
            % middle of the game, this will not affect the desired outcome
            % -- as appending empty arrays will not change the array.
            obj.drawPile = [obj.drawPile, obj.discardPile]; 
            obj.discardPile = TrainCard.empty;
            newOrderIdx = randperm(randStream, length(obj.drawPile));
    
            % Put the cards in their new order
            obj.drawPile(newOrderIdx) = obj.drawPile;
         end

        function addAndCheckFaceUpCards(obj, randStream)
            % This helper function starts by checking if the TrainsDeck 
            % object is drawable, and, if so, adds a card to the set of
            % face-up cards. Then, it checks that adding the new card has 
            % not caused the maxMulticoloredFaceUpAllowed threshold to be 
            % exceeded. If it has, then all face-up cards are discarded 
            % and we have to draw a new face up card set.
            % Cards are to be added and checked until nFaceUpCards is 
            % reached
            % (IF there are at least nFaceUpCards in deck)
            arguments
                obj TrainsDeck
                randStream
            end

            if drawable(obj)
            % if we have less than the face up cards needed, continue 
            % adding cards until a valid set of face-up cards is chosen
                while length(obj.faceUpCards) < obj.nFaceUpCardsNeeded
                    obj.faceUpCards = [obj.faceUpCards, obj.dealCard(randStream)];           
    
                    % Check to make sure the face up cards are not comprised of 
                    % too many multicolored cards.
                    % If there are more than the allowed number of multicolored
                    % cards facing up, discard all faceUpCards (note: this if 
                    % section should not have to be executed too often).
                    if (sum([obj.faceUpCards.color] == Color.multicolored) > obj.maxMulticoloredFaceUpAllowed)              
                        obj.discardPile = [obj.discardPile, obj.faceUpCards];
                        obj.faceUpCards = TrainCard.empty;
                    end % end of if "multicolored" block
                    obj.checkDrawPile(1, randStream);
                end % end of length of cards in face-up deck
            end % end of drawable()
        end % end of function

        function checkDrawPile(obj, nCards, randStream)
            % Checks if there are less than nCards in the drawPile, 
            % shuffle the discardPile into the drawPile. Note: 
            % This shall be run every time the drawPile is changed. 
            % This will ensure that, if the TrainDeck is drawable, 
            % the drawPile is always gets reshuffled when it falls 
            % below nCards.
            arguments
                obj TrainsDeck
                nCards {mustBeInteger}
                randStream
            end

            % If there are not nCards in the draw pile, then shuffle the
            % discardPile into the drawPile. (This would most often be used
            % when nCards = 0, => an empty drawPile.)
            if ~atLeastNCardsinDrawPile(obj,nCards)
                shuffle(obj, randStream);
            end

        end

        function tf = atLeastNCardsinDrawPile(obj, nCards)
            % This returns true if there are at least n Cards in the draw pile
            % This may be used when:
            % -- checking whether there are any cards left after putting cards
            % in the face-up deck
            % -- checking whether there are any cards in the deck after a
            % player draws a card from the drawPile
            arguments
                obj TrainsDeck
                nCards {mustBeInteger}
            end

            if (length(obj.drawPile) >= nCards)
                tf = true;
            else
                tf = false;
            end
        end
    end % private methods
end % end TrainsDeck
