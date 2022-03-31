function RunSimulation(initFunc, varargin)
    gameObj = initFunc(varargin);
    gameObj.simulateGame();
    assignin('base', "gameObj", gameObj);
end