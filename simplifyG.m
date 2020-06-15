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

%% LOAD
addpath([pwd,'\results\'])
% test case
load('R1-12.47-3.mat')

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
            if isfield(props,'power_1')
                powerNom = powerNom + str2num(props.power_1);
            end
            if isfield(props,'power_2')
                powerNom = powerNom + str2num(props.power_2);
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

    %NodeProps = table(G.Nodes.Name(iN),G.Nodes.Type(iN),powerNom/1000,...
    %            'VariableNames',{'Name','Type','KWnom'});
    %Gt = addnode(Gt,NodeProps);

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
            % keep as edge, weight = Prop.length
            %sNode = G.Edges.EndNodes{iE,1};
            %tNode = G.Edges.EndNodes{iE,2};
            %EdgeProps = table({G.Edges.Name{iE}},{G.Edges.Type{iE}},...
            %    str2double(G.Edges.Prop{iE}.length),...
            %    'VariableNames',{'Name','Type','Weight'});
            %Gt = addedge(Gt,sNode,tNode,EdgeProps);
        
        case 'parent'
            G.Edges.Length(iE) = 1;
            % keep as edge, weight (length equivalent) = 5
            %sNode = G.Edges.EndNodes{iE,1};
            %tNode = G.Edges.EndNodes{iE,2};
            %EdgeProps = table({G.Edges.Name{iE}},{G.Edges.Type{iE}},5,...
            %    'VariableNames',{'Name','Type','Weight'});
            %Gt = addedge(Gt,sNode,tNode,EdgeProps);
        
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
            % connect to each end node, weight (length equivalent) = 5
            %sNode = G.Edges.EndNodes{iE,1};
            %tNode = G.Edges.EndNodes{iE,2};
            %EdgeProps = table({' '},{'new'},5,...
            %    'VariableNames',{'Name','Type','Weight'});
            %Gt = addedge(Gt,sNode,G.Edges.Name{iE},EdgeProps);
            %Gt = addedge(Gt,G.Edges.Name{iE},tNode,EdgeProps);            
        otherwise
            error('Edge type missing in switch loop')
    end
end
% add edges (default length 5)
for i = 1:numel(edgeAddS)
    EdgeProps = table("","",5,...
        'VariableNames',{'Name','Type','Weight'});
    %Gt = addedge(Gt,edgeAddS{i},edgeAddT{i},EdgeProps);
    G = addedge(G,edgeAddS{i},edgeAddT{i});
end

% ## remove edges
for i = 1:numel(edgeRemoveS)
    G = rmedge(G,edgeRemoveS{i},edgeRemoveT{i});
end

% TROUBLESHOOT: plot
figure(3)
plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);

%% 4. IDENTIFY SOURCE NODE and adjust directed edges
sourceID = find(Gt.Nodes.Type == 'source');
if isempty(sourceID)
    error('no source node found')
elseif numel(sourceID)>1
    error('multiple source nodes found')
end
Gt = redirectDigraph(Gt,sourceID);

% TROUBLESHOOT: plot
figure(2)
p2 = plot(Gt,'Layout','layered','NodeLabel',Gt.Nodes.Name,...
    'EdgeLabel',Gt.Edges.Name);
title('Gt (all edges, direction fixed)')

%% 5. REMOVE METERS
% TODO: keep history of removed nodes/edges (history Prop)
edgeAddS = {};
edgeAddT = {};
edgeAddName = {};
edgeAddType = {};
edgeAddWeight = [];
removeNodeList = {};
for iN = 1:height(Gt.Nodes)
    % meter type
    if strcmpi(Gt.Nodes.Type(iN),'meter') || strcmpi(Gt.Nodes.Type(iN),'triplex_meter')
        % remove all meters (expected to be inline)
        if (indegree(Gt,iN)==1)&&(outdegree(Gt,iN)==1)
            edgeAddS{end+1} = Gt.Nodes.Name(predecessors(Gt,iN));
            edgeAddT{end+1} = Gt.Nodes.Name(successors(Gt,iN));
            edgeAddName{end+1} = ' ';
            edgeAddType{end+1} = 'meter';
            edgeAddWeight(end+1) = 5;
            removeNodeList{end+1} = Gt.Nodes.Name{iN};
        else
            warning(['Unexpected degree for meter node ',num2str(iN)]);
        end
    end
end
% add edges
for i = 1:size(edgeAddS,2)
    EdgeProps = table(edgeAddName(i),edgeAddType(i),edgeAddWeight(i),...
        'VariableNames',{'Name','Type','Weight'});
    Gt = addedge(Gt,edgeAddS{i},edgeAddT{i},EdgeProps);
end
% remove nodes (keep after adding edges)
Gt = rmnode(Gt,removeNodeList);

%% 6. REMOVE EXTRA NODES
edgeAddS = {};
edgeAddT = {};
edgeAddName = {};
edgeAddType = {};
edgeAddWeight = [];
removeNodeList = {};
for iN = 1:height(Gt.Nodes)
    % node type
    if max(strcmpi(Gt.Nodes.Type(iN),{'node','triplex_node'}))
        % remove node nodes at the end of a line
        %if (indegree(Gt,iN)==0)||(outdegree(Gt,iN)==0)
        %    removeNodeList{end+1} = Gt.Nodes.Name{iN};
        %end
        % if between two nodes
        if (indegree(Gt,iN)==1)&&(outdegree(Gt,iN)==1)
            % remove if one edge is from the previous simplification
            if strcmpi(Gt.Edges.Type{inedges(Gt,iN)},'new')
                edgeAddS{end+1} = Gt.Nodes.Name(predecessors(Gt,iN));
                edgeAddT{end+1} = Gt.Nodes.Name(successors(Gt,iN));
                edgeAddName{end+1} = ' ';
                edgeAddType{end+1} = Gt.Edges.Type{outedges(Gt,iN)};
                edgeAddWeight(end+1) = 5;
                removeNodeList{end+1} = Gt.Nodes.Name{iN};
            elseif strcmpi(Gt.Edges.Type{outedges(Gt,iN)},'new')
                edgeAddS{end+1} = Gt.Nodes.Name(predecessors(Gt,iN));
                edgeAddT{end+1} = Gt.Nodes.Name(successors(Gt,iN));
                edgeAddName{end+1} = ' ';
                edgeAddType{end+1} = Gt.Edges.Type{inedges(Gt,iN)};
                edgeAddWeight(end+1) = 5;
                removeNodeList{end+1} = Gt.Nodes.Name{iN};
            end
        end
    end
end
% add edges
for i = 1:size(edgeAddS,2)
    EdgeProps = table(edgeAddName(i),edgeAddType(i),edgeAddWeight(i),...
        'VariableNames',{'Name','Type','Weight'});
    Gt = addedge(Gt,edgeAddS{i},edgeAddT{i},EdgeProps);
end
% remove nodes (after adding edges)
Gt = rmnode(Gt,removeNodeList);

%% 7. REMOVE TERMINAL NODES THAT ARE NOT LOADS
%disp('Initial end node types:')
%disp(unique(endTypes(Gt))')
removeTypes = {'node','triplex_node','switch','transformer','fuse'};
loops = 0;
while ~min(unique(endTypes(Gt))=="load") && loops < 100
    loops = loops + 1;
    removeNodeList = {};
    for iN = 1:height(Gt.Nodes)
        if outdegree(Gt,iN)==0 && max(strcmpi(Gt.Nodes.Type(iN),removeTypes))
            removeNodeList{end+1} = Gt.Nodes.Name{iN};
        end
    end
    Gt = rmnode(Gt,removeNodeList);
end

%% TROUBLESHOOT: plot
%figure(3)
%p3 = plot(Gt,'Layout','layered','NodeLabel',Gt.Nodes.Name,...
%    'EdgeLabel',Gt.Edges.Name);
%title('Gt (translated and edges adjusted)')


% tabel of pairs
%[t1,t2] = typePairs(Gt)

%% SAVE
% (In new folder)
