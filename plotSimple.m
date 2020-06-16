% plot simplified graph

%% LOAD
modelName = 'R1-12.47-3';
addpath([pwd,'\output\'])
% test case
load([modelName,'.mat'])


G.Edges.Weight = G.Edges.Length;

figure(10)
clf

hPlot = plot(G);
%hPlot = plot(G,'Layout','layered');
%hPlot = plot(G,'Layout','layered',...
%    'Direction','right','AssignLayers','asap');
%hPlot = plot(G,'Layout','force', ...
%    'WeightEffect','direct','Iterations',2,'UseGravity','on', ...
%    'XStart',hPlot.XData,'YStart',hPlot.YData);
%hPlot = plot(G,'Layout','force', ...
%    'WeightEffect','direct','Iterations',10,'UseGravity','off');

% set line colors


for iN = 1:height(G.Nodes)
   switch lower(G.Nodes.Type(iN))
       case 'load'
           highlight(hPlot,iN,...
               'NodeColor',[1 0 0],'Marker','square','MarkerSize',8);
       case 'node'
           highlight(hPlot,iN,...
               'NodeColor',[0 0 0],'Marker','o','MarkerSize',4);
       case 'transformer'
           highlight(hPlot,iN,...
               'NodeColor',[0.6350 0.0780 0.1840],'Marker','^','MarkerSize',4);
       case 'fuse'
           
       case 'switch'
           
       case 'capacitor'
           
       case 'triplex_node'

       case 'regulator'
           
       case 'source'
           highlight(hPlot,iN,...
               'NodeColor',[0.9290 0.6940 0.1250],'Marker','square','MarkerSize',10);
       otherwise
           warning('Node type missing from switch statement');
   end
end

for iE = 1:height(G.Edges)
    switch lower(G.Edges.Type(iE))
        case 'overhead_line'
            highlight(hPlot,G.Edges.EndNodes{iE,1},G.Edges.EndNodes{iE,2},...
               'EdgeColor',[0 0 0],'LineStyle','-','LineWidth',2);
        case 'underground_line'
            highlight(hPlot,G.Edges.EndNodes{iE,1},G.Edges.EndNodes{iE,2},...
               'EdgeColor',[0 0 0],'LineStyle',':','LineWidth',2);
        case 'triplex_line'
            
        case ''
            highlight(hPlot,G.Edges.EndNodes{iE,1},G.Edges.EndNodes{iE,2},...
               'EdgeColor',[0.2 0.2 0.2],'LineStyle','-','LineWidth',1);
        otherwise
            warning('Edge type missing from switch statement');
    end
end            
   
set(hPlot, ...
    'NodeLabel'     , G.Nodes.Name      , ...
    'EdgeLabel'     , G.Edges.Name      );

%plot(G,'Layout','layered','NodeLabel',G.Nodes.Name,'EdgeLabel',G.Edges.Name);