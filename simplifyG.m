% translateG
% take the results from convertGLM / glm2net and translate
% G is the 
%% TO DO:
% - convert to function
% - consider: display as "layered" for hierarchy & impact of length on plotting
% - create "simple" version

%%
addpath([pwd,'\results\'])
% test case
load('R1-12.47-3.mat')

%figure(1)
%p1 = plot(G,'Layout','force','NodeLabel',G.Nodes.Name,...
%    'EdgeLabel',G.Edges.Name);
%title('G (Initial)')

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
% Note: Edge Names do not need to be unique


% ** next: convert node and edge representation

% Initial node types:
%   load: keep node, calculate nominalKW
%   meter: consider removing 
%   node: consider removing (if k_in = k_out = 1)
%       ** not always the case (can be more), what if k_out = 0?
%   triplex_meter: consider removing
%   triplex_node: consider removing
%   ...more???
% Initial edge types:
%   overhead_line: keep as edge, weight = Prop.length
%   underground_line: keep as edge, weight = Prop.length
%   parent: ?? (no Props available)
%   transformer: convert to node
%   switch: convert to node (check Prop.status == CLOSED)
%   fuse: convert to node (check Prop.status == CLOSED)
%   regulator: convert to node
%   triplex_line: keep as edge, weight = Prop.length
%   ...more???

% For new edges, use Weight = 5, Name = ""

Gt = digraph;
% first convert all nodes
for iN = 1:height(G.Nodes)
    powerNom = 0; % default nominal power
    % special cases for each node type
    switch lower(G.Nodes.Type(iN))
        case 'load'
            if isfield(G.Nodes.Prop{iN},'constant_power_A')
                powerNom = powerNom + str2num(G.Nodes.Prop{iN}.constant_power_A);
            end
            if isfield(G.Nodes.Prop{iN},'constant_power_B')
                powerNom = powerNom + str2num(G.Nodes.Prop{iN}.constant_power_B);
            end
            if isfield(G.Nodes.Prop{iN},'constant_power_C')
                powerNom = powerNom + str2num(G.Nodes.Prop{iN}.constant_power_C);
            end
        case 'meter'
        case 'node'
        case 'triplex_meter'
        case 'triplex_node'
        case 'capacitor'
        otherwise
            error('Node type missing in switch loop')
    end
    NodeProps = table(G.Nodes.Name(iN),G.Nodes.Type(iN),powerNom/1000,...
                'VariableNames',{'Name','Type','KWnom'});
    Gt = addnode(Gt,NodeProps);
    
end
% then convert edges: either keep as edge or convert to ndoe
for iE = 1:height(G.Edges)
    length = 5; % default length
    % special cases for each edge type
    switch lower(G.Edges.Type(iE))
        case {'overhead_line','underground_line','triplex_line'}
            % keep as edge, weight = Prop.length
            sNode = G.Edges.EndNodes{iE,1};
            tNode = G.Edges.EndNodes{iE,2};
            EdgeProps = table({G.Edges.Name{iE}},{G.Edges.Type{iE}},...
                str2double(G.Edges.Prop{iE}.length),...
                'VariableNames',{'Name','Type','Weight'});
            Gt = addedge(Gt,sNode,tNode,EdgeProps);
        case 'parent'
            % keep as edge, weight (length equivalent) = 5
            sNode = G.Edges.EndNodes{iE,1};
            tNode = G.Edges.EndNodes{iE,2};
            EdgeProps = table({G.Edges.Name{iE}},{G.Edges.Type{iE}},5,...
                'VariableNames',{'Name','Type','Weight'});
            Gt = addedge(Gt,sNode,tNode,EdgeProps);
        case {'transformer','switch','fuse','regulator'}
            % check status property
            if isfield(G.Edges.Prop{iE},'status')
                if ~strcmpi(G.Edges.Prop{iE}.status,'CLOSED')
                    warning(['Edge ',num2str(iE),' status is NOT closed']);
                end
            end
            % add as node
            NodeProps = table(G.Edges.Name(iE),G.Edges.Type(iE),0,...
                'VariableNames',{'Name','Type','KWnom'});
            Gt = addnode(Gt,NodeProps);
            % connect to each end node, weight (length equivalent) = 5
            sNode = G.Edges.EndNodes{iE,1};
            tNode = G.Edges.EndNodes{iE,2};
            EdgeProps = table({' '},{'new'},5,...
                'VariableNames',{'Name','Type','Weight'});
            Gt = addedge(Gt,sNode,G.Edges.Name{iE},EdgeProps);
            Gt = addedge(Gt,G.Edges.Name{iE},tNode,EdgeProps);            
            
            
        otherwise
            error('Edge type missing in switch loop')
    end
end
            
            %   parent: ?? (no Props available)
%   transformer: convert to node
%   switch: convert to node (check Prop.status == CLOSED)
%   fuse: convert to node (check Prop.status == CLOSED)
%   regulator: convert to node
%   triplex_line:

edgeAddS = {};
edgeAddT = {};
edgeAddName = {};
edgeAddType = {};
edgeAddWeight = [];
removeNodeList = {};
for iN = 1:height(Gt.Nodes)
    % meter type
    if strcmpi(Gt.Nodes.Type(iN),'meter')
        % remove all meters
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
    % node type
    if strcmpi(Gt.Nodes.Type(iN),'node')
        % remove node nodes at the end of a line
        if (indegree(Gt,iN)==0)||(outdegree(Gt,iN)==0)
            removeNodeList{end+1} = Gt.Nodes.Name{iN};
        end
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
% remove nodes (keep after adding edges)
Gt = rmnode(Gt,removeNodeList);

% ** node 'reg-1' is all alone!

%% IDENTIFY SOURCE NODE and adjust directed edges
% TROUBLESHOOT ONLY (not valid source node)
Gt = redirectDigraph(Gt,18);


figure(2)
%p2 = plot(Gt,'NodeLabel',Gt.Nodes.Name,'EdgeLabel',Gt.Edges.Name);
p2 = plot(Gt,'Layout','auto','NodeLabel',Gt.Nodes.Name,...
    'EdgeLabel',Gt.Edges.Name);
%p2 = plot(Gt,'Layout','direct','NodeLabel',Gt.Nodes.Name,...
%    'EdgeLabel',Gt.Edges.Name,'WeightEffect','direct');
%p2 = plot(Gt,'Layout','force','NodeLabel',Gt.Nodes.Name,...
%    'EdgeLabel',Gt.Edges.Name,'WeightEffect','direct',...
%    'UseGravity','on','Iterations',1);
title('Gt (translated and edges adjusted)')


% tabel of pairs
[t1,t2] = typePairs(Gt)



