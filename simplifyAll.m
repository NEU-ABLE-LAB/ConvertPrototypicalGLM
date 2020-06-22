%% simplifyAll
% WORK IN PROGRESS


feederIDs = ["GC-12.47-1", "R1-12.47-1", "R1-12.47-2", "R1-12.47-3",...
    "R1-12.47-4", "R1-25.00-1", "R2-12.47-1", "R2-12.47-2", "R2-12.47-3",...
    "R2-25.00-1", "R2-35.00-1", "R3-12.47-1", "R3-12.47-2", "R3-12.47-3",...
    "R4-12.47-1", "R4-12.47-2", "R4-25.00-1", "R5-12.47-1", "R5-12.47-2",...
    "R5-12.47-3", "R5-12.47-4", "R5-12.47-5", "R5-25.00-1", "R5-35.00-1"];

feederIDs = feederIDs(7);

%% Loop through models
for iF = 1:length(feederIDs)
    
    modelName = feederIDs(iF);
    % load model from output
    load([pwd,'\output\',char(modelName),'.mat'])
    
    G_full = G;
    % simplify
    G = simplifyG(G);
    
    % TROUBLESHOOT: verify total load
    disp(['...model ',char(modelName),' simplified...'])
    fprintf('  Total kVA: %7.0f\n',sum(G.Nodes.NominalPower)/3)
    
    % TROUBLESHOOT: plot
    plotSimple(modelName,G,0,iF)
    
end