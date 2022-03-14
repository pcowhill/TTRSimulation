classdef Player < handle
    %Player Base class
    %   Abstract class for player agents. Subclasses can override 

    properties (SetAccess = immutable)
        color
    end

    properties (SetAccess = private)
        trainCardsHand TrainCard = []

        destinationCardsHand DestinationTicketCard = []

        victoryPoints = 0
    end

    methods (Access = public)
        function player = Player(color)
            %Player Construct a player
            %   Assign color and choose destination cards
            player.color = color;
        end

        function takeTurn(player, rules, board, trainsDeck, destinationsDeck)
            %takeTurn Carry out a single turn
            %   Carry out chosen action using the provided board and decks.
            %   Assume board and decks are Handle type classes so they
            %   exhibit pass-by-refrence like behavior
            %   https://www.mathworks.com/help/matlab/handle-classes.html
            arguments
                player Player
                rules Rules
                board Board
                trainsDeck TrainsDeck
                destinationsDeck DestinationsDeck
            end
            routesClaimed = [];
            cardsDrawn = [];
            drawnDestinations = 0;
            turnOver = false;

            while ~turnOver
                [claimableRoutes, drawableCards, drawDestinationCards] = rules.getPossibleActions(player, board, trainsDeck, destinationsDeck, routesClaimed, cardsDrawn, drawnDestinations);
                if isempty(claimableRoutes) && isempty(drawableCards) && ~drawDestinationCards
                    turnOver = true;
                else
                    [route, card, destination] = player.chooseAction(board, claimableRoutes, drawableCards, drawDestinationCards);
                    if route > 0
                        player.claimRoute(rules, board, trainsDeck, claimableRoutes(route));
                    elseif card > 0
                        player.drawTrainCard(trainsDeck, card);
                    elseif destination
                        player.drawDestinations(destinationsDeck);
                    end
                    if rules.isTurnOver(claimableRoutes, drawableCards, drawDestinationCards, route, card, destinations)
                        turnOver = true;
                    end
                end
            end

        end

        function [route, card, destination] = chooseAction(player, board, claimableRoutes, drawableCards, drawDestinationCards)
            arguments
                player Player
                board Board
                claimableRoutes Route
                drawableCards TrainCard
                drawDestinationCards
            end
            [route, card, destination] = player.chooseActionImpl(player, board, claimableRoutes, drawableCards, drawDestinationCards);
        end

        function keptCardIndices = chooseDestinationCards(player, board, destinationCards)
            arguments
                player Player
                board Board
                destinationCards DestinationTicketCard
            end

            keptCardIndices = player.chooseDestinationCardsImpl(player, board, destinationCards);

        end
    end

    methods (Sealed=true)
        function initPlayer(player, startingHand)
            arguments
                player Player
                startingHand TrainCard
            end
            player.destinationCardsHand = [];
            player.victoryPoints = 0;
            player.drawDestinations(destinationsDeck);
            player.trainCardsHand = startingHand;
        end
    end

    methods (Abstract)
        [route, card, destination] = chooseActionImpl(player, board, claimableRoutes, drawableCards, drawDestinationCards);
        %chooseAction Returns [index of route to claim, index of card to
        % draw, whether to draw destination tickets] only one action will
        % be taken
        keptCardIndices = chooseDestinationCardsImpl(player, board, destinationCards);
        %chooseDestinationCards returns the indices of the cards to keep
    end


    methods (Access=private, Sealed=true)
        function claimRoute(player, rules, board, trainsDeck, route)
           board.claim(route, player.color);
           indicesToDiscard = [];
           index = 1;
           % find the cards in the player hand to discard
           while length(indicesToDiscard) < route.length && index <= length(player.trainCardsHand)
               if player.trainCardsHand(index).color == route.color
                   indicesToDiscard = [indicesToDiscard index];
                   trainsDeck.discard(player.trainCardsHand(index));
               end
               index = index+1;
           end
           if length(indicesToDiscard) < route.length
               index = 1;
               % use locomotives for remaining cards
               while length(indicesToDiscard) < route.length && index <= length(player.trainCardsHand)
                   if player.trainCardsHand(index).color == Color.multicolored
                       indicesToDiscard = [indicesToDiscard index];
                       trainsDeck.discard(player.trainCardsHand(index));
                   end
                   index = index+1;
               end
           end
           player.trainCardsHand(indicesToDiscard) = [];
           player.victoryPoints = player.victoryPoints + rules.getRoutePoints(route);
        end

        function drawTrainCard(player, trainsDeck, card)
            player.trainCardsHand.append(trainsDeck.drawCard(card));
        end

        function drawDestinations(player, destinationsDeck)
            cards = destinationsDeck.draw(3);
            chosenCardsIndices = player.chooseDestinationCards(cards);
            if isempty(chosenCardsIndices)
                chosenCardsIndices = 1;
            end
            player.destinationCardsHand.append(cards(chosenCardsIndices));
            cards(chosenCardsIndices) = [];
            destinationsDeck.returnCards(cards);
        end
    end
end