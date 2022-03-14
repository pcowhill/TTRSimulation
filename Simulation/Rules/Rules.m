classdef Rules < handle
    %Rules Base rules class
    %   Abstract class that provides an interface to be implemented by subclasses

    properties (SetAccess=protected)
        startingTrains = 45 %number of trains each player starts with

        numStartingCards = 4 %number of cards each player starts with
    end

    methods (Abstract=true)
        initGameState(rules);
        [claimableRoutes, drawableCards, drawDestinationCards] = ...
                getPossibleActions(rules, player, board, trainsDeck, destinationsDeck, routesClaimed, cardsDrawn, drawnDestinations);
            %getPossibleActions Get all possible actions for this player
            %   Returns list of claimable routes, drawable cards, and
            %   whether or not the player can draw destination cards
            %   
            %   Inputs
            %
            % routesClaimed - routes claimed so far for this player's turn
            % cardsDrawn - cards drawn so far this turn
            % drawnDestinations - whether the player has drawn destination
            % cards

        over =  isTurnOver(rules, claimableRoutes, drawableCards, drawDestinationCards, route, card, destinations);
            %isTurnOver Returns true if the player's last action has caused
            %   their turn to be over.
            %
            %   Input Parameters
            %
            %   claimableRoutes - routes that were available to be claimed
            %   for the last action
            %
            %   drawableCards - train cards that were available to be drawn
            %   for the last action
            %
            %   drawDestinationCards - true if it was possible to draw
            %   destination cards for the last action
            %
            %   route - index of the route the player claimed last action;
            %   0 if no route was claimed
            %   
            %   card - index of the card the player drew last action; 0 if
            %   no card was drawn
            %
            %   destinations - true if the player drew destination cards
            %   last turn

        points = getRoutePoints(rules, route);
        %getRoutePoints Returns the number of victory points claiming the
        %given route is worth

        udpateGameState(rules, board, players, trainsDeck, destinationsDeck);
        %updateGameState Updates the internal state of the rules object for
        %determining the end of the game

        over = isGameOver(rules)
        %over Returns true if the game is over
    end

    methods (Access = protected)
        %getClaimableRoutes
        %   Returns a list of routes that are claimable given the player's
        %   current hand
        function routes = getClaimableRoutes(rules, player, board)
            % TODO
            routes = [BOSTON_TO_NEW_YORK_A];
        end
    end
end