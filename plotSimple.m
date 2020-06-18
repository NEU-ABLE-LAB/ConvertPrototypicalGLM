function plotSimple(modelName,G,labelFlag)
    % plot simplified graph

    %% LOAD
    %modelName = 'R1-12.47-3';
    %addpath([pwd,'\output\'])
    % test case
    %load([modelName,'.mat'])


    %G.Edges.Weight = G.Edges.Length;

    hFig = figure(10);
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
    highlight(hPlot,find(G.Nodes.Type=='fuse'),...
        'NodeColor',[1 0 1],'Marker','square','MarkerSize',3);
    hS(1) = scatter(x,y,4,[1 0 1],'filled','s','DisplayName','Fuse');

    highlight(hPlot,find(G.Nodes.Type=='load'),...
        'NodeColor',[0.6350 0.0780 0.1840],'Marker','square','MarkerSize',4);
    hS(2) = scatter(x,y,8,[0.6350 0.0780 0.1840],'filled','s','DisplayName','Load');

    highlight(hPlot,find(G.Nodes.Type=='node'),...
        'NodeColor',[0 0 0],'Marker','o','MarkerSize',2);
    hS(3) = scatter(x,y,2,[0 0 0],'filled','o','DisplayName','Node');

    highlight(hPlot,find(G.Nodes.Type=='recloser'),...
        'NodeColor',[1 0 1],'Marker','s');
    hS(4) = scatter(x,y,4,[1 0 1],'filled','s','DisplayName','Recloser');

    highlight(hPlot,find(G.Nodes.Type=='regulator'),...
        'NodeColor',[1 0 1],'Marker','square','MarkerSize',3);
    hS(5) = scatter(x,y,4,[1 0 1],'filled','s','DisplayName','Regulator');

    highlight(hPlot,find(G.Nodes.Type=='source'),...
        'NodeColor',[0.9290 0.6940 0.1250],'Marker','square','MarkerSize',5);
    hS(6) = scatter(x,y,10,[0.9290 0.6940 0.1250],'filled','s','DisplayName','Source');

    highlight(hPlot,find(G.Nodes.Type=='switch'),...
        'NodeColor',[0.4940 0.1840 0.5560],'Marker','o','MarkerSize',3);
    hS(7) = scatter(x,y,4,[0.4940 0.1840 0.5560],'filled','o','DisplayName','Switch');

    highlight(hPlot,find(G.Nodes.Type=='transformer'),...
        'NodeColor',[0 0 0],'Marker','^','MarkerSize',3);
    hS(8) = scatter(x,y,5,[0 0 0],'filled','^','DisplayName','Transformer');

    highlight(hPlot,find(G.Nodes.Type=='triplex_node'),...
        'NodeColor',[0.4660 0.6740 0.1880],'Marker','o','MarkerSize',4);
    hS(9) = scatter(x,y,8,[0.4660 0.6740 0.1880],'filled','o','DisplayName','Triplex Node');

    % set edge highlights
    eIDs = find(G.Edges.Type=='overhead_line');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0 0 0],'LineStyle','-','LineWidth',1.5,'ArrowSize',0);
    hL(1) = plot(x,y,'Color',[0 0 0],'LineStyle','-','LineWidth',2,'DisplayName','Overhead Line');

    eIDs = find(G.Edges.Type=='underground_line');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0 0 0],'LineStyle',':','LineWidth',1.5,'ArrowSize',0);
    hL(2) = plot(x,y,'Color',[0 0 0],'LineStyle',':','LineWidth',2,'DisplayName','Underground Line');

    eIDs = find(G.Edges.Type=='triplex_line');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0.4660 0.6740 0.1880],'LineStyle','-.','LineWidth',1.5,'ArrowSize',0);
    hL(3) = plot(x,y,'Color',[0.4660 0.6740 0.1880],'LineStyle','-.','LineWidth',2,'DisplayName','Triplex Line');

    eIDs = find(G.Edges.Type=='');
    highlight(hPlot,G.Edges.EndNodes(eIDs,1),G.Edges.EndNodes(eIDs,2),...
        'EdgeColor',[0 0.4470 0.7410],'LineStyle','-','LineWidth',1.5,'ArrowSize',0);
    hL(4) = plot(x,y,'Color',[0 0.4470 0.7410],'LineStyle','-','LineWidth',2,'DisplayName','Direct Connection');

    % restore plot boundary
    xlim(xlims);
    ylim(ylims);
    % add legend
    hLegend = legend([hS,hL]);
    set(hLegend         , ...
        'numColumns'    , 2     );
    % label selected nodes and edges
    nodeLabels = string(G.Nodes.Name);
    nodeLabels(G.Nodes.Type=='node') = '';
    if labelFlag
        % only label if flag set
        set(hPlot, ...
            'NodeLabel'     , nodeLabels      , ...
            'EdgeLabel'     , G.Edges.Name      );
    end
    % general plot style
    set(gca         , ...
        'box'       , 'on'     , ...
        'XTick'     , []        , ...
        'YTick'     , []        );
    hTitle = title(modelName);






end