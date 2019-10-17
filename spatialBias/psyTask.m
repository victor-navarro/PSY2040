%PsyTask is the main function
%THe other functions at the end of this file are called from the main function.
function psyTask(params)
	%This function controls the experimental loop
	%TO DO:
	%	-Add function to save data
	%	-Add more support for diffeent stimulus types (drawStim)
	%parse the params argument
	if ~exist('params', 'var')
		params = struct;
	end
	if ~isfield(params, 'task')
		params.task = 'RB-Categorization';
	end
    if ~isfield(params, 'ITI')
		params.ITI = 1;
    end
	if ~isfield(params, 'stimtype')
		params.stimtype = 'line';
    end
	if ~isfield(params, 'feedback_duration')
		params.feedback_duration = 1;
    end
	if ~isfield(params, 'nTrials')
		params.nTrials = 2;
	end
	if ~isfield(params, 'fix_duration')
		params.fix_duration = 1;
	end
	
    %Before we begin the experimental loop, we will define any variables we might need.
    %Make stimuli based on task
    stims = makeStimuli(params);
	
	
	    %Get keyboard keycodes based on task
    [params.keycodes, params.keys] = getKeys(params.task);
    %Get trials
    trials = makeTrials(params.task, stims, params.keycodes);
	
	%Initialize screen
	screen_rect = [0, 0, 640, 360];
	screeninfo = initScreen(params.task, screen_rect);
	
	%Pre-generate stimuli based on stimtype
	params.genStim = genStimuli(params)
	
	
	
	%Initialize some variables
	params.allAccs = [];
	
	%Go through trials
	expRunning = 1;
	t = 1;
	while expRunning
		params.currentTrial = t;
		switch(params.task)
			case {'RB-Categorization', 'II-Categorization'}
				%Give the trial
				params = twoAFC(trials(t, 1:2), trials(t, 4), params, screeninfo); %note the params assignment. Given the scope of params, we need to rewrite it trial after trial. Ugly fix.
			case {'SpatialBias'}
				%Give the trial
				params = visualSearch(trials(t, 1), trials(t, 2), params, screeninfo);
		end
		if t == params.nTrials
			expRunning = 0;
		else
			expRunning = ~abortCheck()
			t = t+1;
		end
	end
	
	%After the experiment is finished, close the window
	Screen('Close', screeninfo.window)
end

function check = abortCheck();
	check = 0;
	[pressed, ~, key] = KbCheck();
	if pressed
		keys = find(key); %Q and P
		if numel(keys) > 1
			check = keys(1) == 80 && keys(2) == 81;
		end
	end
end

