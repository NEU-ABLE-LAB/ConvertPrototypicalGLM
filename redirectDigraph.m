function G = redirectDigraph(Gin,sourceID)
    % redirect all directed edges, with sourceID node as top of hierarchy

    G = Gin;
    G.Edges.Checked = zeros(height(G.Edges),1);
    G.Nodes.Checked = zeros(height(G.Nodes),1);
    
    nodeIDs = sourceID; % start with input source
        
    loops = 0;
    flipFlag = 0; % set as true if edge ever needed to be flipped
    while ~isempty(nodeIDs) && loops < 1000
        loops = loops + 1;
        nextNodes = [];     % clear next interation of nodes
        for iN = 1:numel(nodeIDs)
            % for each node in nodeID list
            nodeID = nodeIDs(iN);
            G.Nodes.Checked(nodeID) = 1;
            % OUT EDGES
            outEdges = outedges(G,nodeID);
            for iE = 1:numel(outEdges)
                edgeID = outEdges(iE);
                % flag as Checked
                G.Edges.Checked(edgeID) = 1;
                % add nodes list for next iteration (unless already checked)
                t = findnode(G,G.Edges.EndNodes{edgeID,2});
                if G.Nodes.Checked(t) == 0
                    nextNodes(end+1) = t;
                end
            end
            % IN EDGES
            inEdges = inedges(G,nodeID);
            flipList = [];
            % STEP 1: check, update and record
            for iE = 1:numel(inEdges)
                edgeID = inEdges(iE);
                if ~G.Edges.Checked(edgeID)
                    % only flip if not already Checked
                    flipList(end+1) = edgeID;
                    G.Edges.Checked(edgeID) = 1;
                    % add nodes list for next iteration (unless already checked)
                    s = findnode(G,G.Edges.EndNodes{edgeID,1});
                    if G.Nodes.Checked(s) == 0
                        nextNodes(end+1) = s;
                    end
                end
            end
            % STEP 2: flip edges
            if ~isempty(flipList)
                flipFlag = 1;
                disp('Edges flipped:')
                disp(num2str(flipList(:)));
                G = flipedge(G,flipList);
            end
            
        end
    
        nodeIDs = nextNodes;
        
    end
    
    if ~flipFlag
        disp('No edges needed to be flipped')
    end
    
    if min(G.Edges.Checked(:)) == 0
        warning('Edges not checked:')
        disp(G.Edges.EndNodes(find(~G.Edges.Checked),:))
    end
    if min(G.Nodes.Checked(:)) == 0
        warning('Nodes not checked:')
        disp(G.Nodes.Name(find(~G.Nodes.Checked)))
    end

    % remove flag variables
    G.Edges.Checked = [];
    G.Nodes.Checked = [];
    
    
end