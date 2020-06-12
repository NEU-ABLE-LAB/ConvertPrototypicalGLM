% check raw output graphs from glm2net


feederIDs = [...
    "GC-12.47-1",...
    "R1-12.47-1",...
    "R1-12.47-2",...
    "R1-12.47-3",...
    "R1-12.47-4",...
    "R1-25.00-1",...
    "R2-12.47-1",...
    "R2-12.47-2",...
    "R2-12.47-3",...
    "R2-25.00-1",...
    "R2-35.00-1",...
    "R3-12.47-1",...
    "R3-12.47-2",...
    "R3-12.47-3",...
    "R4-12.47-1",...
    "R4-12.47-2",...
    "R4-25.00-1",...
    "R5-12.47-1",...
    "R5-12.47-2",...
    "R5-12.47-3",...
    "R5-12.47-4",...
    "R5-12.47-5",...
    "R5-25.00-1",...
    "R5-35.00-1",...
    ];

for iFeeder = 1:numel(feederIDs)
    feederID = feederIDs(iFeeder);
    % load raw graph
    load([char(feederID),'.mat'])

    disp(feederID)
    disp(['Total nodes: ',num2str(numnodes(G))]);
    disp(['Connected components: ',num2str(max(conncomp(G,'Type','weak')))]);
    disp(' ')
    
    
end