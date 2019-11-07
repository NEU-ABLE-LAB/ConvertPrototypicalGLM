% wrapper to translate results from parseGLM.m into graphs

addpath([pwd,'\results\'])
load('glmStrData.mat')

tic
for iF = 1:length(feederIDs)
    modelName = feederIDs(iF);
    G = glm2net(modelName,modelData{iF});
    toc
    save([pwd,'\results\',char(modelName),'.mat'],'G','modelName')
end


% ** next check edge direction and clean
