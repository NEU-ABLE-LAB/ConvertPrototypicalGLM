% translateG
% take the results from convertGLM / glm2net and translate

% test case
load('R1-12.47-3.mat')

% remove model name from node (edge table automatically updated) and edge names
% replace "_" from model names to make plotting cleaner
removeStr = strcat(replace(modelName,".","-"),'_');
% loop through nodes and edges
for iN = 1:height(G.Nodes)
    initName = G.Nodes.Name{iN};
    newName = erase(initName,removeStr);
    newName = replace(newName,"_","-");
    G.Nodes.Name{iN} = newName;
end
for iE = 1:height(G.Edges)
    initName = G.Edges.Name{iE};
    newName = erase(initName,removeStr);
    newName = replace(newName,"_","-");
    G.Edges.Name{iE} = newName;
end

% ** next: convert node and edge representation

% Initial node types:
%   load - keep node
%   node - keep node
%   meter - merge with load (other connections?)
%   ...
% Initial edge types:
%   ol - keep edge
%   xfmr - make node
%   parent - keep edge
%   ...




