% initializeBoard
% Creates BOARD, an object of type Board which has the default layout of
% the board in Ticket to Ride.

if ~exist('INITIALIZE_BOARD_M', 'var')

    INITIALIZE_BOARD_M = true;

    initializeRoutes;

    BOARD = Board(ROUTE_ATLANTA_TO_CHARLESTON, ...
                  ROUTE_ATLANTA_TO_MIAMI, ...
                  ROUTE_ATLANTA_TO_NASHVILLE, ...
                  ROUTE_ATLANTA_TO_NEW_ORLEANS_A, ...
                  ROUTE_ATLANTA_TO_NEW_ORLEANS_B, ...
                  ROUTE_ATLANTA_TO_RALEIGH_A, ...
                  ROUTE_ATLANTA_TO_RALEIGH_B, ...
                  ROUTE_BOSTON_TO_MONTREAL_A, ...
                  ROUTE_BOSTON_TO_MONTREAL_B, ...
                  ROUTE_BOSTON_TO_NEW_YORK_A, ...
                  ROUTE_BOSTON_TO_NEW_YORK_B, ...
                  ROUTE_CALGARY_TO_HELENA, ...
                  ROUTE_CALGARY_TO_SEATTLE, ...
                  ROUTE_CALGARY_TO_VANCOUVER, ...
                  ROUTE_CALGARY_TO_WINNIPEG, ...
                  ROUTE_CHARLESTON_TO_MIAMI, ...
                  ROUTE_CHARLESTON_TO_RALEIGH, ...
                  ROUTE_CHICAGO_TO_DULUTH, ...
                  ROUTE_CHICAGO_TO_OMAHA, ...
                  ROUTE_CHICAGO_TO_PITTSBURG_A, ...
                  ROUTE_CHICAGO_TO_PITTSBURG_B, ...
                  ROUTE_CHICAGO_TO_SAINT_LOUIS_A, ...
                  ROUTE_CHICAGO_TO_SAINT_LOUIS_B, ...
                  ROUTE_CHICAGO_TO_TORONTO, ...
                  ROUTE_DALLAS_TO_EL_PASO, ...
                  ROUTE_DALLAS_TO_HOUSTON_A, ...
                  ROUTE_DALLAS_TO_HOUSTON_B, ...
                  ROUTE_DALLAS_TO_LITTLE_ROCK, ...
                  ROUTE_DALLAS_TO_OKLAHOMA_CITY_A, ...
                  ROUTE_DALLAS_TO_OKLAHOMA_CITY_B, ...
                  ROUTE_DENVER_TO_HELENA, ...
                  ROUTE_DENVER_TO_KANSAS_CITY_A, ...
                  ROUTE_DENVER_TO_KANSAS_CITY_B, ...
                  ROUTE_DENVER_TO_OKLAHOMA_CITY, ...
                  ROUTE_DENVER_TO_OMAHA, ...
                  ROUTE_DENVER_TO_PHOENIX, ...
                  ROUTE_DENVER_TO_SALT_LAKE_CITY_A, ...
                  ROUTE_DENVER_TO_SALT_LAKE_CITY_B, ...
                  ROUTE_DENVER_TO_SANTA_FE, ...
                  ROUTE_DULUTH_TO_HELENA, ...
                  ROUTE_DULUTH_TO_OMAHA_A, ...
                  ROUTE_DULUTH_TO_OMAHA_B, ...
                  ROUTE_DULUTH_TO_SAULT_ST_MARIE, ...
                  ROUTE_DULUTH_TO_TORONTO, ...
                  ROUTE_DULUTH_TO_WINNIPEG, ...
                  ROUTE_EL_PASO_TO_HOUSTON, ...
                  ROUTE_EL_PASO_TO_LOS_ANGELES, ...
                  ROUTE_EL_PASO_TO_OKLAHOMA_CITY, ...
                  ROUTE_EL_PASO_TO_PHOENIX, ...
                  ROUTE_EL_PASO_TO_SANTA_FE, ...
                  ROUTE_HELENA_TO_OMAHA, ...
                  ROUTE_HELENA_TO_SALT_LAKE_CITY, ...
                  ROUTE_HELENA_TO_SEATTLE, ...
                  ROUTE_HELENA_TO_WINNIPEG, ...
                  ROUTE_HOUSTON_TO_NEW_ORLEANS, ...
                  ROUTE_KANSAS_CITY_TO_OKLAHOMA_CITY_A, ...
                  ROUTE_KANSAS_CITY_TO_OKLAHOMA_CITY_B, ...
                  ROUTE_KANSAS_CITY_TO_OMAHA_A, ...
                  ROUTE_KANSAS_CITY_TO_OMAHA_B, ...
                  ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_A, ...
                  ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B, ...
                  ROUTE_LAS_VEGAS_TO_LOS_ANGELES, ...
                  ROUTE_LAS_VEGAS_TO_SALT_LAKE_CITY, ...
                  ROUTE_LOS_ANGELES_TO_PHOENIX, ...
                  ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_A, ...
                  ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B, ...
                  ROUTE_LITTLE_ROCK_TO_NASHVILLE, ...
                  ROUTE_LITTLE_ROCK_TO_NEW_ORLEANS, ...
                  ROUTE_LITTLE_ROCK_TO_OKLAHOMA_CITY, ...
                  ROUTE_LITTLE_ROCK_TO_SAINT_LOUIS, ...
                  ROUTE_MIAMI_TO_NEW_ORLEANS, ...
                  ROUTE_MONTREAL_TO_NEW_YORK, ...
                  ROUTE_MONTREAL_TO_SAULT_ST_MARIE, ...
                  ROUTE_MONTREAL_TO_TORONTO, ...
                  ROUTE_NASHVILLE_TO_PITTSBURG, ...
                  ROUTE_NASHVILLE_TO_RALEIGH, ...
                  ROUTE_NASHVILLE_TO_SAINT_LOUIS, ...
                  ROUTE_NEW_YORK_TO_PITTSBURG_A, ...
                  ROUTE_NEW_YORK_TO_PITTSBURG_B, ...
                  ROUTE_NEW_YORK_TO_WASHINGTON_DC_A, ...
                  ROUTE_NEW_YORK_TO_WASHINGTON_DC_B, ...
                  ROUTE_OKLAHOMA_CITY_TO_SANTA_FE, ...
                  ROUTE_PHOENIX_TO_SANTA_FE, ...
                  ROUTE_PITTSBURG_TO_RALEIGH, ...
                  ROUTE_PITTSBURG_TO_SAINT_LOUIS, ...
                  ROUTE_PITTSBURG_TO_TORONTO, ...
                  ROUTE_PITTSBURG_TO_WASHINGTON_DC, ...
                  ROUTE_PORTLAND_TO_SALT_LAKE_CITY, ...
                  ROUTE_PORTLAND_TO_SAN_FRANCISCO_A, ...
                  ROUTE_PORTLAND_TO_SAN_FRANCISCO_B, ...
                  ROUTE_PORTLAND_TO_SEATTLE_A, ...
                  ROUTE_PORTLAND_TO_SEATTLE_B, ...
                  ROUTE_RALEIGH_TO_WASHINGTON_DC_A, ...
                  ROUTE_RALEIGH_TO_WASHINGTON_DC_B, ...
                  ROUTE_SALT_LAKE_CITY_TO_SAN_FRANCISCO_A, ...
                  ROUTE_SALT_LAKE_CITY_TO_SAN_FRANCISCO_B, ...
                  ROUTE_SAULT_ST_MARIE_TO_TORONTO, ...
                  ROUTE_SAULT_ST_MARIE_TO_WINNIPEG, ...
                  ROUTE_SEATTLE_TO_VANCOUVER_A, ...
                  ROUTE_SEATTLE_TO_VANCOUVER_B);

end