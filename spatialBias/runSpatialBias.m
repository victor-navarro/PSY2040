%This script sets some parameters and runs a categorization task supported by 
clear all
params = struct;
params.name = 'test_subject'; %name of the subject (filename)
params.nTrials = [12, 48, 12]; %number of trials per phase
params.richTrials = params.nTrials./[2, 8, 2];
params.sparseTrials = (params.nTrials-params.richTrials)/3;
params.screenbg = [.5, .5, .5]; %if the display is not a square, the color of the vertical bands to the sides
params.stimbg = [0, 0, 0]; %Background of the stimulus space
params.stimcol = [1, 1, 1]; %Background of the stimuli
params.richQ = 1; %1 = TR, 2 = BR, 3 = BL, 4 = TL
params.ITI = 1; %Inter-trial interval
params.optionKeys = [70, 74]; %Available keys (F and J)
params.fix_duration = 1; %Duration of the fixation cross
params.feedback_duration = 1; %Duration of the feedback message
params.qStims = 3; %Stimuli to be drawn on each quadrant
params.debugmode = 0; %Fullscreen or not

spatialBias(params); %Run the experiment