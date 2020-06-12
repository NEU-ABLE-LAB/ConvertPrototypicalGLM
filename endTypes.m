function [typeList,endIDs] = endTypes(G)
    % returns unique Node.Type for all nodes without outedges

    typeList = string.empty;
    endIDs = [];
    for iN = 1:height(G.Nodes)
        if isempty(outedges(G,iN))
            typeList(end+1) = G.Nodes.Type(iN);
            endIDs(end+1) = iN;
        end
    end
    
    typeList = typeList';
    endIDs = endIDs';


end

