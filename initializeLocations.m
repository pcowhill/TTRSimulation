% initializeLocations
% Defines variables (with the intention of acting as global variables) that
% refer to the standard locations used in TTR.

if ~exist('INITIALIZE_LOCATIONS_M', 'var')

    INITIALIZE_LOCATIONS_M = true;

    % Patrick Note: I originally named these as CITY_ATLANTA, CITY_LITTLEROCK,
    % etc. although it seemed to be too verbose, so I removed the CITY_ prefix.
    
    ATLANTA = Location("Atlanta");
    BOSTON = Location("Boston");
    CALGARY = Location("Calgary");
    CHARLESTON = Location("Charleston");
    CHICAGO = Location("Chicago");
    DALLAS = Location("Dallas");
    DENVER = Location("Denver");
    DULUTH = Location("Duluth");
    EL_PASO = Location("El Paso");
    HELENA = Location("Helena");
    HOUSTON = Location("Houston");
    KANSAS_CITY = Location("Kansas City");
    LAS_VEGAS = Location("Las Vegas");
    LOS_ANGELES = Location("Los Angeles");
    LITTLE_ROCK = Location("Little Rock");
    MIAMI = Location("Miami");
    MONTREAL = Location("Montreal");
    NASHVILLE = Location("Nashville");
    NEW_ORLEANS = Location("New Orleans");
    NEW_YORK = Location("New York");
    OKLAHOMA_CITY = Location("Oklahoma City");
    OMAHA = Location("Omaha");
    PHOENIX = Location("Phoenix");
    PITTSBURG = Location("Pittsburg");
    PORTLAND = Location("Portland");
    RALEIGH = Location("Raleigh");
    SAINT_LOUIS = Location("Saint Louis");
    SALT_LAKE_CITY = Location("Salt Lake City");
    SAN_FRANCISCO = Location("San Francisco");
    SANTA_FE = Location("Santa Fe");
    SAULT_ST_MARIE = Location("Sault St. Marie");
    SEATTLE = Location("Seattle");
    TORONTO = Location("Toronto");
    VANCOUVER = Location("Vancouver");
    WASHINGTON_DC = Location("Washington D.C.");
    WINNIPEG = Location("Winnipeg");

end