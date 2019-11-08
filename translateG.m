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
            EdgeProps = table({' '},{"new"},5,...
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

for iN = 1:height(Gt.Nodes)
    if strcmpi(Gt.Nodes.Type(iN),'meter')
        
    end
    
end




%p = plot(Gt,'NodeLabel',Gt.Nodes.Name,'EdgeLabel',Gt.Edges.Name);

p = plot(Gt,'Layout','force','NodeLabel',Gt.Nodes.Name,...
    'EdgeLabel',Gt.Edges.Name);

%p = plot(Gt,'Layout','force','NodeLabel',Gt.Nodes.Name,...
%    'EdgeLabel',Gt.Edges.Name,'WeightEffect','direct',...
%    'UseGravity','on','Iterations',1);



