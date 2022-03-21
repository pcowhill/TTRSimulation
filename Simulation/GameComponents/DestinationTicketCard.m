classdef DestinationTicketCard
% DestinationTicketCard
% This type of card comprises two destination cities, and the Player earns 
% points by connecting a contiguous set of Routes between the cities with 
% their train pieces. The two cities will pull from the user-defined 
% Location objects. Players will choose at least 2 out of 3 destination 
% cards at the beginning of the game. During the game, if Players complete 
% the destination cards in their hand, they can choose to pick an additional 
% 1-3 destination cards. 

    properties (SetAccess = immutable)
        firstLocation Location  % first Location on destination card
        secondLocation Location % second Location on destination card
        pointValue {mustBeNumeric}    % integer amount of points a Player earns for completing the particular destination card
    end

    methods

        function obj = DestinationTicketCard(inFirstLocation, inSecondLocation, inPoints)
            % DestionationTicketCard Constructor
            % Creates a DestionationTicketCard object and defines the
            % properties with two Location objects and 1 integer object
            arguments
                inFirstLocation Location
                inSecondLocation Location
                inPoints {mustBeNumeric}
            end
    
            % Assign properties to DestinationTicketCard object
            obj.firstLocation = inFirstLocation;  % first Location on destination card   
            obj.secondLocation = inSecondLocation;  % second Location on destination card   
            obj.pointValue = inPoints;  % points card is worth
        end
    end
end
