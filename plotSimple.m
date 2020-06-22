function plotSimple(modelName,G,labelFlag,figNum)
    % plot simplified graph
    
    %% TO DO
    % - consider: display as "layered" for hierarchy & impact of length on plotting
    

    %% LOAD
    %modelName = 'R1-12.47-3';
    %addpath([pwd,'\output\'])
    % test case
    %load([modelName,'.mat'])


    %G.Edges.Weight = G.Edges.Length;

    hFig = figure(figNum);
    clf
    hold on

    %hPlot = plot(G);
    hPlot = plot(G,'Layout','layered');
    %hPlot = plot(G,'Layout','layered',...
    %    'Direction','right','AssignLayers','asap');
    %hPlot = plot(G,'Layout','force', ...
    %    'WeightEffect','direct','Iterations',20,'UseGravity','on', ...
    %    'XStart',hPlot.XData,'YStart',hPlot.YData);
    %hPlot = plot(G,'Layout','force', ...
    %    'WeightEffect','direct','Iterations',2,'UseGravity','off');

    % auto-generated plot boundaries
    ylims = ylim;
    xlims = xlim;
    % legend marker locations (outside plot)
    x = 2*xlims(2);
    y = 2*ylims(2);

    % set node highlights
    
    highlight(hPlot,find(G.Nodes.Type=={'load'}),...
        'NodeColor',[0.6350 0.0780 0.1840],'Marker','square','MarkerSize',4);
    hLoad = scatter(x,y,8,[0.6350 0.0780 0.1840],'filled','s','DisplayName','Load');
    
    highlight(hPlot,find(G.Nodes.Type=='node'),...
        'NodeColor',[0 0 0],'Marker','o','MarkerSize',2);
    hNode = scatter(x,y,2,[0 0 0],'filled','o','DisplayName','Node');

    highlight(hPlot,find(G.Nodes.Type=='fuse'),...
        'NodeColor',[1 0 1],'Marker','square','MarkerSize',3);
    hFuse = scatter(x,y,4,[1 0 1],'filled','s','DisplayName','Fuse');
    
    highlight(hPlot,find(G.Nodes.Type=='recloser'),...
        'NodeColor',[1 0 1],'Marker','s');
    hRecloser = scatter(x,y,4,[1 0 1],'filled','s','DisplayName','Recloser');

    highlight(hPlot,find(G.Nodes.Type=='regulator'),...
        'NodeColor',[1 0 1],'Marker','square','MarkerSize',3);
    hRegulator = scatter(x,y,4,[1 0 1],'filled','s','DisplayName','Regulator');
    
    

    highlight(hPlot,find(G.Nodes.Type=='source'),...
        'NodeColor',[0.9290 0.6940 0.1250],'Marker','square','MarkerSize',5);
    hSource = scatter(x,y,10,[0.9290 0.6940 0.1250],'filled','s','DisplayName','Source');

    highlight(hPlot,find(G.Nodes.Type=='switch'),...
        'NodeColor',[0.4940 0.1840 0.5560],'Marker','o','MarkerSize',3);
    hSwitch = scatter(x,y,4,[0.4940 0.1840 0.5560],'filled','o','DisplayName','Switch');

    highlight(hPlot,find(G.Nodes.Type=='transformer'),...
        'NodeColor',[0 0 0],'Marker','^','MarkerSize',3);
    hTransformer = scatter(x,y,5,[0 0 0],'filled','^','DisplayName','Transformer');



    % set edge highlights
    eIDs = find(G.Edges.Type=='overhead_line');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0 0 0],'LineStyle','-','LineWidth',1.5,'ArrowSize',0);
    hOverhead = plot(x,y,'Color',[0 0 0],'LineStyle','-','LineWidth',2,'DisplayName','Overhead Line');

    eIDs = find(G.Edges.Type=='underground_line');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0 0 0],'LineStyle',':','LineWidth',1.5,'ArrowSize',0);
    hUnderground = plot(x,y,'Color',[0 0 0],'LineStyle',':','LineWidth',2,'DisplayName','Underground Line');

    eIDs = find(G.Edges.Type=='triplex_line');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0.4660 0.6740 0.1880],'LineStyle','-.','LineWidth',1.5,'ArrowSize',0);
    hTriplex = plot(x,y,'Color',[0.4660 0.6740 0.1880],'LineStyle','-.','LineWidth',2,'DisplayName','Triplex Line');

    eIDs = find(G.Edges.Type=='');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0.5 0.5 0.5],'LineStyle','-','LineWidth',1.5,'ArrowSize',0);
    hDirect = plot(x,y,'Color',[0.5 0.5 0.5],'LineStyle','-','LineWidth',2,'DisplayName','Direct Connection');

    % restore plot boundary
    xlim(xlims);
    ylim(ylims);
    % add legend (in order selected, don't include nodes)
    hLegend = legend([hSource,hLoad,...
                    hSwitch,hFuse,hRecloser,hRegulator,...
                    hDirect,hTransformer,hOverhead,hUnderground,hTriplex]);
    set(hLegend         , ...
        'Location'      , 'best'     , ...
        'numColumns'    , 4     );
    % only label if flag set
    if labelFlag
        nodeLabels = string(G.Nodes.Name);
        nodeLabels(G.Nodes.Type=='node') = '';
        set(hPlot, ...
            'NodeLabel'     , nodeLabels      , ...
            'EdgeLabel'     , G.Edges.Name      );
    else
        set(hPlot, ...
            'NodeLabel'     , []      , ...
            'EdgeLabel'     , []      );
    end
    % general plot style
    set(gca         , ...
        'box'       , 'on'     , ...
        'XTick'     , []        , ...
        'YTick'     , []        );
    hTitle = title([char(modelName),' (simplified)']);






end