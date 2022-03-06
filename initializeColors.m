% initializeColors
% Defines variables (with the intention of acting as global variables) that
% refer to the standard colors used in TTR.

% If these variables have already been initialized, the code in this file
% is skipped.
if ~exist('INITIALIZE_COLORS_M', 'var')

    INITIALIZE_COLORS_M = true;

    % Patrick Note: I originally named these as COLOR_PURPLE, etc. although it
    % seemed to be too verbose, so I removed the COLOR_ prefix.
    
    % For train card colors, train peice colors and player colors
    PURPLE = Color("purple", "Purple", "PURPLE");
    BLUE = Color("blue", "Blue", "BLUE");
    ORANGE = Color("orange", "Orange", "ORANGE");
    WHITE = Color("white", "White", "WHITE");
    GREEN = Color("green", "Green", "GREEN");
    YELLOW = Color("yellow", "Yellow", "YELLOW");
    BLACK = Color("black", "Black", "BLACK");
    RED = Color("red", "Red", "RED");
    
    % For colorless spots in routes on the game board
    UNCOLORED = Color("uncolored", "Uncolored", "UNCOLORED", ...
                      "blank", "Blank", "BLANK", ...
                      "empty", "Empty", "EMPTY", ...
                      "null", "Null", "NULL", ...
                      "colorless", "Colorless", "COLORLESS", ...
                      "grey", "Grey", "GREY", ...
                      "neutral", "Neutral", "NEUTRAL");
    
    % For the locomotive card
    RAINBOW = Color("rainbow", "Rainbow", "RAINBOW", ...
                    "multi", "Multi", "MULTI", ...
                    "locomotive", "Locomotive", "LOCOMOTIVE", ...
                    "multicolor", "Multicolor", "MULTICOLOR", ...
                    "multicolored", "Multicolored", "MULTICOLORED");

end