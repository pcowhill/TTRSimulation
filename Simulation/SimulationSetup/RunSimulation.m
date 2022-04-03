function RunSimulation(initFunc, varargin)
    gameObj = initFunc(varargin);
    gameObj.simulateGame();
    assignin('base', "gameObj", gameObj);

    edgeOwners=gameObj.board.routeGraph.Edges.Owner;
    edgeColors = repmat([0 0 0], length(edgeOwners), 1);    
    tmp=find(edgeOwners=='red');
    edgeColors(tmp, :)=repmat([1 0 0], length(tmp),1);
    tmp=find(edgeOwners=='yellow');
    edgeColors(tmp, :)=repmat([1 1 0], length(tmp),1);
    tmp=find(edgeOwners=='green');
    edgeColors(tmp, :)=repmat([0 1 0], length(tmp),1);
    tmp=find(edgeOwners=='blue');
    edgeColors(tmp, :)=repmat([0 0 1], length(tmp),1);
    
    plot(gameObj.board.routeGraph, 'EdgeColor', edgeColors)
end