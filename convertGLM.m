%% convertGLM
% Converts .glm files to digraph object
%   Requires a file for each feederID in folder "\glm"
%   Saves each digraph object and its model name to "\output"
% This has only been tested on Prototypical Feeders; it is possible it
%   could be extended to other GridLAB-D models

feederIDs = ["GC-12.47-1", "R1-12.47-1", "R1-12.47-2", "R1-12.47-3",...
    "R1-12.47-4", "R1-25.00-1", "R2-12.47-1", "R2-12.47-2", "R2-12.47-3",...
    "R2-25.00-1", "R2-35.00-1", "R3-12.47-1", "R3-12.47-2", "R3-12.47-3",...
    "R4-12.47-1", "R4-12.47-2", "R4-25.00-1", "R5-12.47-1", "R5-12.47-2",...
    "R5-12.47-3", "R5-12.47-4", "R5-12.47-5", "R5-25.00-1", "R5-35.00-1"];

%% Loop through models
for iF = 1:length(feederIDs)
    
    modelName = feederIDs(iF);
    disp(' ')
    disp(['----STARTING CONVERSION OF ',char(modelName),' (Model ',num2str(iF),'/',num2str(numel(feederIDs)),')----'])
    
    %% Generate digraph
    modelData = parseGLM(modelName);    % load .glm and create string array
    G = glm2net(modelName,modelData);   % convert to digraph
    
    %% Clean names
    % remove model name from node (edge table automatically updated) and edge names
    % replace "_" with "-" to make plotting cleaner
    removeStr = strcat(replace(modelName,".","-"),'_');
    % loop through nodes
    for iN = 1:height(G.Nodes)
        % rename (note: Name must be cell array)
        initName = G.Nodes.Name{iN};
        newName = erase(initName,removeStr);
        newName = replace(newName,"_","-");
        G.Nodes.Name{iN} = newName;
    end
    % loop through edges (note: edge Names do not need to be unique)
    for iE = 1:height(G.Edges)
        initName = G.Edges.Name{iE};
        newName = erase(initName,removeStr);
        newName = replace(newName,"_","-");
        G.Edges.Name{iE} = newName;
    end
    
    %% ID source and check/adjust directed edge directions
    for iN = 1:height(G.Nodes)
        props = G.Nodes.Prop{iN};
        if isfield(props,'bustype')
            disp(['Source node identified and set: ',G.Nodes.Name{iN},' (index ',num2str(iN),')...'])
            if strcmpi(props.bustype,'SWING')
                % swing bus is infinite bus (i.e. source)
                G.Nodes.Type(iN) = 'source';
            else
                warning('Unexpected node bustype (not "SWING")');
            end
        end
    end
    % adjust directed edges if needed
    sourceID = find(G.Nodes.Type == 'source');
    if isempty(sourceID)
        error('no source node found')
    elseif numel(sourceID)>1
        error('multiple source nodes found')
    end
    G = redirectDigraph(G,sourceID);
    
    %% Save results
    save(['output\',char(modelName),'.mat'],'G','modelName')
    disp(['----COMPLETED CONVERSION OF ',char(modelName),' (Model ',num2str(iF),'/',num2str(numel(feederIDs)),')----'])
    disp(['...saved to output\',char(modelName),'.mat...'])
    disp(' ');
    
end





