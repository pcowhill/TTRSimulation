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
        firstLocation  % first Location on destination card
        secondLocation % second Location on destination card
        pointValue     % integer amount of points a Player earns for completing the particular destination card
    end
    methods
        % parameters are of class Location and points are integer
        function obj = DestinationTicketCard(inFirstLocation, inSecondLocation, inPoints)
            % DestionationTicketCard Constructor
            % Creates a DestionationTicketCard object and defines the
            % properties with two Location objects and 1 integer object

            % Check that the corrrect number of arguments was given to the
            % constructor
            assert(nargin == 3, "A destination ticket card must have 3 input arguments: " + ...
                    "2 paramaters of class Location, representing the two " + ...
                    "destination cities, and a third integer parameter, " + ...
                    "representing the number of points.")

            % Check that the objects sent to the constructor are of the
            % correct data type
            assert(string(class(inFirstLocation)) == "Location", ...
                "The first parameter of the DestinationTicketCard constructor was not an object of the Location class.")
            assert(string(class(inSecondLocation)) == "Location", ...
                "The second parameter of the DestinationTicketCard constructor was not an object of the Location class.")
            assert(or(string(class(inPoints)) == "int8",string(class(inPoints)) == "int16"), ...
                "The third parameter of the DestinationTicketCard constructor must be of the type int8 or int16.")

            % Assign properties to DestinationTicketCard object
            obj.firstLocation = inFirstLocation;  % first Location on destination car   
            obj.secondLocation = inSecondLocation;  % second Location on destination car   
            obj.pointValue = inPoints;  % points a destination card is worth
        end
    end
end
