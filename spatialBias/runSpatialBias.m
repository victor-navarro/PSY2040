%This script sets some parameters and runs a categorization task supported by 
clear all
params = struct;
params.name = ''; %name of the subject (filename)
params.nTrials = [36, 100, 36]; %All these numbers should be even in order to balance the orientation of the target
params.richTrials = [18, 10, 18];
params.sparseTrials = [6, 30, 6];
params.nBlocks = [3, 3, 3]; 
params.screenbg = [.5, .5, .5]; %if the display is not a square, the color of the vertical bands to the sides
params.stimbg = [0, 0, 0]; %Background of the stimulus space
params.stimcol = [1, 1, 1]; %Background of the stimuli
params.richQ = randi(4); %1 = TR, 2 = BR, 3 = BL, 4 = TL
params.ITI = 0; %Inter-trial interval
params.optionKeys = [70, 74]; %Available response keys (F and J)
params.fix_duration = 1; %Duration of the fixation cross
params.feedback_duration = 1; %Duration of the feedback message
params.qStims = 3; %Stimuli to be drawn on each quadrant
params.debugmode = 0; %Fullscreen or not

spatialBias(params); %Run the experiment
