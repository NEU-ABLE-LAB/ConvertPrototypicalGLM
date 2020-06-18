% wrapper to translate results from parseGLM.m into graphs

feederIDs = ["GC-12.47-1", "R1-12.47-1", "R1-12.47-2", "R1-12.47-3",...
    "R1-12.47-4", "R1-25.00-1", "R2-12.47-1", "R2-12.47-2", "R2-12.47-3",...
    "R2-25.00-1", "R2-35.00-1", "R3-12.47-1", "R3-12.47-2", "R3-12.47-3",...
    "R4-12.47-1", "R4-12.47-2", "R4-25.00-1", "R5-12.47-1", "R5-12.47-2",...
    "R5-12.47-3", "R5-12.47-4", "R5-12.47-5", "R5-25.00-1", "R5-35.00-1"];

% convert all feeder .glm files to string arrays (within a cell array)
modelData = parseGLMs(feederIDs);

%addpath([pwd,'\results\'])
%load('glmStrData.mat')

tic
for iF = 1:length(feederIDs)
    modelName = feederIDs(iF);
    modelData = parseGLM(modelName);    % create string array from .glm
    G = glm2net(modelName,modelData);   % convert to digraph
    
    allG{iF} = G;
    toc
    
end


% ** next check edge direction and clean
