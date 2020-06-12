function Gout = redirectDigraph(Gin,sourceID)
    % redirect all directed edges, with sourceID node as top of hierarchy

    Gout = Gin;
    Gout.Edges.Checked = zeros(height(Gout.Edges),1);
    Gout.Nodes.Checked = zeros(height(Gout.Nodes),1);
    
    nodeIDs = sourceID; % start with input source
        
    loops = 0;
    while ~isempty(nodeIDs) && loops < 1000
        loops = loops + 1;
        nextNodes = [];     % clear next interation of nodes
        for iN = 1:numel(nodeIDs)
            % for each node in nodeID list
            nodeID = nodeIDs(iN);
            Gout.Nodes.Checked(nodeID) = 1;
            % OUT EDGES
            outEdges = outedges(Gout,nodeID);
            for iE = 1:numel(outEdges)
                edgeID = outEdges(iE);
                % flag as Checked
                Gout.Edges.Checked(edgeID) = 1;
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
                if ~Gout.Edges.Checked(edgeID)
                    % only flip if not already Checked
                    flipList(end+1) = edgeID;
                    Gout.Edges.Checked(edgeID) = 1;
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
    
        nodeIDs = nextNodes;
        
    end
    
    if min(Gout.Edges.Checked(:)) == 0
        warning('Edges not checked:')
        disp(Gout.Edges.EndNodes(find(~Gout.Edges.Checked),:))
    end
    if min(Gout.Nodes.Checked(:)) == 0
        warning('Nodes not checked:')
        disp(Gout.Nodes.Name(find(~Gout.Nodes.Checked)))
    end

    % remove flag variables
    Gout.Edges.Checked = [];
    Gout.Nodes.Checked = [];
    
    
end