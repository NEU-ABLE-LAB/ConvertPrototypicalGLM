function G = redirectDigraph(Gin,sourceID)
    % redirect all directed edges, with sourceID node as top of hierarchy
    % displays update when edges are flipped
    % Inputs:
    %   Gin: digraph object; designed and verified for hierarchical form
    %   sourceID: node index from which edges should originate
    % Output:
    %   G: digraph with same nodes and edges, edges flipped if needed

    
    G = Gin;
    G.Edges.Checked = zeros(height(G.Edges),1);
    G.Nodes.Checked = zeros(height(G.Nodes),1);
    
    disp(['...checking edge directions, starting from source ',...
        G.Nodes.Name{sourceID},' (index ',num2str(sourceID),')...'])
    
    % initialize
    nodeIDs = sourceID; % start with input source
    loops = 0;          % loop count to break while loop
    allFlips = [];      % record all flips
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
                allFlips = [allFlips,flipList]; % record with all other flips
                G = flipedge(G,flipList);
            end
            
        end
    
        nodeIDs = nextNodes;
        
    end
    
    if isempty(allFlips)
        disp('No edges were flipped')
        disp(' ')
    else
        disp('The following edge indices were flipped:')
        disp(allFlips');
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