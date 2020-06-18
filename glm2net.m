%% generate network from glm data string arrays
function G = glm2net(modelName,glmStrArray)


    %% settings (DELETE ME)
    %clear
    %load('glmStrData.mat')
    % begin for a specific model
    %iModel = 20;
    %modelName = feederIDs(iModel)
    %modelName = replace(modelName,".","-"); % match format in .glm names
    %glmStrArray = modelData{iModel};

    %% initialize
    %tic;
    disp(' ')
    disp(['...beginning conversion of model ',char(modelName),' to digraph...'])
    G = digraph;
    linkCellArray = {};
    nodeIndex = 0;
    objSearch = true;
    parentProps = table;
    conductorProps = table;
    spacingProps = table;
    configProps = table;

    %% loop through string array
    for iLine = 1:length(glmStrArray)
        lineChars = char(glmStrArray(iLine));
        if strfind(lineChars,"//")==1
            % if line begins with "//" do nothing (commented out in source)
        elseif objSearch
            if contains(lineChars,"object")
                % looking for new object and discovered one!
                objSearch = false;
                nodeIndex = nodeIndex + 1;
                % create blank node prop table
                NodeProps = table(string,true,string,string,NaN,{struct},...
                    'VariableNames',{'Name','glmName','ID','Type','Line','Prop'});
                NodeProps.Line = iLine;
                % find type of string in this rows
                indexSpace = strfind(lineChars," ");
                indexColon = strfind(lineChars,":");
                idStr = lineChars(indexSpace(1)+1:indexSpace(2)-1);
                typeStr = lineChars(indexSpace(1)+1:indexColon-1);
                if isempty(typeStr)
                    % at least one instance in which the colon is missing
                    typeStr = idStr;
                end
                NodeProps.Type = string(typeStr);
                NodeProps.ID = string(idStr);
            else
                % looking for a new object and still looking
            end
        else
            if contains(lineChars,"}")
                % working with an object and found the end
                if strcmpi(NodeProps.Name,"")
                    % if Name is blank, flag the node and create name from ID
                    NodeProps.glmName = false;
                    NodeProps.Name = strcat("id_",NodeProps.ID);
                     %skippedIndices(end+1) = NodeProps.Line;
                end
                if strcmpi(NodeProps.ID,'recorder')
                    % ignore all recorder types; only used in GridLAB-D
                elseif isfield(NodeProps.Prop{1},'to') && isfield(NodeProps.Prop{1},'from')
                    % check property fields to see if this is an edge
                    % save all links until after nodes have been added
                    linkCellArray{end+1} = NodeProps;
                else
                    % else add as a node
                    G = addnode(G,NodeProps);
                end
                objSearch = true; % begin the search again
            else
                % working with an object, still gathering properties
                if contains(lineChars,"name")
                    % name properties are special
                    indexSpace = strfind(lineChars," ");
                    indexSemicolon = strfind(lineChars,";");
                    nameStr = lineChars(indexSpace+1:indexSemicolon-1);
                    NodeProps.Name = string(nameStr);
                else
                    % otherwise store properties in structure
                    indexSpace = strfind(lineChars," ");
                    indexSemicolon = strfind(lineChars,";");
                    propStr = lineChars(1:indexSpace(1)-1);
                    propStr = replace(propStr,".","_"); % periods mess up field names
                    valStr = lineChars(indexSpace(1)+1:indexSemicolon-1);
                    NodeProps.Prop{1}.(propStr) = valStr;
                    % record details if field is parent, spacing, or conductor, or configuration
                    addTable = table(string(propStr),string(valStr),...
                            NodeProps.Line,NodeProps.Name,NodeProps.ID,...
                            'VariableNames',{'Type','Value','RefLine','RefName','RefID',});
                    if strcmpi(propStr,'parent') && ~strcmpi(NodeProps.ID,'recorder')
                        % ignore recorder objects
                        parentProps = [parentProps;addTable];
                    elseif strcmpi(propStr,'conductor_A') || ...
                            strcmpi(propStr,'conductor_B') || ...
                            strcmpi(propStr,'conductor_C') || ...
                            strcmpi(propStr,'conductor_1') || ...
                            strcmpi(propStr,'conductor_2') || ...
                            strcmpi(propStr,'conductor_N')
                        conductorProps = [conductorProps;addTable];
                    elseif strcmpi(propStr,'spacing')
                        spacingProps = [spacingProps;addTable];
                    elseif strcmpi(propStr,'configuration')
                        configProps = [configProps;addTable];
                    end
                end
            end
        end
    end
    %% clean up resulting digraph
    % add links from object with "from" and "to" properties
    for iLink = 1:length(linkCellArray)
        NodeProps = linkCellArray{iLink};
        s = NodeProps.Prop{1}.from;
        t = NodeProps.Prop{1}.to;
        EdgeTable = table({s,t},NodeProps.Name,NodeProps.glmName,NodeProps.ID,...
            NodeProps.Type,NodeProps.Line,{rmfield(NodeProps.Prop{1},{'from','to'})},...
            'VariableNames',{'EndNodes','Name','glmName','ID','Type','Line','Prop'});
        G = addedge(G,EdgeTable);
    end
    disp(['After object links, number of isolated nodes: ',num2str(sum((outdegree(G)+indegree(G))==0))])

    % incorporate parent relationships as links
    for iRel = 1:height(parentProps)
        s = char(parentProps.Value(iRel));
        t = char(parentProps.RefName(iRel));
        nameStr = strcat("parent-",parentProps.RefName(iRel));
        EdgeTable = table({s,t},nameStr,false,"","parent",parentProps.RefLine(iRel),{struct},...
            'VariableNames',{'EndNodes','Name','glmName','ID','Type','Line','Prop'});
        G = addedge(G,EdgeTable);
    end
    disp(['After parent links, number of isolated nodes: ',...
        num2str(sum((outdegree(G)+indegree(G))==0))])

    % incorporate conductor, spacing, then configuration properties when referenced by an object
    for i = 1:3
        switch i
            case 1
                propTable = conductorProps;
                label = 'conductor';
            case 2
                propTable = spacingProps;
                label = 'spacing';
            case 3
                propTable = configProps;
                label = 'configuration';
        end
        for iCon = 1:height(propTable)
            % access the properties as a structure
            configNodeIndex = find(G.Nodes.Name==propTable.Value(iCon),1);
            if isempty(configNodeIndex)
                % if not listed by name, check ID
                configNodeIndex = find(G.Nodes.ID==propTable.Value(iCon),1);
                if isempty(configNodeIndex)
                    warning(['this should not happen (finding config node) ',label]);
                end
            end
            configStruct = G.Nodes.Prop{configNodeIndex};
            % and add them to a node or edge prop
            destNodeIndex = find(G.Nodes.Name==propTable.RefName(iCon),1);
            if isempty(destNodeIndex)
                % check node IDs if not found by name
                destNodeIndex = find(G.Nodes.ID==propTable.RefID(iCon),1);
            end
            if ~isempty(destNodeIndex)
                % if destination is found as a node
                f = fieldnames(configStruct);
                for i = 1:length(f)
                   G.Nodes.Prop{destNodeIndex}.(strcat(propTable.Type(iCon),'_',(f{i}))) ...
                       = configStruct.(f{i}); 
                end
            else
                % else check for destination as an edge
                destEdgeIndex = find(G.Edges.Name==propTable.RefName(iCon),1);
                if isempty(destEdgeIndex)
                    % check edge IDs if not found by name
                    destEdgeIndex = find(G.Edges.ID==propTable.RefID(iCon),1);
                end
                if ~isempty(destEdgeIndex)
                    f = fieldnames(configStruct);
                    for i = 1:length(f)
                       G.Edges.Prop{destEdgeIndex}.(strcat(propTable.Type(iCon),'_',(f{i}))) ...
                           = configStruct.(f{i}); 
                    end
                else 
                    % when match not found for node or edge name or ID
                    warning(['this should not happen (applying properties) ',label]);
                end 
            end
        end
        % then remove configuration nodes from the graph
        uniqueConfigs = unique(propTable.Value(:));
        for iCon = 1:length(uniqueConfigs)
            configNodeIndex = find(G.Nodes.Name==uniqueConfigs(iCon),1);
            if isempty(configNodeIndex)
                % if not listed by name, check ID
                configNodeIndex = find(G.Nodes.ID==uniqueConfigs(iCon),1);
                if isempty(configNodeIndex)
                    warning(['this should not happen (node removal) ',label]);
                end
            end
            G = rmnode(G,configNodeIndex);
        end
        disp(['After ',label,' round of property application, number of isolated nodes: ',...
            num2str(sum((outdegree(G)+indegree(G))==0))])
    end

    % remove any remaining isolated nodes (should be unused configurations)
    isolatedTable = (G.Nodes((outdegree(G)+indegree(G))==0,:));
    if ~isempty(isolatedTable)
        disp('**After processing, the following nodes are isolated and will be removed')
        disp('  Verify they are all unused configuration objects');
        disp(isolatedTable.Name(:));
        for name = isolatedTable.Name(:)
           G = rmnode(G,name); 
        end
    end

    % add degrees to Nodes table
    G.Nodes.DegreeIn = indegree(G);
    G.Nodes.DegreeOut = outdegree(G);
    G.Nodes.DegreeSum = indegree(G)+outdegree(G);



    %% analyze and display results

    %toc;
    %figure;
    %plot(G,'Layout','force')
    %title(modelName)
    disp(['Conversion of model ',char(modelName),' to digraph COMPLETE'])
    disp(['  Number of Nodes: ',num2str(height(G.Nodes))]);
    disp(['  Number of Edges: ',num2str(height(G.Edges))]);


    %% optional review processes
    %{
    save(strcat(modelName,'.mat'),'G','modelName')

    %{
    % name property review
    disp(' ')
    disp('**Nodes that did not have "name" property in .glm: **')
    disp(G.Nodes(G.Nodes.glmName==false,:))
    disp('**Edges that did not have "name" property in .glm: **')
    disp(G.Edges(G.Edges.glmName==false,:))
    %}

    % property name review
    allProps = [];
    allTypeProps = [];
    for iNode = 1:height(G.Nodes)
        allProps = [allProps;string(fields(G.Nodes.Prop{iNode}))];
        allTypeProps = [allTypeProps;strcat(G.Nodes.Type(iNode)," - ",string(fields(G.Nodes.Prop{iNode})))];
    end
    for iEdge = 1:height(G.Edges)
        allProps = [allProps;string(fields(G.Edges.Prop{iEdge}))];
        allTypeProps = [allTypeProps;strcat(G.Edges.Type(iEdge)," - ",string(fields(G.Edges.Prop{iEdge})))];
    end
    % display summaries
    disp(' ')
    %disp('**Unique property names: **')
    %disp(unique(allProps))
    %disp(' ')
    %disp('**Unique type - property name pairs: **')
    typePropPairs = unique(allTypeProps);
    %disp(typePropPairs);
    disp(['Total number of unique type-prop pairs: ',num2str(length(typePropPairs))]);
    toc;
    %}

end

