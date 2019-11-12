function [pairTableDir,pairTableUndir] = typePairs(G)
% returns list of all unique pairs of node types connected by an edge
% input: G, must have attribute "Type" for nodes



    for iE = 1:height(G.Edges)
        s = findnode(G,G.Edges.EndNodes{iE,1});
        t = findnode(G,G.Edges.EndNodes{iE,2});
        typePair = strcat(G.Nodes.Type(s),"-",G.Nodes.Type(t));
        % directed pairs
        if iE == 1
            pairListDir(1) = typePair; % initialize string array
            pairIndicesDir{1} = [iE];  % initialize cell array
        else
            iFind = find(pairListDir == typePair);
            if isempty(iFind)
                pairListDir(end+1) = typePair;
                pairIndicesDir{end+1} = [iE];
            else
                pairIndicesDir{iFind}(end+1) = iE;
            end
        end
        % undirected pairs
        typePairFlip = strcat(G.Nodes.Type(t),"-",G.Nodes.Type(s));
        if iE == 1
            pairListUndir(1) = typePair; % initialize string array
            pairIndicesUndir{1} = [iE];  % initialize cell array
        else
            iFind = find(pairListUndir == typePair);
            if isempty(iFind)
                iFind2 = find(pairListUndir == typePairFlip);
                if isempty(iFind2)
                    pairListUndir(end+1) = typePair;
                    pairIndicesUndir{end+1} = [iE];
                else
                    pairIndicesUndir{iFind2}(end+1) = iE;
                end
            else
                pairIndicesUndir{iFind}(end+1) = iE;
            end
        end
    end
    
    pairTableDir = table(pairListDir',cellfun(@length,pairIndicesDir)',...
        pairIndicesDir','VariableNames',{'DirectedPair','Total','Indices'});
    pairTableUndir = table(pairListUndir',cellfun(@length,pairIndicesUndir)',...
        pairIndicesUndir','VariableNames',{'UndirectedPair','Total','Indices'});
    
    
    
end