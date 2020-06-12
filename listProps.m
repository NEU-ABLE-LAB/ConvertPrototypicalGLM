% list unique type-property combos across all raw graphs

feederIDs = ["GC-12.47-1", "R1-12.47-1", "R1-12.47-2", "R1-12.47-3",...
    "R1-12.47-4", "R1-25.00-1", "R2-12.47-1", "R2-12.47-2", "R2-12.47-3",...
    "R2-25.00-1", "R2-35.00-1", "R3-12.47-1", "R3-12.47-2", "R3-12.47-3",...
    "R4-12.47-1", "R4-12.47-2", "R4-25.00-1", "R5-12.47-1", "R5-12.47-2",...
    "R5-12.47-3", "R5-12.47-4", "R5-12.47-5", "R5-25.00-1", "R5-35.00-1"];

propTypes = string.empty;

for iFeeder = 1:numel(feederIDs)
    feederID = feederIDs(iFeeder);
    % load raw graph
    load([char(feederID),'.mat'])

    %{
    for iN = 1:height(G.Nodes)
        props = fields(G.Nodes.Prop{iN});
        for iP = 1:numel(props)
            propTypes(end+1) = [G.Nodes.Type{iN},'-',props{iP}];
            %if strcmpi(propTypes(end),"triplex_node-power_12")
            %    disp(num2str(iN))
            %end
        end
    end
    %}
    
    for iE = 1:height(G.Edges)
        props = fields(G.Edges.Prop{iE});
        for iP = 1:numel(props)
            propTypes(end+1) = [G.Edges.Type{iE},'-',props{iP}];
            %if strcmpi(propTypes(end),"triplex_node-power_12")
            %    disp(num2str(iN))
            %end
        end
    end
    
end

propTypes = propTypes';
disp(unique(propTypes))
