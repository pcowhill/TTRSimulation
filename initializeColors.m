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
    PURPLE = Color.purple;
    BLUE = Color.blue;
    ORANGE = Color.orange;
    WHITE = Color.white;
    GREEN = Color.green;
    YELLOW = Color.yellow;
    BLACK = Color.black;
    RED = Color.red;
    
    % For colorless spots in routes on the game board
    GRAY = Color.gray;
    
    % For the locomotive card
    MULTICOLORED = Color.multicolored;

end