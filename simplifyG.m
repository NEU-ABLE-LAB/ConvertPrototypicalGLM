% take the results from convertGLM / glm2net and simplify
%% TO DO:
% - convert to function
% - consider: display as "layered" for hierarchy & impact of length on plotting
% - create "simple" version
% - check and document properties retained
% - REMOVE nodes between only 2 others (add WHILE LOOP)
%   - choose when to inherit properties (name/length) of edges
% remove troubleshoot plots

%% Notes and formatting:
% Nodes.Name is cell array of char, otherwise text fields are string arrays
clear

modelName = 'R1-12.47-3';

%% LOAD

addpath([pwd,'\results\'])
% test case
load([modelName,'.mat'])

%% 1. RENAME NODES AND EDGES
G0 = G; % troubleshooting savepoint
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

% TROUBLESHOOT: plot
figure(1)
plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);

%% CREATE NEW GRAPH
%Gt = digraph;

%% 2. NODES: Extract and clean up properties
G1 = G; % troubleshooting savepoint
% Keep properties: Name, Type
% New properties: NominalPower

for iN = 1:height(G.Nodes)
    props = G.Nodes.Prop{iN};
    % check node type
    switch lower(G.Nodes.Type(iN))
        case 'load'
            % update NominalPower
            powerNom = 0;
            if isfield(props,'constant_power_A')
                powerNom = powerNom + str2num(props.constant_power_A);
            end
            if isfield(props,'constant_power_B')
                powerNom = powerNom + str2num(props.constant_power_B);
            end
            if isfield(props,'constant_power_C')
                powerNom = powerNom + str2num(props.constant_power_C);
            end
            G.Nodes.NominalPower(iN) = real(powerNom);
        case 'node'
            % check for type and ID source node
            if isfield(props,'bustype')
                disp(['bustype for ',char(G.Nodes.Name(iN)),' (id ',num2str(iN),'); set as source']);
                if strcmpi(props.bustype,'SWING')
                    % swing bus is infinite bus (i.e. source)
                    G.Nodes.Type(iN) = 'source';
                else
                    warning('Unexpected node bustype (not "SWING")');
                end
            end
            G.Nodes.NominalPower(iN) = 0;
        case 'triplex_node'
            % update NominalPower
            powerNom = 0;
            if isfield(props,'power_12')
                powerNom = str2num(props.power_12);
            end
            G.Nodes.NominalPower(iN) = real(powerNom);
        case {'capacitor','meter','triplex_meter'}
            % nothing for these types
            G.Nodes.NominalPower(iN) = 0;
        otherwise
            error('Node type missing in switch loop')
    end
end

% remove unused properties
G.Nodes.glmName = [];
G.Nodes.ID = [];
G.Nodes.Line = [];
G.Nodes.Prop = [];
G.Nodes.DegreeIn = [];
G.Nodes.DegreeOut = [];
G.Nodes.DegreeSum = [];
    
% TROUBLESHOOT: plot
figure(2)
plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);

%% 3. EDGES: Convert some, extract and clean properties
G2 = G; % troubleshooting savepoint
% cell arrays for new and removed edges (added at end due to for loop)
edgeAddS = {};
edgeAddT = {};
edgeRemoveS = {};
edgeRemoveT = {};
% check edge types: either keep as edge or convert to node
for iE = 1:height(G.Edges)
    %length = 5; % default length
    props = G.Edges.Prop{iE};
    % check edge type
    switch lower(G.Edges.Type(iE))
        case {'overhead_line','underground_line','triplex_line'}
            G.Edges.Length(iE) = str2num(props.length);
        case 'parent'
            G.Edges.Length(iE) = 1;
        case {'transformer','switch','fuse','regulator'}
            % convert to node
            % check "status" property; should be "closed"
            if isfield(G.Edges.Prop{iE},'status')
                if ~strcmpi(G.Edges.Prop{iE}.status,'CLOSED')
                    warning(['Edge ',num2str(iE),' status is NOT closed']);
                end
            end
            % add as node
            newName = G.Edges.Name(iE);
            NodeProps = table(newName,G.Edges.Type(iE),0,...
                'VariableNames',{'Name','Type','NominalPower'});
            G = addnode(G,NodeProps);
            % track EndNodes for two new edges
            edgeAddS{end+1} = G.Edges.EndNodes{iE,1};
            edgeAddT{end+1} = char(newName);
            edgeAddS{end+1} = char(newName);
            edgeAddT{end+1} = G.Edges.EndNodes{iE,2};
            % track EndNodes to be removed
            edgeRemoveS{end+1} = G.Edges.EndNodes{iE,1};
            edgeRemoveT{end+1} = G.Edges.EndNodes{iE,2};
        otherwise
            error('Edge type missing in switch loop')
    end
end

% remove unused properties
G.Edges.glmName = [];
G.Edges.ID = [];
G.Edges.Line = [];
G.Edges.Prop = [];
% add new edges
for i = 1:numel(edgeAddS)
    % Name and Type empty string, Length 5
    EdgeProps = table({edgeAddS{i},edgeAddT{i}},"","",5,...
        'VariableNames',{'EndNodes','Name','Type','Length'});
    G = addedge(G,EdgeProps);
end
% remove replaced edges
for i = 1:numel(edgeRemoveS)
    G = rmedge(G,edgeRemoveS{i},edgeRemoveT{i});
end

