%This script sets some parameters and runs a categorization task supported by 
clear all
params = struct;
params.name = 'test_subject';
params.nTrials = [12, 48, 12];
params.richTrials = params.nTrials./[2, 8, 2];
params.sparseTrials = (params.nTrials-params.richTrials)/3;
params.screenbg = [.5, .5, .5];
params.stimbg = [0, 0, 0];
params.stimcol = [1, 1, 1];
params.richQ = 1; %1 = TR, 2 = BR, 3 = BL, 4 = TL
params.ITI = 1;
params.optionKeys = [70, 74];
params.fix_duration = 1;
params.feedback_duration = 1;
params.qStims = 3;
params.debugmode = 0;

spatialBias(params);