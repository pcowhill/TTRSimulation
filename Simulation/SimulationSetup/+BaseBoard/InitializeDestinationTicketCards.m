% initializeDestinationTicketCards
% Defines variables (with the intention of acting as global variables) that
% refer to the standard destination ticket cards used in TTR.
%                                 References
% List of Ticket to Ride Destination Tickets. (n.d.). 
% Retrieved from Fandom: https://ticket-to-ride.fandom.com/wiki/List_of_Ticket_to_Ride_Destination_Tickets

% number of ticket destination cards in the game
NUM_DESTINATION_TICKET_CARDS = 30; 

% Initialize all ticket destination cards in the game
DEST_BOSTON_MIAMI = DestinationTicketCard(Location.Boston, Location.Miami, 12);
DEST_CALGARY_PHOENIX = DestinationTicketCard(Location.Calgary, Location.Phoenix, 13);
DEST_CALGARY_SALT_LAKE_CITY = DestinationTicketCard(Location.Calgary, Location.Salt_Lake_City, 7);
DEST_CHICAGO_NEW_ORLEANS = DestinationTicketCard(Location.Chicago, Location.New_Orleans, 7);
DEST_CHICAGO_SANTA_FE = DestinationTicketCard(Location.Chicago, Location.Santa_Fe, 9);
DEST_DALLAS_NEW_YORK = DestinationTicketCard(Location.Dallas, Location.New_York, 11);
DEST_DENVER_EL_PASO = DestinationTicketCard(Location.Denver, Location.El_Paso, 4);
DEST_DENVER_PITTSBURGH = DestinationTicketCard(Location.Denver, Location.Pittsburgh, 11);
DEST_DULUTH_EL_PASO = DestinationTicketCard(Location.Duluth, Location.El_Paso, 10);
DEST_DULUTH_HOUSTON = DestinationTicketCard(Location.Duluth, Location.Houston, 8);
DEST_HELENA_LOS_ANGELES = DestinationTicketCard(Location.Helena, Location.Los_Angeles, 8);
DEST_KANSAS_CITY_HOUSTON = DestinationTicketCard(Location.Kansas_City, Location.Houston, 5);
DEST_LOS_ANGELES_CHICAGO = DestinationTicketCard(Location.Los_Angeles, Location.Chicago, 16);
DEST_LOS_ANGELES_MIAMI = DestinationTicketCard(Location.Los_Angeles, Location.Miami, 20);
DEST_LOS_ANGELES_NEW_YORK = DestinationTicketCard(Location.Los_Angeles, Location.New_York, 21);
DEST_MONTREAL_ATLANTA = DestinationTicketCard(Location.Montreal, Location.Atlanta, 9);
DEST_MONTREAL_NEW_ORLEANS = DestinationTicketCard(Location.Montreal, Location.New_Orleans, 13);
DEST_NEW_YORK_ATLANTA = DestinationTicketCard(Location.New_York, Location.Atlanta, 6);
DEST_PORTLAND_NASHVILLE = DestinationTicketCard(Location.Portland, Location.Nashville, 17);
DEST_PORTLAND_PHOENIX = DestinationTicketCard(Location.Portland, Location.Phoenix, 11);
DEST_SAN_FRANCISCO_ATLANTA = DestinationTicketCard(Location.San_Francisco, Location.Atlanta, 17);
DEST_SAULT_ST_MARIE_NASHVILLE = DestinationTicketCard(Location.Sault_St_Marie, Location.Nashville, 8);
DEST_SAULT_ST_MARIE_OKLAHOMA_CITY = DestinationTicketCard(Location.Sault_St_Marie, Location.Oklahoma_City, 9);
DEST_SEATTLE_LOS_ANGELES = DestinationTicketCard(Location.Seattle, Location.Los_Angeles, 9);
DEST_SEATTLE_NEW_YORK = DestinationTicketCard(Location.Seattle, Location.New_York, 22);
DEST_TORONTO_MIAMI = DestinationTicketCard(Location.Toronto, Location.Miami, 10);
DEST_VANCOUVER_MONTREAL = DestinationTicketCard(Location.Vancouver, Location.Montreal, 20);
DEST_VANCOUVER_SANTA_FE = DestinationTicketCard(Location.Vancouver, Location.Santa_Fe, 13);
DEST_WINNIPEG_HOUSTON = DestinationTicketCard(Location.Winnipeg, Location.Houston, 12);
DEST_WINNIPEG_LITTLE_ROCK = DestinationTicketCard(Location.Winnipeg, Location.Little_Rock, 11);

DESTINATIONS_DECK = DestinationsDeck(DEST_BOSTON_MIAMI, DEST_CALGARY_PHOENIX, DEST_CALGARY_SALT_LAKE_CITY, DEST_CHICAGO_NEW_ORLEANS, DEST_CHICAGO_SANTA_FE, DEST_DALLAS_NEW_YORK, DEST_DENVER_EL_PASO, DEST_DENVER_PITTSBURGH, DEST_DULUTH_EL_PASO, DEST_DULUTH_HOUSTON, DEST_HELENA_LOS_ANGELES, DEST_KANSAS_CITY_HOUSTON, DEST_LOS_ANGELES_CHICAGO, DEST_LOS_ANGELES_MIAMI, DEST_LOS_ANGELES_NEW_YORK, DEST_MONTREAL_ATLANTA, DEST_MONTREAL_NEW_ORLEANS, DEST_NEW_YORK_ATLANTA, DEST_PORTLAND_NASHVILLE, DEST_PORTLAND_PHOENIX, DEST_SAN_FRANCISCO_ATLANTA, DEST_SAULT_ST_MARIE_NASHVILLE, DEST_SAULT_ST_MARIE_OKLAHOMA_CITY, DEST_SEATTLE_LOS_ANGELES, DEST_SEATTLE_NEW_YORK, DEST_TORONTO_MIAMI, DEST_VANCOUVER_MONTREAL, DEST_VANCOUVER_SANTA_FE, DEST_WINNIPEG_HOUSTON, DEST_WINNIPEG_LITTLE_ROCK);