% TROUBLESHOOT: plot
figure(3)
plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);

%% 4. IDENTIFY SOURCE NODE and adjust directed edges
sourceID = find(G.Nodes.Type == 'source');
if isempty(sourceID)
    error('no source node found')
elseif numel(sourceID)>1
    error('multiple source nodes found')
end
G = redirectDigraph(G,sourceID);

% TROUBLESHOOT: plot
figure(4)
plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);

%% 5. REMOVE INLINE NODES AND MERGE EDGES
G4 = G; % troubleshooting savepoint
G.Edges.MergeLog(:) = ""; % property to record names
% searching for inline node, merge, search again, until none remain
flagSearch = 1;
loops1 = 0;
while flagSearch && loops1 < 10000
    iN = 0; % candidate node
    loops1 = loops1 + 1;
    flagFound = 0; % flag for inline discovered
    % check each node ID until one is found or all checked
    while flagFound==0 && iN<height(G.Nodes)
        iN = iN+1;
        % if one of candidate node types
        if max(strcmpi(G.Nodes.Type(iN),{'meter','triplex_meter','node','triplex_node'}))
        
            % if only one edge in and one edge out
            if (indegree(G,iN)==1)&&(outdegree(G,iN)==1)
                edgeTypeIn = G.Edges.Type(inedges(G,iN));
                edgeTypeOut = G.Edges.Type(outedges(G,iN));
                
                % if in edge or out edge matches type to be consolidated
                if max(strcmpi(edgeTypeIn,{'parent',''})) || max(strcmpi(edgeTypeOut,{'parent',''}))
                    flagFound = 1; % inline discovered
                    if G.Nodes.NominalPower(iN) ~= 0
                        error('Nominal Power should be zero for inline nodes')
                    end
                    % EndNodes
                    edgeAddS = G.Nodes.Name{predecessors(G,iN)};
                    edgeAddT = G.Nodes.Name{successors(G,iN)};
                    % replacement edge name and type
                    if ~max(strcmpi(edgeTypeIn,{'parent',''}))
                        % if in edge is relevant (both can't be relevant)
                        edgeAddName = G.Edges.Name(inedges(G,iN));
                        edgeAddType = G.Edges.Type(inedges(G,iN));
                        edgeAddLength = G.Edges.Length(inedges(G,iN));
                    elseif ~max(strcmpi(edgeTypeOut,{'parent',''}))
                        % if out edge is relevant (both can't be relevant)
                        edgeAddName = G.Edges.Name(outedges(G,iN));
                        edgeAddType = G.Edges.Type(outedges(G,iN));
                        edgeAddLength = G.Edges.Length(outedges(G,iN));
                    else
                        % else leave name and type blank
                        edgeAddName = "";
                        edgeAddType = "";
                        edgeAddLength = 1;
                    end
                    % generate MergeLog string
                    edgeMergeLogIn = G.Edges.MergeLog(inedges(G,iN));
                    edgeMergeLogOut = G.Edges.MergeLog(outedges(G,iN));
                    edgeAddMergeLog = strcat(edgeMergeLogIn,'_',G.Nodes.Name{iN},'_',edgeMergeLogOut);
                    % add new edge
                    EdgeProps = table({edgeAddS,edgeAddT},...
                    edgeAddName,edgeAddType,edgeAddLength,edgeAddMergeLog,...
                        'VariableNames',{'EndNodes','Name','Type','Length','MergeLog'});
                    G = addedge(G,EdgeProps);
                    % remove old node (also removes connected edges)
                    G = rmnode(G,G.Nodes.Name{iN});
                end
            end
        end
    end
    if flagFound == 0
        % no inline nodes discovered, stop searching
        flagSearch = 0;
    end
end

% TROUBLESHOOT: plot
figure(5)
plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);

%% 6. REMOVE TERMINAL NODES THAT ARE NOT LOADS
G5 = G; % troubleshooting savepoint
G.Nodes.MergeLog(:) = ""; % property to record names
% searching for terminal node, merge, search again, until none remain
flagSearch = 1;
loops1 = 0;
while flagSearch && loops1 < 10000
    iN = 0; % candidate node
    loops1 = loops1 + 1;
    flagFound = 0; % flag for terminal node discovered
    while flagFound==0 && iN<height(G.Nodes)
        iN = iN+1;
        % if terminal node
        if isempty(outedges(G,iN)) && strcmpi(G.Nodes.Type(iN),'node')
            flagFound = 1;
            % add node and edge name to upstream node MergeLog
            upNodeID = predecessors(G,iN);
            edgeID = inedges(G,iN);
            G.Nodes.MergeLog(upNodeID) = ...
                strcat(G.Nodes.MergeLog(upNodeID),'_',...
                G.Edges.Name(edgeID),'_',G.Nodes.Name(iN));
            % remove node
            G = rmnode(G,iN);
        end
    end
    if flagFound == 0
        % no terminal nodes discovered, stop searching
        flagSearch = 0;
    end
end

% TROUBLESHOOT: list terminal node types
disp('--Terminal Node Types--');
for iN = 1:height(G.Nodes)
   if isempty(outedges(G,iN))
       disp(G.Nodes.Type(iN));
   end
end

% TROUBLESHOOT: plot
figure(6)
plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);

%% SAVE
% (In new folder)
save([pwd,'\output\',char(modelName),'.mat'],'G','modelName')


