% initializeRoutes
% Defines variables (with the intention of acting as global variables) that
% refer to the standard colors used in TTR.

% If these variables have already been initialized, the code in this file
% is skipped.
if ~exist('INITIALIZE_ROUTES_M', 'var')

    INITIALIZE_ROUTES_M = true;

    initializeColors;
    initializeLocations;

    IntCounter.setget(1);

    % Initialize the routes organized alphabetically
    % Patrick Note: The first location in the variable name and in the
    % Route contructor is the location that appears first alphabetically.
    % Also, cities that have multiple routes between them are appended with
    % _A and _B to distinguish them (even if they are the same color).  If
    % they are different colors, they will be organized by the order of the
    % colors in the instructions.

    ROUTE_ATLANTA_TO_CHARLESTON = Route(ATLANTA, CHARLESTON, GRAY, 2);
    ROUTE_ATLANTA_TO_MIAMI = Route(ATLANTA, MIAMI, BLUE, 5);
    ROUTE_ATLANTA_TO_NASHVILLE = Route(ATLANTA, NASHVILLE, GRAY, 1);
    ROUTE_ATLANTA_TO_NEW_ORLEANS_A = Route(ATLANTA, NEW_ORLEANS, ORANGE, 4);
    ROUTE_ATLANTA_TO_NEW_ORLEANS_B = Route(ATLANTA, NEW_ORLEANS, YELLOW, 4);
    ROUTE_ATLANTA_TO_RALEIGH_A = Route(ATLANTA, RALEIGH, GRAY, 2);
    ROUTE_ATLANTA_TO_RALEIGH_B = Route(ATLANTA, RALEIGH, GRAY, 2);

    ROUTE_BOSTON_TO_MONTREAL_A = Route(BOSTON, MONTREAL, GRAY, 2);
    ROUTE_BOSTON_TO_MONTREAL_B = Route(BOSTON, MONTREAL, GRAY, 2);
    ROUTE_BOSTON_TO_NEW_YORK_A = Route(BOSTON, NEW_YORK, YELLOW, 2);
    ROUTE_BOSTON_TO_NEW_YORK_B = Route(BOSTON, NEW_YORK, RED, 2);

    ROUTE_CALGARY_TO_HELENA = Route(CALGARY, HELENA, GRAY, 4);
    ROUTE_CALGARY_TO_SEATTLE = Route(CALGARY, SEATTLE, GRAY, 4);
    ROUTE_CALGARY_TO_VANCOUVER = Route(CALGARY, VANCOUVER, GRAY, 3);
    ROUTE_CALGARY_TO_WINNIPEG = Route(CALGARY, WINNIPEG, WHITE, 6);

    ROUTE_CHARLESTON_TO_MIAMI = Route(CHARLESTON, MIAMI, PURPLE, 4);
    ROUTE_CHARLESTON_TO_RALEIGH = Route(CHARLESTON, RALEIGH, GRAY, 2);
    
    ROUTE_CHICAGO_TO_DULUTH = Route(CHICAGO, DULUTH, RED, 3);
    ROUTE_CHICAGO_TO_OMAHA = Route(CHICAGO, OMAHA, BLUE, 4);
    ROUTE_CHICAGO_TO_PITTSBURGH_A = Route(CHICAGO, PITTSBURGH, ORANGE, 3);
    ROUTE_CHICAGO_TO_PITTSBURGH_B = Route(CHICAGO, PITTSBURGH, BLACK, 3);
    ROUTE_CHICAGO_TO_SAINT_LOUIS_A = Route(CHICAGO, SAINT_LOUIS, WHITE, 2);
    ROUTE_CHICAGO_TO_SAINT_LOUIS_B = Route(CHICAGO, SAINT_LOUIS, GREEN, 2);
    ROUTE_CHICAGO_TO_TORONTO = Route(CHICAGO, TORONTO, WHITE, 4);

    ROUTE_DALLAS_TO_EL_PASO = Route(DALLAS, EL_PASO, RED, 4);
    ROUTE_DALLAS_TO_HOUSTON_A = Route(DALLAS, HOUSTON, GRAY, 1);
    ROUTE_DALLAS_TO_HOUSTON_B = Route(DALLAS, HOUSTON, GRAY, 1);
    ROUTE_DALLAS_TO_LITTLE_ROCK = Route(DALLAS, LITTLE_ROCK, GRAY, 2);
    ROUTE_DALLAS_TO_OKLAHOMA_CITY_A = Route(DALLAS, OKLAHOMA_CITY, GRAY, 2);
    ROUTE_DALLAS_TO_OKLAHOMA_CITY_B = Route(DALLAS, OKLAHOMA_CITY, GRAY, 2);

    ROUTE_DENVER_TO_HELENA = Route(DENVER, HELENA, GREEN, 4);
    ROUTE_DENVER_TO_KANSAS_CITY_A = Route(DENVER, KANSAS_CITY, ORANGE, 4);
    ROUTE_DENVER_TO_KANSAS_CITY_B = Route(DENVER, KANSAS_CITY, BLACK, 4);
    ROUTE_DENVER_TO_OKLAHOMA_CITY = Route(DENVER, OKLAHOMA_CITY, RED, 4);
    ROUTE_DENVER_TO_OMAHA = Route(DENVER, OMAHA, PURPLE, 4);
    ROUTE_DENVER_TO_PHOENIX = Route(DENVER, PHOENIX, WHITE, 5);
    ROUTE_DENVER_TO_SALT_LAKE_CITY_A = Route(DENVER, SALT_LAKE_CITY, YELLOW, 3);
    ROUTE_DENVER_TO_SALT_LAKE_CITY_B = Route(DENVER, SALT_LAKE_CITY, RED, 3);
    ROUTE_DENVER_TO_SANTA_FE = Route(DENVER, SANTA_FE, GRAY, 2);

    ROUTE_DULUTH_TO_HELENA = Route(DULUTH, HELENA, ORANGE, 6);
    ROUTE_DULUTH_TO_OMAHA_A = Route(DULUTH, OMAHA, GRAY, 2);
    ROUTE_DULUTH_TO_OMAHA_B = Route(DULUTH, OMAHA, GRAY, 2);
    ROUTE_DULUTH_TO_SAULT_ST_MARIE = Route(DULUTH, SAULT_ST_MARIE, GRAY, 3);
    ROUTE_DULUTH_TO_TORONTO = Route(DULUTH, TORONTO, PURPLE, 6);
    ROUTE_DULUTH_TO_WINNIPEG = Route(DULUTH, WINNIPEG, BLACK, 4);

    ROUTE_EL_PASO_TO_HOUSTON = Route(EL_PASO, HOUSTON, GREEN, 6);
    ROUTE_EL_PASO_TO_LOS_ANGELES = Route(EL_PASO, LOS_ANGELES, BLACK, 6);
    ROUTE_EL_PASO_TO_OKLAHOMA_CITY = Route(EL_PASO, OKLAHOMA_CITY, YELLOW, 5);
    ROUTE_EL_PASO_TO_PHOENIX = Route(EL_PASO, PHOENIX, GRAY, 3);
    ROUTE_EL_PASO_TO_SANTA_FE = Route(EL_PASO, SANTA_FE, GRAY, 2);

    ROUTE_HELENA_TO_OMAHA = Route(HELENA, OMAHA, RED, 5);
    ROUTE_HELENA_TO_SALT_LAKE_CITY = Route(HELENA, SALT_LAKE_CITY, PURPLE, 3);
    ROUTE_HELENA_TO_SEATTLE = Route(HELENA, SEATTLE, YELLOW, 6);
    ROUTE_HELENA_TO_WINNIPEG = Route(HELENA, WINNIPEG, BLUE, 4);

    ROUTE_HOUSTON_TO_NEW_ORLEANS = Route(HOUSTON, NEW_ORLEANS, GRAY, 2);

    ROUTE_KANSAS_CITY_TO_OKLAHOMA_CITY_A = Route(KANSAS_CITY, OKLAHOMA_CITY, GRAY, 2);
    ROUTE_KANSAS_CITY_TO_OKLAHOMA_CITY_B = Route(KANSAS_CITY, OKLAHOMA_CITY, GRAY, 2);
    ROUTE_KANSAS_CITY_TO_OMAHA_A = Route(KANSAS_CITY, OMAHA, GRAY, 1);
    ROUTE_KANSAS_CITY_TO_OMAHA_B = Route(KANSAS_CITY, OMAHA, GRAY, 1);
    ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_A = Route(KANSAS_CITY, SAINT_LOUIS, PURPLE, 2);
    ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B = Route(KANSAS_CITY, SAINT_LOUIS, BLUE, 2);
    
    ROUTE_LAS_VEGAS_TO_LOS_ANGELES = Route(LAS_VEGAS, LOS_ANGELES, GRAY, 2);
    ROUTE_LAS_VEGAS_TO_SALT_LAKE_CITY = Route(LAS_VEGAS, SALT_LAKE_CITY, ORANGE, 3);

    ROUTE_LOS_ANGELES_TO_PHOENIX = Route(LOS_ANGELES, PHOENIX, GRAY, 3);
    ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_A = Route(LOS_ANGELES, SAN_FRANCISCO, PURPLE, 3);
    ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B = Route(LOS_ANGELES, SAN_FRANCISCO, PURPLE, 3);
    
    ROUTE_LITTLE_ROCK_TO_NASHVILLE = Route(LITTLE_ROCK, NASHVILLE, WHITE, 3);
    ROUTE_LITTLE_ROCK_TO_NEW_ORLEANS = Route(LITTLE_ROCK, NEW_ORLEANS, GREEN, 3);
    ROUTE_LITTLE_ROCK_TO_OKLAHOMA_CITY = Route(LITTLE_ROCK, OKLAHOMA_CITY, GRAY, 2);
    ROUTE_LITTLE_ROCK_TO_SAINT_LOUIS = Route(LITTLE_ROCK, SAINT_LOUIS, GRAY, 2);

    ROUTE_MIAMI_TO_NEW_ORLEANS = Route(MIAMI, NEW_ORLEANS, RED, 6);

    ROUTE_MONTREAL_TO_NEW_YORK = Route(MONTREAL, NEW_YORK, BLUE, 3);
    ROUTE_MONTREAL_TO_SAULT_ST_MARIE = Route(MONTREAL, SAULT_ST_MARIE, BLACK, 5);
    ROUTE_MONTREAL_TO_TORONTO = Route(MONTREAL, TORONTO, GRAY, 3);

    ROUTE_NASHVILLE_TO_PITTSBURGH = Route(NASHVILLE, PITTSBURGH, YELLOW, 4);
    ROUTE_NASHVILLE_TO_RALEIGH = Route(NASHVILLE, RALEIGH, BLACK, 3);
    ROUTE_NASHVILLE_TO_SAINT_LOUIS = Route(NASHVILLE, SAINT_LOUIS, GRAY, 2);

    ROUTE_NEW_YORK_TO_PITTSBURGH_A = Route(NEW_YORK, PITTSBURGH, WHITE, 2);
    ROUTE_NEW_YORK_TO_PITTSBURGH_B = Route(NEW_YORK, PITTSBURGH, WHITE, 2);
    ROUTE_NEW_YORK_TO_WASHINGTON_DC_A = Route(NEW_YORK, WASHINGTON_DC, ORANGE, 2);
    ROUTE_NEW_YORK_TO_WASHINGTON_DC_B = Route(NEW_YORK, WASHINGTON_DC, BLACK, 2);

    ROUTE_OKLAHOMA_CITY_TO_SANTA_FE = Route(OKLAHOMA_CITY, SANTA_FE, BLUE, 3);

    ROUTE_PHOENIX_TO_SANTA_FE = Route(PHOENIX, SANTA_FE, GRAY, 3);

    ROUTE_PITTSBURGH_TO_RALEIGH = Route(PITTSBURGH, RALEIGH, GRAY, 2);
    ROUTE_PITTSBURGH_TO_SAINT_LOUIS = Route(PITTSBURGH, SAINT_LOUIS, GREEN, 5);
    ROUTE_PITTSBURGH_TO_TORONTO = Route(PITTSBURGH, TORONTO, GRAY, 2);
    ROUTE_PITTSBURGH_TO_WASHINGTON_DC = Route(PITTSBURGH, WASHINGTON_DC, GRAY, 2);

    ROUTE_PORTLAND_TO_SALT_LAKE_CITY = Route(PORTLAND, SALT_LAKE_CITY, BLUE, 6);
    ROUTE_PORTLAND_TO_SAN_FRANCISCO_A = Route(PORTLAND, SAN_FRANCISCO, PURPLE, 5);
    ROUTE_PORTLAND_TO_SAN_FRANCISCO_B = Route(PORTLAND, SAN_FRANCISCO, GREEN, 5);
    ROUTE_PORTLAND_TO_SEATTLE_A = Route(PORTLAND, SEATTLE, GRAY, 1);
    ROUTE_PORTLAND_TO_SEATTLE_B = Route(PORTLAND, SEATTLE, GRAY, 1);
    
    ROUTE_RALEIGH_TO_WASHINGTON_DC_A = Route(RALEIGH, WASHINGTON_DC, GRAY, 2);
    ROUTE_RALEIGH_TO_WASHINGTON_DC_B = Route(RALEIGH, WASHINGTON_DC, GRAY, 2);
    
    ROUTE_SALT_LAKE_CITY_TO_SAN_FRANCISCO_A = Route(SALT_LAKE_CITY, SAN_FRANCISCO, ORANGE, 5);
    ROUTE_SALT_LAKE_CITY_TO_SAN_FRANCISCO_B = Route(SALT_LAKE_CITY, SAN_FRANCISCO, WHITE, 5);
    
    ROUTE_SAULT_ST_MARIE_TO_TORONTO = Route(SAULT_ST_MARIE, TORONTO, GRAY, 2);
    ROUTE_SAULT_ST_MARIE_TO_WINNIPEG = Route(SAULT_ST_MARIE, WINNIPEG, GRAY, 6);

    ROUTE_SEATTLE_TO_VANCOUVER_A = Route(SEATTLE, VANCOUVER, GRAY, 1);
    ROUTE_SEATTLE_TO_VANCOUVER_B = Route(SEATTLE, VANCOUVER, GRAY, 1);

    NUM_ROUTES = IntCounter.setget() - 1;

end