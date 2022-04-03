classdef Player < handle & matlab.mixin.Heterogeneous
    %Player Base class
    %   Abstract class for player agents. Subclasses can override 

    properties (Constant)
        PlayerColors = [Color.red Color.yellow Color.green Color.blue]
    end

    properties (SetAccess = immutable)
        color
    end

    properties (SetAccess = private)
        trainCardsHand TrainCard = TrainCard.empty

        destinationCardsHand DestinationTicketCard = DestinationTicketCard.empty

        victoryPoints = 0

        nStartingTrains = 0

        allPlayers
    end

    methods (Access = public)
        function player = Player(playerNumber)
            %Player Construct a player
            %   Assign color
            player.color = Player.PlayerColors(playerNumber);
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
            routesClaimed = Route.empty;
            cardsDrawn = TrainCard.empty;
            destinationsDrawn=false;
            turnOver = false;

            while ~turnOver
                [claimableRoutes, claimableRouteColors, drawableCards, canDrawDestinationCards] = rules.getPossibleActions(player, board, trainsDeck, destinationsDeck, routesClaimed, cardsDrawn, destinationsDrawn);
                if isempty(claimableRoutes) && isempty(drawableCards) && ~canDrawDestinationCards
                    turnOver = true;
                else
                    [route, card, drawDestinationCards] = player.chooseAction(board, claimableRoutes, claimableRouteColors, drawableCards, canDrawDestinationCards);
                    if route > 0
                        player.claimRoute(rules, board, trainsDeck, claimableRoutes(route), claimableRouteColors(route));
                        routesClaimed=[routesClaimed claimableRoutes(route)];
                    elseif card > 0
                        cardsDrawn = [cardsDrawn drawableCards(card)];
                        player.drawTrainCard(trainsDeck, drawableCards(card));
                    elseif drawDestinationCards
                        destinationsDrawn=true;
                        player.drawDestinations(board,destinationsDeck);
                    end
                    if rules.isTurnOver(claimableRoutes, drawableCards, canDrawDestinationCards, routesClaimed, cardsDrawn, destinationsDrawn)
                        turnOver = true;
                    end
                end
            end

        end

    end

    methods (Sealed=true)
        function addToVictoryPoints(player, points)
            player.victoryPoints = player.victoryPoints+points;
        end

        
    end


    methods (Abstract)
        [route, card, drawDestinationCards] = chooseAction(player, board, claimableRoutes, claimableRouteColors, drawableCards, canDrawDestinationCards);
        %chooseAction Returns [index of route to claim, index of card to
        % draw, whether to draw destination tickets] only one action will
        % be taken
        keptCardIndices = chooseDestinationCards(player, board, destinationCards);
        %chooseDestinationCards returns the indices of the cards to keep

        initPlayerSpecific(player, startingHand, board, destinationsDeck, nStartingTrains);
    end

    methods (Sealed=true)
        function initPlayer(player, startingHand, board, destinationsDeck, nStartingTrains, players)
            %initPlayer Get starting hand and choose destination cards
            arguments
                player Player
                startingHand TrainCard
                board Board
                destinationsDeck DestinationsDeck
                nStartingTrains
                players
            end
            player.destinationCardsHand = DestinationTicketCard.empty;
            player.victoryPoints = 0;
            player.drawDestinations(board, destinationsDeck);
            player.trainCardsHand = startingHand;
            player.nStartingTrains=nStartingTrains;
            player.allPlayers = players;

            player.initPlayerSpecific(startingHand, board, destinationsDeck, nStartingTrains);
        end
    end


    methods (Access=private, Sealed=true)
        function claimRoute(player, rules, board, trainsDeck, route, color)
           board.claim(route, player.color);
           indicesToDiscard = [];
           index = 1;
           % find the cards in the player hand to discard
           while length(indicesToDiscard) < route.length && index <= length(player.trainCardsHand) && color~=Color.multicolored
               if player.trainCardsHand(index).color == color
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

           assert(length(indicesToDiscard)==route.length && length(indicesToDiscard) == length(unique(indicesToDiscard)), "Player didn't discard number of cards to claim route");
           player.trainCardsHand(indicesToDiscard) = [];
           player.victoryPoints = player.victoryPoints + rules.getRoutePoints(route);
        end

        function drawTrainCard(player, trainsDeck, card)
            player.trainCardsHand = [player.trainCardsHand trainsDeck.drawCard(card)];
        end

        function drawDestinations(player, board, destinationsDeck)
            cards = destinationsDeck.draw(3);
            chosenCardsIndices = player.chooseDestinationCards(board, cards);
            if isempty(player.destinationCardsHand)
                if length(chosenCardsIndices) < 2
                    chosenCardsIndices = [1 2];
                end
            else
                if isempty(chosenCardsIndices)
                    chosenCardsIndices=1;
                end
            end
            player.destinationCardsHand = [player.destinationCardsHand cards(chosenCardsIndices)];
            cards(chosenCardsIndices) = [];
            destinationsDeck.returnCards(cards);
        end
    end
end