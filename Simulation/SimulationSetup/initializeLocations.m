% initializeLocations
% Defines variables (with the intention of acting as global variables) that
% refer to the standard locations used in TTR.

if ~exist('INITIALIZE_LOCATIONS_M', 'var')

    INITIALIZE_LOCATIONS_M = true;

    % Patrick Note: I originally named these as CITY_ATLANTA, CITY_LITTLEROCK,
    % etc. although it seemed to be too verbose, so I removed the CITY_ prefix.
    
    ATLANTA = Location.Atlanta;
    BOSTON = Location.Boston;
    CALGARY = Location.Calgary;
    CHARLESTON = Location.Charleston;
    CHICAGO = Location.Chicago;
    DALLAS = Location.Dallas;
    DENVER = Location.Denver;
    DULUTH = Location.Duluth;
    EL_PASO = Location.El_Paso;
    HELENA = Location.Helena;
    HOUSTON = Location.Houston;
    KANSAS_CITY = Location.Kansas_City;
    LAS_VEGAS = Location.Las_Vegas;
    LOS_ANGELES = Location.Los_Angeles;
    LITTLE_ROCK = Location.Little_Rock;
    MIAMI = Location.Miami;
    MONTREAL = Location.Montreal;
    NASHVILLE = Location.Nashville;
    NEW_ORLEANS = Location.New_Orleans;
    NEW_YORK = Location.New_York;
    OKLAHOMA_CITY = Location.Oklahoma_City;
    OMAHA = Location.Omaha;
    PHOENIX = Location.Phoenix;
    PITTSBURGH = Location.Pittsburgh;
    PORTLAND = Location.Portland;
    RALEIGH = Location.Raleigh;
    SAINT_LOUIS = Location.Saint_Louis;
    SALT_LAKE_CITY = Location.Salt_Lake_City;
    SAN_FRANCISCO = Location.San_Francisco;
    SANTA_FE = Location.Santa_Fe;
    SAULT_ST_MARIE = Location.Sault_St_Marie;
    SEATTLE = Location.Seattle;
    TORONTO = Location.Toronto;
    VANCOUVER = Location.Vancouver;
    WASHINGTON_DC = Location.Washington_DC;
    WINNIPEG = Location.Winnipeg;

end