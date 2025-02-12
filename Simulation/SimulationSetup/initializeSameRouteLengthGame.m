function game = initializeSameRouteLengthGame(args)
%INITIALIZERDUCEDROUTEGAME Initialize a Game with less routes
    
    SAME_LENGTH = 3;
    initializeColors;
    initializeLocations;

    IntCounter.setget(1);

    ROUTE_ATLANTA_TO_CHARLESTON = Route(ATLANTA, CHARLESTON, GRAY, SAME_LENGTH);
    ROUTE_ATLANTA_TO_MIAMI = Route(ATLANTA, MIAMI, BLUE, SAME_LENGTH);
    ROUTE_ATLANTA_TO_NASHVILLE = Route(ATLANTA, NASHVILLE, GRAY, SAME_LENGTH);
    ROUTE_ATLANTA_TO_NEW_ORLEANS_A = Route(ATLANTA, NEW_ORLEANS, ORANGE, SAME_LENGTH);
    ROUTE_ATLANTA_TO_NEW_ORLEANS_B = Route(ATLANTA, NEW_ORLEANS, YELLOW, SAME_LENGTH);
    ROUTE_ATLANTA_TO_RALEIGH_A = Route(ATLANTA, RALEIGH, GRAY, SAME_LENGTH);
    ROUTE_ATLANTA_TO_RALEIGH_B = Route(ATLANTA, RALEIGH, GRAY, SAME_LENGTH);

    ROUTE_BOSTON_TO_MONTREAL_A = Route(BOSTON, MONTREAL, GRAY, SAME_LENGTH);
    ROUTE_BOSTON_TO_MONTREAL_B = Route(BOSTON, MONTREAL, GRAY, SAME_LENGTH);
    ROUTE_BOSTON_TO_NEW_YORK_A = Route(BOSTON, NEW_YORK, YELLOW, SAME_LENGTH);
    ROUTE_BOSTON_TO_NEW_YORK_B = Route(BOSTON, NEW_YORK, RED, SAME_LENGTH);

    ROUTE_CALGARY_TO_HELENA = Route(CALGARY, HELENA, GRAY, SAME_LENGTH);
    ROUTE_CALGARY_TO_SEATTLE = Route(CALGARY, SEATTLE, GRAY, SAME_LENGTH);
    ROUTE_CALGARY_TO_VANCOUVER = Route(CALGARY, VANCOUVER, GRAY, SAME_LENGTH);
    ROUTE_CALGARY_TO_WINNIPEG = Route(CALGARY, WINNIPEG, WHITE, SAME_LENGTH);

    ROUTE_CHARLESTON_TO_MIAMI = Route(CHARLESTON, MIAMI, PURPLE, SAME_LENGTH);
    ROUTE_CHARLESTON_TO_RALEIGH = Route(CHARLESTON, RALEIGH, GRAY, SAME_LENGTH);
    
    ROUTE_CHICAGO_TO_DULUTH = Route(CHICAGO, DULUTH, RED, SAME_LENGTH);
    ROUTE_CHICAGO_TO_OMAHA = Route(CHICAGO, OMAHA, BLUE, SAME_LENGTH);
    ROUTE_CHICAGO_TO_PITTSBURGH_A = Route(CHICAGO, PITTSBURGH, ORANGE, SAME_LENGTH);
    ROUTE_CHICAGO_TO_PITTSBURGH_B = Route(CHICAGO, PITTSBURGH, BLACK, SAME_LENGTH);
    ROUTE_CHICAGO_TO_SAINT_LOUIS_A = Route(CHICAGO, SAINT_LOUIS, WHITE, SAME_LENGTH);
    ROUTE_CHICAGO_TO_SAINT_LOUIS_B = Route(CHICAGO, SAINT_LOUIS, GREEN, SAME_LENGTH);
    ROUTE_CHICAGO_TO_TORONTO = Route(CHICAGO, TORONTO, WHITE, SAME_LENGTH);

    ROUTE_DALLAS_TO_EL_PASO = Route(DALLAS, EL_PASO, RED, SAME_LENGTH);
    ROUTE_DALLAS_TO_HOUSTON_A = Route(DALLAS, HOUSTON, GRAY, SAME_LENGTH);
    ROUTE_DALLAS_TO_HOUSTON_B = Route(DALLAS, HOUSTON, GRAY, SAME_LENGTH);
    ROUTE_DALLAS_TO_LITTLE_ROCK = Route(DALLAS, LITTLE_ROCK, GRAY, SAME_LENGTH);
    ROUTE_DALLAS_TO_OKLAHOMA_CITY_A = Route(DALLAS, OKLAHOMA_CITY, GRAY, SAME_LENGTH);
    ROUTE_DALLAS_TO_OKLAHOMA_CITY_B = Route(DALLAS, OKLAHOMA_CITY, GRAY, SAME_LENGTH);

    ROUTE_DENVER_TO_HELENA = Route(DENVER, HELENA, GREEN, SAME_LENGTH);
    ROUTE_DENVER_TO_KANSAS_CITY_A = Route(DENVER, KANSAS_CITY, ORANGE, SAME_LENGTH);
    ROUTE_DENVER_TO_KANSAS_CITY_B = Route(DENVER, KANSAS_CITY, BLACK, SAME_LENGTH);
    ROUTE_DENVER_TO_OKLAHOMA_CITY = Route(DENVER, OKLAHOMA_CITY, RED, SAME_LENGTH);
    ROUTE_DENVER_TO_OMAHA = Route(DENVER, OMAHA, PURPLE, SAME_LENGTH);
    ROUTE_DENVER_TO_PHOENIX = Route(DENVER, PHOENIX, WHITE, SAME_LENGTH);
    ROUTE_DENVER_TO_SALT_LAKE_CITY_A = Route(DENVER, SALT_LAKE_CITY, YELLOW, SAME_LENGTH);
    ROUTE_DENVER_TO_SALT_LAKE_CITY_B = Route(DENVER, SALT_LAKE_CITY, RED, SAME_LENGTH);
    ROUTE_DENVER_TO_SANTA_FE = Route(DENVER, SANTA_FE, GRAY, SAME_LENGTH);

    ROUTE_DULUTH_TO_HELENA = Route(DULUTH, HELENA, ORANGE, SAME_LENGTH);
    ROUTE_DULUTH_TO_OMAHA_A = Route(DULUTH, OMAHA, GRAY, SAME_LENGTH);
    ROUTE_DULUTH_TO_OMAHA_B = Route(DULUTH, OMAHA, GRAY, SAME_LENGTH);
    ROUTE_DULUTH_TO_SAULT_ST_MARIE = Route(DULUTH, SAULT_ST_MARIE, GRAY, SAME_LENGTH);
    ROUTE_DULUTH_TO_TORONTO = Route(DULUTH, TORONTO, PURPLE, SAME_LENGTH);
    ROUTE_DULUTH_TO_WINNIPEG = Route(DULUTH, WINNIPEG, BLACK, SAME_LENGTH);

    ROUTE_EL_PASO_TO_HOUSTON = Route(EL_PASO, HOUSTON, GREEN, SAME_LENGTH);
    ROUTE_EL_PASO_TO_LOS_ANGELES = Route(EL_PASO, LOS_ANGELES, BLACK, SAME_LENGTH);
    ROUTE_EL_PASO_TO_OKLAHOMA_CITY = Route(EL_PASO, OKLAHOMA_CITY, YELLOW, SAME_LENGTH);
    ROUTE_EL_PASO_TO_PHOENIX = Route(EL_PASO, PHOENIX, GRAY, SAME_LENGTH);
    ROUTE_EL_PASO_TO_SANTA_FE = Route(EL_PASO, SANTA_FE, GRAY, SAME_LENGTH);

    ROUTE_HELENA_TO_OMAHA = Route(HELENA, OMAHA, RED, SAME_LENGTH);
    ROUTE_HELENA_TO_SALT_LAKE_CITY = Route(HELENA, SALT_LAKE_CITY, PURPLE, SAME_LENGTH);
    ROUTE_HELENA_TO_SEATTLE = Route(HELENA, SEATTLE, YELLOW, SAME_LENGTH);
    ROUTE_HELENA_TO_WINNIPEG = Route(HELENA, WINNIPEG, BLUE, SAME_LENGTH);

    ROUTE_HOUSTON_TO_NEW_ORLEANS = Route(HOUSTON, NEW_ORLEANS, GRAY, SAME_LENGTH);

    ROUTE_KANSAS_CITY_TO_OKLAHOMA_CITY_A = Route(KANSAS_CITY, OKLAHOMA_CITY, GRAY, SAME_LENGTH);
    ROUTE_KANSAS_CITY_TO_OKLAHOMA_CITY_B = Route(KANSAS_CITY, OKLAHOMA_CITY, GRAY, SAME_LENGTH);
    ROUTE_KANSAS_CITY_TO_OMAHA_A = Route(KANSAS_CITY, OMAHA, GRAY, SAME_LENGTH);
    ROUTE_KANSAS_CITY_TO_OMAHA_B = Route(KANSAS_CITY, OMAHA, GRAY, SAME_LENGTH);
    ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_A = Route(KANSAS_CITY, SAINT_LOUIS, PURPLE, SAME_LENGTH);
    ROUTE_KANSAS_CITY_TO_SAINT_LOUIS_B = Route(KANSAS_CITY, SAINT_LOUIS, BLUE, SAME_LENGTH);
    
    ROUTE_LAS_VEGAS_TO_LOS_ANGELES = Route(LAS_VEGAS, LOS_ANGELES, GRAY, SAME_LENGTH);
    ROUTE_LAS_VEGAS_TO_SALT_LAKE_CITY = Route(LAS_VEGAS, SALT_LAKE_CITY, ORANGE, SAME_LENGTH);

    ROUTE_LOS_ANGELES_TO_PHOENIX = Route(LOS_ANGELES, PHOENIX, GRAY, SAME_LENGTH);
    ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_A = Route(LOS_ANGELES, SAN_FRANCISCO, PURPLE, SAME_LENGTH);
    ROUTE_LOS_ANGELES_TO_SAN_FRANCISCO_B = Route(LOS_ANGELES, SAN_FRANCISCO, PURPLE, SAME_LENGTH);
    
    ROUTE_LITTLE_ROCK_TO_NASHVILLE = Route(LITTLE_ROCK, NASHVILLE, WHITE, SAME_LENGTH);
    ROUTE_LITTLE_ROCK_TO_NEW_ORLEANS = Route(LITTLE_ROCK, NEW_ORLEANS, GREEN, SAME_LENGTH);
    ROUTE_LITTLE_ROCK_TO_OKLAHOMA_CITY = Route(LITTLE_ROCK, OKLAHOMA_CITY, GRAY, SAME_LENGTH);
    ROUTE_LITTLE_ROCK_TO_SAINT_LOUIS = Route(LITTLE_ROCK, SAINT_LOUIS, GRAY, SAME_LENGTH);

    ROUTE_MIAMI_TO_NEW_ORLEANS = Route(MIAMI, NEW_ORLEANS, RED, SAME_LENGTH);

    ROUTE_MONTREAL_TO_NEW_YORK = Route(MONTREAL, NEW_YORK, BLUE, SAME_LENGTH);
    ROUTE_MONTREAL_TO_SAULT_ST_MARIE = Route(MONTREAL, SAULT_ST_MARIE, BLACK, SAME_LENGTH);
    ROUTE_MONTREAL_TO_TORONTO = Route(MONTREAL, TORONTO, GRAY, SAME_LENGTH);

    ROUTE_NASHVILLE_TO_PITTSBURGH = Route(NASHVILLE, PITTSBURGH, YELLOW, SAME_LENGTH);
    ROUTE_NASHVILLE_TO_RALEIGH = Route(NASHVILLE, RALEIGH, BLACK, SAME_LENGTH);
    ROUTE_NASHVILLE_TO_SAINT_LOUIS = Route(NASHVILLE, SAINT_LOUIS, GRAY, SAME_LENGTH);

    ROUTE_NEW_YORK_TO_PITTSBURGH_A = Route(NEW_YORK, PITTSBURGH, WHITE, SAME_LENGTH);
    ROUTE_NEW_YORK_TO_PITTSBURGH_B = Route(NEW_YORK, PITTSBURGH, WHITE, SAME_LENGTH);
    ROUTE_NEW_YORK_TO_WASHINGTON_DC_A = Route(NEW_YORK, WASHINGTON_DC, ORANGE, SAME_LENGTH);
    ROUTE_NEW_YORK_TO_WASHINGTON_DC_B = Route(NEW_YORK, WASHINGTON_DC, BLACK, SAME_LENGTH);

    ROUTE_OKLAHOMA_CITY_TO_SANTA_FE = Route(OKLAHOMA_CITY, SANTA_FE, BLUE, SAME_LENGTH);

    ROUTE_PHOENIX_TO_SANTA_FE = Route(PHOENIX, SANTA_FE, GRAY, SAME_LENGTH);

    ROUTE_PITTSBURGH_TO_RALEIGH = Route(PITTSBURGH, RALEIGH, GRAY, SAME_LENGTH);
    ROUTE_PITTSBURGH_TO_SAINT_LOUIS = Route(PITTSBURGH, SAINT_LOUIS, GREEN, SAME_LENGTH);
    ROUTE_PITTSBURGH_TO_TORONTO = Route(PITTSBURGH, TORONTO, GRAY, SAME_LENGTH);
    ROUTE_PITTSBURGH_TO_WASHINGTON_DC = Route(PITTSBURGH, WASHINGTON_DC, GRAY, SAME_LENGTH);

    ROUTE_PORTLAND_TO_SALT_LAKE_CITY = Route(PORTLAND, SALT_LAKE_CITY, BLUE, SAME_LENGTH);
    ROUTE_PORTLAND_TO_SAN_FRANCISCO_A = Route(PORTLAND, SAN_FRANCISCO, PURPLE, SAME_LENGTH);
    ROUTE_PORTLAND_TO_SAN_FRANCISCO_B = Route(PORTLAND, SAN_FRANCISCO, GREEN, SAME_LENGTH);
    ROUTE_PORTLAND_TO_SEATTLE_A = Route(PORTLAND, SEATTLE, GRAY, SAME_LENGTH);
    ROUTE_PORTLAND_TO_SEATTLE_B = Route(PORTLAND, SEATTLE, GRAY, SAME_LENGTH);
    
    ROUTE_RALEIGH_TO_WASHINGTON_DC_A = Route(RALEIGH, WASHINGTON_DC, GRAY, SAME_LENGTH);
    ROUTE_RALEIGH_TO_WASHINGTON_DC_B = Route(RALEIGH, WASHINGTON_DC, GRAY, SAME_LENGTH);
    
    ROUTE_SALT_LAKE_CITY_TO_SAN_FRANCISCO_A = Route(SALT_LAKE_CITY, SAN_FRANCISCO, ORANGE, SAME_LENGTH);
    ROUTE_SALT_LAKE_CITY_TO_SAN_FRANCISCO_B = Route(SALT_LAKE_CITY, SAN_FRANCISCO, WHITE, SAME_LENGTH);
    
    ROUTE_SAULT_ST_MARIE_TO_TORONTO = Route(SAULT_ST_MARIE, TORONTO, GRAY, SAME_LENGTH);
    ROUTE_SAULT_ST_MARIE_TO_WINNIPEG = Route(SAULT_ST_MARIE, WINNIPEG, GRAY, SAME_LENGTH);

    ROUTE_SEATTLE_TO_VANCOUVER_A = Route(SEATTLE, VANCOUVER, GRAY, SAME_LENGTH);
    ROUTE_SEATTLE_TO_VANCOUVER_B = Route(SEATTLE, VANCOUVER, GRAY, SAME_LENGTH);

    NUM_ROUTES = IntCounter.setget() - 1;

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
                  ROUTE_CHICAGO_TO_PITTSBURGH_A, ...
                  ROUTE_CHICAGO_TO_PITTSBURGH_B, ...
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
                  ROUTE_NASHVILLE_TO_PITTSBURGH, ...
                  ROUTE_NASHVILLE_TO_RALEIGH, ...
                  ROUTE_NASHVILLE_TO_SAINT_LOUIS, ...
                  ROUTE_NEW_YORK_TO_PITTSBURGH_A, ...
                  ROUTE_NEW_YORK_TO_PITTSBURGH_B, ...
                  ROUTE_NEW_YORK_TO_WASHINGTON_DC_A, ...
                  ROUTE_NEW_YORK_TO_WASHINGTON_DC_B, ...
                  ROUTE_OKLAHOMA_CITY_TO_SANTA_FE, ...
                  ROUTE_PHOENIX_TO_SANTA_FE, ...
                  ROUTE_PITTSBURGH_TO_RALEIGH, ...
                  ROUTE_PITTSBURGH_TO_SAINT_LOUIS, ...
                  ROUTE_PITTSBURGH_TO_TORONTO, ...
                  ROUTE_PITTSBURGH_TO_WASHINGTON_DC, ...
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
    
    BaseBoard.InitializeTrainCardDeck;
    BaseBoard.InitializeDestinationTicketCards;
    args{7} = BOARD;
    args{8} = TRAINS_DECK;
    args{9} = DESTINATIONS_DECK;

    game = initializeGame(args);

end

