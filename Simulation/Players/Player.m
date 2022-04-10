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

        publicHand TrainCard = TrainCard.empty

        allPlayers
    end

    methods (Access = public)
        function player = Player(playerNumber)
            %Player Construct a player
            %   Assign color
            player.color = Player.PlayerColors(playerNumber);
        end

        function takeTurn(player, rules, board, trainsDeck, destinationsDeck, logger)
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
                logger log4m
            end

            takenActions = struct();
            takenActions.routesClaimed = Route.empty;
            takenActions.cardsDrawn = TrainCard.empty;
            takenActions.destinationsDrawn = false;
            turnOver = false;

            while ~turnOver
                possibleActions = rules.getPossibleActions(player, board, trainsDeck, destinationsDeck, takenActions);
                if player.cannotTakeAction(possibleActions)
                    turnOver = true;
                else
                    chosenActions = player.chooseAction(board, possibleActions);
                    if isfield(chosenActions, 'route') && chosenActions.route > 0
                        player.claimRoute(rules, board, trainsDeck, possibleActions.claimableRoutes(chosenActions.route), possibleActions.claimableRouteColors(chosenActions.route), logger);
                        takenActions.routesClaimed = [takenActions.routesClaimed possibleActions.claimableRoutes(chosenActions.route)];
                    elseif isfield(chosenActions, 'card') && chosenActions.card > 0
                        takenActions.cardsDrawn = [takenActions.cardsDrawn possibleActions.drawableCards(chosenActions.card)];
                        player.drawTrainCard(trainsDeck, possibleActions.drawableCards(chosenActions.card), logger);
                    elseif isfield(chosenActions, 'drawDestinationCards') && chosenActions.drawDestinationCards
                        takenActions.destinationsDrawn=true;
                        player.drawDestinations(board,destinationsDeck, logger);

                    end
                    if rules.isTurnOver(possibleActions, takenActions)
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
        chosenAction = chooseAction(player, board, possibleActions);
        %chooseAction Returns [index of route to claim, index of card to
        % draw, whether to draw destination tickets] only one action will
        % be taken

        tf = cannotTakeAction(player, possibleActions);
        %cannotTakeAction return whether or not the player is unable to
        % take any of the possible actions provided to this method.

        keptCardIndices = chooseDestinationCards(player, board, destinationCards);
        %chooseDestinationCards returns the indices of the cards to keep

        initPlayerSpecific(player, startingHand, board, destinationsDeck, nStartingTrains);
    end

    methods (Sealed=true)
        function initPlayer(player, startingHand, board, destinationsDeck, nStartingTrains, players, logger)
            %initPlayer Get starting hand and choose destination cards
            arguments
                player Player
                startingHand TrainCard
                board Board
                destinationsDeck DestinationsDeck
                nStartingTrains
                players
                logger log4m
            end
            player.destinationCardsHand = DestinationTicketCard.empty;
            player.victoryPoints = 0;
            player.drawDestinations(board, destinationsDeck, logger);
            player.trainCardsHand = startingHand;
            player.nStartingTrains=nStartingTrains;
            player.allPlayers = players;
            
            player.initPlayerSpecific(startingHand, board, destinationsDeck, nStartingTrains);
        end
    end

    methods (Access=private, Sealed=true)
        function claimRoute(player, rules, board, trainsDeck, route, color, logger)
           board.claim(route, player.color);
           indicesToDiscard = [];
           
           nColorCards=0;
           nLocomotives=0;
           index = 1;
           % find the cards in the player hand to discard
           while length(indicesToDiscard) < route.length && index <= length(player.trainCardsHand) && color~=Color.multicolored
               if player.trainCardsHand(index).color == color
                   indicesToDiscard = [indicesToDiscard index];
                   trainsDeck.discard(player.trainCardsHand(index));
                   nColorCards = nColorCards+1;
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
                       nLocomotives = nLocomotives + 1;
                   end
                   index = index+1;
               end
           end
           publicHandIndices = [];
           for ix=1:length(player.publicHand)
               if player.publicHand(ix).color == color && nColorCards > 0
                   nColorCards = nColorCards - 1;
                   publicHandIndices = [publicHandIndices ix];
               elseif player.publicHand(ix).color == Color.multicolored && nLocomotives > 0
                   nLocomotives = nLocomotives - 1;
                   publicHandIndices = [publicHandIndices ix];
               end
           end

           player.publicHand(publicHandIndices) = [];
           assert(length(indicesToDiscard)==route.length && length(indicesToDiscard) == length(unique(indicesToDiscard)), "Player didn't discard number of cards to claim route");
           player.trainCardsHand(indicesToDiscard) = [];
           player.victoryPoints = player.victoryPoints + rules.getRoutePoints(route);
           activityLogStep = "claimed the route from " + string(route.locations(1)) + " to " + string(route.locations(2)) + " and earned " + rules.getRoutePoints(route) + " point(s).";
           logger.writePlayerTurnDetails("Claim Route","Player " + activityLogStep);
        end

        function drawTrainCard(player, trainsDeck, card, logger)
            drawnCard = trainsDeck.drawCard(card);
            player.trainCardsHand = [player.trainCardsHand drawnCard];
            player.publicHand = [player.publicHand drawnCard];
                 
            activityLogStep = "drew a " + string(card.color) + " card.";
            logger.writePlayerTurnDetails("Draw Train Card","Player " + activityLogStep);
        end

        function drawDestinations(player, board, destinationsDeck, logger)
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
            activityLogStep = "drew three destination cards: 1) " + ...
            string(cards(1).firstLocation) + " to " + string(cards(1).secondLocation) + ", 2) " +...
            string(cards(2).firstLocation) + " to " + string(cards(2).secondLocation) + ", and 3) " + ...
            string(cards(3).firstLocation) + " to " + string(cards(3).secondLocation) + ".";

            activityLogStep = activityLogStep + " Player chose card(s): " ;
            for i = 1:length(chosenCardsIndices)
                activityLogStep = activityLogStep + string(chosenCardsIndices(i));
                if i < length(chosenCardsIndices)
                    activityLogStep = activityLogStep + ", ";
                end
            end

            logger.writePlayerTurnDetails("Draw Destinations","Player " + activityLogStep);
            player.destinationCardsHand = [player.destinationCardsHand cards(chosenCardsIndices)];
            cards(chosenCardsIndices) = [];
            destinationsDeck.returnCards(cards);
        end
    end
end
