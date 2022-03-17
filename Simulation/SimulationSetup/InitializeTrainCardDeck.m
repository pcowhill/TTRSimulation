% initializeTrainCards
% Defines variables (with the intention of acting as global variables) that
% refer to the number of each type of train card used in TTR and then
% constructs the initial state of train card pile (prior to shuffling and
% dealing to players).

% Jessica TODO: Need to cite:
% https://teams.microsoft.com/_#/pdf/viewer/teams/https:~2F~2Fgtvault.sharepoint.com~2Fsites~2FModelingandSimulationTeam1~2FShared%20Documents~2FGeneral~2FTicket%20To%20Ride%20Resources~2FTicketToRideRules.pdf?threadId=19:umNZGR5vjjedPKaD1XMbJpupBGgasRLyEct9H7qcltM1@thread.tacv2&baseUrl=https:~2F~2Fgtvault.sharepoint.com~2Fsites~2FModelingandSimulationTeam1&fileId=00994582-f912-4be8-ac38-39748c218ed8&ctx=files&rootContext=items_view&viewerAction=view
% for a list of the number of each type of card

% These are the colors and respective number of cards from the North America board game.
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
drawPile = TrainsDeck(NUM_PURPLE, NUM_WHITE, NUM_BLUE, NUM_YELLOW, NUM_ORANGE, NUM_BLACK, NUM_RED, NUM_GREEN, NUM_MULTICOLORED);