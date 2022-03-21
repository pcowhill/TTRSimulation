% initializeTrainCards
% Defines variables (with the intention of acting as global variables) that
% refer to the number of each type of train card used in TTR and then
% constructs the initial state of train card pile (prior to shuffling and
% dealing to players).

% These are the colors and respective number of cards from the North America board game.
% Reference:
% Ticket to Ride Rules. (2015). Days of Wonder. 
NUM_PURPLE = int8(12);
NUM_WHITE = int8(12);
NUM_BLUE = int8(12);
NUM_YELLOW = int8(12);
NUM_ORANGE = int8(12);
NUM_BLACK = int8(12);
NUM_RED = int8(12);
NUM_GREEN = int8(12);
NUM_MULTICOLORED = int8(14);

% Create TrainCard deck
TRAINS_DECK = TrainsDeck(NUM_PURPLE, NUM_WHITE, NUM_BLUE, NUM_YELLOW, NUM_ORANGE, NUM_BLACK, NUM_RED, NUM_GREEN, NUM_MULTICOLORED);

