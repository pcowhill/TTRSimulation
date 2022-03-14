classdef DefaultRules < Rules
    %Rules Default set of rules
    %   Implements the default rules for the TTR base game

    properties (SetAccess = private)
        turnsRemaining = -1 %-1 means the end has not been triggered
    end

    methods
        function initGameState(rules)
            rules.turnsRemaining = -1;
        end

        function [claimableRoutes, drawableCards, drawDestinationCards] = ...
                getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, routesClaimed, cardsDrawn, drawnDestinations)
            arguments
                rules Rules
                player Player
                board Board
                trainsDeck TrainsDeck
                destinationsDeck DestinationsDeck
                routesClaimed Route
                cardsDrawn TrainCard
                drawnDestinations DestinationTicketCard
            end
            if ~isempty(routesClaimed) || length(cardsDrawn) > 1 || drawnDestinations
                % if the player has drawn two cards, claimed a route or
                % drawn destination cards, their turn is over and they have
                % no more possible actions
                claimableRoutes = [];
                drawableCards = [];
                drawDestinationCards = 0;
            else
                drawableCards = [trainsDeck.getFaceUpCards() TrainCard(Color.unknown)];
                if ~isempty(cardsDrawn)
                    %Don't allow the player to draw a locomotive as their
                    %second card
                    indicesToRemove = [];
                    for cardIndex = 1:length(drawableCards)
                        if drawableCards(cardIndex).color == Color.multicolored
                            indicesToRemove = [indicesToRemove cardIndex];
                        end
                    end
                    drawableCards(indicesToRemove) = [];

                    % Can only draw a card as second action
                    claimableRoutes = [];
                    drawDestinationCards = 0;
                else
                    if destinationsDeck.getCardsLeft() > 0
                        drawDestinationCards = 1;                
                    end
                    claimableRoutes = rules.getClaimableRoutes(player, board);
                end

                
            end
        end

        function over =  isTurnOver(rules, claimableRoutes, drawableCards, drawDestinationCards, route, card, destinations)
            % if the player claimed a route, drew a multiclor card, or drew
            % destination cards, their turn is over
            over = route > 0 || (card < length(drawableCards) && drawableCards(card).color == Color.MultiColor) || destinations;
        end

        function points = getRoutePoints(rules, route)
            %getRoutePoints Return the number of victory points the given
            %route is worth
            if route.length == 1
                points = 1;
            elseif route.length == 2
                points = 2;
            elseif route.length == 3
                points = 4;
            elseif routes.length == 4
                points = 7;
            elseif routes.length == 5
                points = 10;
            else
                points = 15;
            end
        end

        function udpateGameState(rules, board, players, trainsDeck, destinationsDeck)
            for p = 1:length(players)
                if rules.startingTrains - board.getNumOfTrains(players(p).color) <= 2
                    % if a player has two or less trains remaining,
                    % everyone gets one more turn before the game is over
                    if rules.turnsRemaining == -1
                        % -1 means the ending hasn't been triggered already
                        rules.turnsRemaining = length(players);
                    else
                        rules.turnsRemaining = rules.turnsRemaining - 1;
                    end
                end
            end
        end

        function over = isGameOver(rules)
            % turnsRemaining==0 only when the end condition is triggered
            % and everyone has taken their final turn
            over = rules.turnsRemaining ~= 0;
        end
    end
end