function drawStim(stim, params, screeninfo);
	%This function takes stimulus coordinates (stim) and draws a certain kind of stimulus (params.stimtype)
	switch(params.stimtype)
		case 'line'
			length = rescaleValues(stim(1), [-1, 1], [.5, 1]);
			orientation = rescaleValues(stim(2), [-1, 1], [-.25, .25]);
			%create rotation matrix
			a = orientation*pi; %set rotation (in radians)
			rmat = [cos(a), -sin(a); sin(a), cos(a)]; %create rotation matrix
			%create line in unit space
			line = [0, -1; 0, 1]*rmat;
			line = reshape(line', [1, 4])*length;
			%rescale to screen space
			line([1, 3]) = rescaleValues(line([1, 3]), [-1, 1], screeninfo.stimRect([1, 3]));
			line([2, 4]) = rescaleValues(line([2, 4]), [-1, 1], screeninfo.stimRect([2, 4]));
			%draw background
			Screen('FillRect', screeninfo.window, [1, 1, 1], screeninfo.stimRect + [-5, -5, 5, 5]); %Psychtoolbox function
			%draw line
			Screen('DrawLine', screeninfo.window, [0, 0, 0], line(1), line(2), line(3), line(4), 3); %Psychtoolbox function
	end
end


function updateScreen(screentype, stim, params, screeninfo)
	%This function updates the screen, depending on screentype. It uses the information in stim to draw the requested stimulus (c.f. 2AFC and TextFeedback)
	switch(screentype)
		case {'Erase'}
			Screen('FillRect', screeninfo.window, [0, 0, 0], screeninfo.windowRect);
		case {'2AFC'}
			drawStim(stim, params, screeninfo);
		case {'VisualArray'}
			drawBiasSearch(stim, params, screeninfo);		
		case {'CenteredText'}
			DrawFormattedText(screeninfo.window, stim, 'center', 'center', [1, 1, 1]);
		case {'Fixation'}
			Screen('DrawLine', screeninfo.window, [1, 1, 1], screeninfo.fixRect(1), screeninfo.windowCenter(2), screeninfo.fixRect(3), screeninfo.windowCenter(2), 4);
			Screen('DrawLine', screeninfo.window, [1, 1, 1], screeninfo.windowCenter(1), screeninfo.fixRect(2), screeninfo.windowCenter(1), screeninfo.fixRect(4), 4);
			
	end
	drawParams(params, screeninfo);
	Screen('Flip', screeninfo.window); %Flip the screen (i.e. show the things we drew)
 end
 
 function drawParams(params, screeninfo)
	%This function is called within the updateScreen function. Draws useful information.
	BR = [sprintf('Trial %d/%d', params.currentTrial, params.nTrials)];
	TR = [sprintf('Accuracy: %3.0f%%', mean(params.allAccs)*100)];
	DrawFormattedText(screeninfo.window, BR, screeninfo.windowRect(3)-180, screeninfo.windowRect(4)-20, [1, 1, 1]); %Psychtoolbox function
	DrawFormattedText(screeninfo.window, TR, screeninfo.windowRect(3)-200, screeninfo.windowRect(2)+40, [1, 1, 1]);
 end
 
function trials = makeTrials(task, stims, keycodes)
	%This function makes and randomizes trials depending on the task, stims, and keycodes.
	switch(task)
		case {'RB-Categorization', 'II-Categorization'}
			cats = [0, 1]; %these are the target categories
			keycodes = keycodes(randperm(2));
			for c = 1:2
				stims(stims(:, 3) == cats(c), 4) = keycodes(c);
			end
	end
	%randomize trials
	trials = stims(randperm(size(stims, 1)), :);
end
	

function [kcodes, keys] = getKeys(task)
	%This function returns the keycodes and keynames available in a task.
	switch(task)
		case {'RB-Categorization', 'II-Categorization', 'SpatialBias'}
			keys = ['F', 'J'];
	end
	kcodes = [];
	for k = 1:numel(keys)
		kcodes = [kcodes, KbName(keys(k))];
	end
end

function stims = makeStimuli(params)
	%This function creates stimuli for a given task, and samples stimuli based on ntrials
	nstims = 1000; %set stimuli to initially generate
	stims = []; %initialize an empty array for stimuli
	switch(params.task)
		case 'RB-Categorization'
			stims = -1 + (1-(-1)).*rand(nstims, 2); %generate stimuli in unit space
			stims(:, 3) = stims(:, 1) < 0; %assign category membership
			as = stims(stims(:, 3) == 0, :); %get stimuli belonging to category A
			bs = stims(stims(:, 3) == 1, :); %get stimuli belonging to category B
			%sample stimuli from each category
			stims = [as(randi(size(as, 1), [1, params.nTrials/2]), :); bs(randi(size(bs, 1), [1, params.nTrials/2]), :)];
		case 'II-Categorization'
			%This task is the same as the RB categorization, just rotated 45 degrees
			stims = -1 + (1-(-1)).*rand(nstims, 2); 
			stims(:, 3) = stims(:, 1) < 0; %assign category membership
			a = .25*pi; %set rotation (in radians)
			rmat = [cos(a), -sin(a); sin(a), cos(a)]; %create rotation matrix
			stims(:, 1:2) = stims(:, 1:2)*rmat; %rotate the stimuli
			as = stims(stims(:, 3) == 1, :); %get stimuli belonging to category A
			bs = stims(stims(:, 3) == 0, :); %get stimuli belonging to category B
			%sample stimuli from each category
			stims = [as(randi(size(as, 1), [1, params.nTrials/2]), :); bs(randi(size(bs, 1), [1, params.nTrials/2]), :)];
		case 'SpatialBias'
			%sparse quadrants
			for q = find(params.richQ ~= [1, 2, 3 , 4])
				stims = [stims; [repmat(q, [params.nTrials/6, 1]), repmat([1; 2], [params.nTrials/12, 1])]];
			end
			stims = [stims; [repmat(params.richQ, [params.nTrials/2, 1]), repmat([1; 2], [params.nTrials/4, 1])]];
	end
end

function data = rescaleValues(data, d, s)
	%Simple rescaling function to rescale data. d and s are vectors containing the min and max of the data (d) and the desired scale (s)
    data = s(1) + ((data-d(1))*(s(2)-s(1))/(d(2) - d(1)));
end



function params = twoAFC(stim, correct, params, screeninfo)
	%This function contains the structure of a 2AFC trial. Called within the main function
	%ITI period
	WaitSecs(params.ITI); %Psychtoolbox function
	%Present stimulus
	updateScreen('2AFC', stim, params, screeninfo);
	%Get response
	key = getKeyResponse(params.keycodes);
	%Give feedback
	acc = correct == key;
	params.allAccs = [params.allAccs, acc];
	if acc; fText = 'Correct!'; else; fText = 'Error!'; end;
	updateScreen('CenteredText', fText, params, screeninfo);
	WaitSecs(params.feedback_duration);
	%Erase screen for next trial
	updateScreen('Erase', stim, params, screeninfo);
end


function params = visualSearch(stim, correct, params, screeninfo)
	%This function contains the structure of a visual search trial.
	%ITI Period (self-paced)
	updateScreen('CenteredText', 'Press SPACEBAR to initiate the next trial', params, screeninfo);
	getKeyResponse([32]);
	%Give fixation
	updateScreen('Fixation', [], params, screeninfo);
	WaitSecs(params.fix_duration);
	%Give search array
	updateScreen('VisualArray', stim, params, screeninfo)
end
		
function key = getKeyResponse(keys)
	%This function returns a user-generated keystroke contained in keys.
	valid = 0;
	while ~valid
		[~, key] = KbWait(); %Psychtoolbox function
		key = find(key);
		if ismember(key, keys)
			valid = 1;
		end
	end
end

function stims = genStimuli(params, screeninfo)
	stims = cell();
	switch(params.stimtype)
		case('TL')
			dev = 25;
			padding = 10;
			width = 4;
			holder = zeros(100, 100);
			%cat(3, rep(params.stimbg(1), [100, 100]), rep(params.stimbg(2), [100, 100]), rep(params.stimbg(3), [100, 100]));
			h = holder;
			h(padding:(padding+width), padding:(100-padding)) = 1;
			h(padding+width:(100-padding), (50-width/2):(50+width/2)) = 1;
			
			%Make T's
			stims{1} = h';
			stims{2} = h(100:-1:1, :)';
			
			%Make Ls
			h = holder;
			h(padding:(100-padding), padding:(padding+width)) = 1;
			h(50-dev:(50-dev+width), padding+width:(100-padding)) = 1;
			stims{3} = h';
			stims{4} = h(100:-1:1, :)';
			stims{5} = h(:, 100:-1:1)';
			stims{6} = h(100:-1:1, 100:-1:1)';
		
			%now make them as textures, for psychtoolbox
			for s = 1:6
				stims{s} = Screen('MakeTexture', screeninfo.window, stims{s});
			end
	end
end
		
   

function screeninfo = initScreen(task, screen_rect);
	%This function initializes the screen. If specific areas need to be drawn, those are added as a function of task.
	screeninfo = struct;
	%initialize screen (Psychtoolbox)
	PsychDefaultSetup(2);
	Screen('Preference', 'SkipSyncTests', 1);
	
	% Get the screen numbers
	screens = Screen('Screens');
    % Draw to the external screen if avaliable
    screenNumber = max(screens);
	[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0, 0, 0], screen_rect, [], [], [], 16);
	Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
	% Get the size of the on screen window
    [xpix, ypix] = Screen('WindowSize', window);
	% Get the centre coordinate of the window
    [xc, yc] = RectCenter(windowRect);
	
	
	%put necessary information into screeninfo
	screeninfo.window = window;
	screeninfo.windowRect = windowRect;
	screeninfo.fixRect = [xc, yc, xc, yc] + [-xpix, -xpix, xpix, xpix]*.05;
	screeninfo.windowCenter = [xc, yc];
	
	%put task-specific information
	switch(task)
		case {'RB-Categorization', 'II-Categorization'}
			screeninfo.stimRect = [xc, yc, xc, yc] + ([-ypix/2, -ypix/2, ypix/2, ypix/2].*.5);
		case {'SpatialBias'}
			ymult = .1;
			screeninfo.stimDims = [0, 0, floor(ypix*ymult), floor(ypix*ymult)];
	end
end
	