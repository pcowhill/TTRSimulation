classdef IntCounter
    % IntCounter
    % Class for static use.  After setting a 
    
    methods (Static)
        function out = setget(val)
            persistent theCount;
            if nargin == 0
                out = theCount;
                theCount = theCount + 1;
            else
                theCount = val;
                out = theCount;
            end
        end
    end
end

