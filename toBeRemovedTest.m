function toBeRemovedTest()

% Initial example, all but one edge can be in a continuous route
a = {[1 2 1], ...
     [2 6 1], ...
     [1 6 1], ...
     [5 6 1], ...
     [2 3 1], ...
     [3 5 1], ...
     [4 5 1], ...
     [3 4 1]};

% % Single edge between two nodes
% a = {[1 2 1]};

% % One clump with many routes does not produce a longer path than a small
% % two-route section.
% a = {[1 6 1], ...
%      [2 6 1], ...
%      [3 6 1], ...
%      [4 6 1], ...
%      [5 6 1], ...
%      [7 8 1], ...
%      [8 9 2]};

% % Speed test: nodes with edges between all nodes
% a = {};
% numNodes = 6; % this takes about 10 seconds at numNodes = 6
% for i = 1:numNodes
%     for j = 1:numNodes
%         if i < j
%             a{end+1} = [i j 1];
%         end
%     end
% end

% % Speed test: nodes with two connecting edges each in a circle
% numNodes = 100; % Even 100 nodes is only 0.3 seconds
% a = {[1 numNodes 1]};
% for i = 2:numNodes
%     a{end+1} = [i i-1 1];
% end

% % Speed test: nodes with four connecting edges each in a circle
% numNodes = 9; % This takes about 7 seconds at numNodes = 9
% a = {[1 numNodes   1], ...
%      [1 numNodes-1 1], ...
%      [2 1          1], ...
%      [2 numNodes   1]};
% for i = 3:numNodes
%     a{end+1} = [i i-1 1];
%     a{end+1} = [i i-2 1];
% end


aMat = zeros(length(a), 3);
for i = 1:length(a)
    aMat(i, 1:3) = a{i};
end

nodeIDs = unique(aMat(:,1:2));
nodeIDs = reshape(nodeIDs, 1, length(nodeIDs));

longestPath = 0;
longestDirections = [];

disp('start')
tic
for n = nodeIDs
    [longestLength, pathSoFar] = getLength(n, a);
    if longestLength > longestPath
        longestPath = longestLength;
        longestDirections = pathSoFar;
        longestDirections(end+1) = n; %#ok<AGROW> 
    end
end
toc

disp('result')
disp(longestPath);
disp('path')
disp(longestDirections)
disp('totalEdges')
disp(length(a))

plotGraph(a)

end

function [longestPath, pathSoFar] = getLength(node, edges)
longestPath = 0;
pathSoFar = [];

for iEdge = 1:length(edges)
    if edges{iEdge}(1) == node
        newEdges = edges;
        newEdges(iEdge) = [];
        [result, newPath] = getLength(edges{iEdge}(2), newEdges);
        newLength = edges{iEdge}(3) + result;
        if newLength > longestPath
            longestPath = newLength;
            pathSoFar = [newPath edges{iEdge}(2)];
        end
    elseif edges{iEdge}(2) == node
        newEdges = edges;
        newEdges(iEdge) = [];
        [result, newPath] = getLength(edges{iEdge}(1), newEdges);
        newLength = edges{iEdge}(3) + result;
        if newLength > longestPath
            longestPath = newLength;
            pathSoFar = [newPath edges{iEdge}(1)];
        end
    end
end

end

function plotGraph(edges)

allFroms = zeros(1,length(edges));
allTos = zeros(1,length(edges));
for i = 1:length(edges)
    allFroms(i) = edges{i}(1);
    allTos(i) = edges{i}(2);
end

newGraph = graph(allFroms, allTos);

plot(newGraph)

end