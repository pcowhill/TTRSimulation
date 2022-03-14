classdef Color
    % Color
    % Represents a color for the various trains, players, cards, routes, etc.

    enumeration
        purple
        blue
        orange
        white
        green
        yellow
        black
        red
        gray
        multicolored
        unknown
    end

    % Patrick Note: I originally wrote a method to recieve a string version
    % of the enumeration until I learned there already exists such a method
    % by default: Color.red.string()

end