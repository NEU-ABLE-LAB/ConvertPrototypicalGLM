function Gout = redirectDigraph(Gin,sourceID)
    % redirect all directed edges, with sourceID node as top of hierarchy
    % Gout is a DAG

    if ~isdag(Gin)
        % DELETE EVENTUALLY: this is not the check needed
        error('Input digraph must be Directed Acyclic Graph (DAG)')
    end

    Gout = Gin;
    Gout.Edges.Adjusted = zeros(height(Gout.Edges),1);
    Gout.Nodes.Checked = zeros(height(Gout.Nodes),1);
    
    nodeIDs = sourceID; % start with input source
    nextNodes = [];     % next iteration of nodes
    
    for iN = 1:numel(nodeIDs)
        % for each node in nodeID list
        nodeID = nodeIDs(iN);
        % OUT EDGES
        outEdges = outedges(Gout,nodeID);
        for iE = 1:numel(outEdges)
            edgeID = outEdges(iE);
            % flag as adjusted
            Gout.Edges.Adjusted(edgeID) = 1;
            % add nodes list for next iteration (unless already checked)
            t = findnode(Gout,Gout.Edges.EndNodes{edgeID,2});
            if Gout.Nodes.Checked(t) == 0
                nextNodes(end+1) = t;
            end
        end
        % IN EDGES
        inEdges = inedges(Gout,nodeID);
        flipList = [];
        % STEP 1: check, update and record
        for iE = 1:numel(inEdges)
            edgeID = inEdges(iE);
            % check to see if already adjusted
            if Gout.Edges.Adjusted
                warning(['Attempted to flip edge from ',
                    Gout.Edges.EndNodes{edgeID,1},' to ',
                    Gout.Edges.EndNodes{edgeID,2},' again']);
            else
                flipList(end+1) = edgeID;
                Gout.Edges.Adjusted(edgeID) = 1;
                % add nodes list for next iteration (unless already checked)
                s = findnode(Gout,Gout.Edges.EndNodes{edgeID,1});
                if Gout.Nodes.Checked(s) == 0
                    nextNodes(end+1) = s;
                end
            end
        end
        % STEP 2: flip edges
        Gout = flipedge(Gout,flipList);
    end
    
       
    %warning('edge already adjusted');

    % remove flag variables
    %Gout.Edges.Adjusted = [];
    %Gout.Nodes.Checked = [];
    
    
end