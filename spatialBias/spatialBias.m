function spatialBias(params)
	%generate trials
	trials = [];
	for p = 1:3 %cycle through phases
		ts = [];
		%make trials for sparse quadrants
		for q = find(params.richQ ~= [1, 2, 3 , 4])
			ts = [ts; [repmat(q, [params.sparseTrials(p), 1]), repmat([1; 2], [params.sparseTrials(p)/2, 1])]];
		end
		%make trials for rich quadrant
		ts = [ts; [repmat(params.richQ, [params.richTrials(p), 1]), repmat([1; 2], [params.richTrials(p)/2, 1])]];
		%randomize trials
		ts = ts(randperm(size(ts, 1)), :);
		
		%append to the totallity of trials
		trials = [trials; [ts, repmat(p, [size(ts, 1), 1])]];
	end
	%calculate some stuff
	maxTrials = size(trials, 1);

	%make stimuli
	distractors = cell();		
	targets = cell();
	dev = 25;
	padding = 10;
	width = 4;
	holder = ones(100, 100)*100;
	%Make T's
	h = holder;
	h(padding:(padding+width), padding:(100-padding)) = 99;
	h(padding+width:(100-padding), (50-width/2):(50+width/2)) = 99;
	targets{1} = h';
	targets{2} = h(100:-1:1, :)';
	%Make Ls
	h = holder;
	h(padding:(100-padding), padding:(padding+width)) = 99;
	h(50-dev:(50-dev+width), padding+width:(100-padding)) = 99;
	distractors{1} = h';
	distractors{2} = h(100:-1:1, :)';
	distractors{3} = h(:, 100:-1:1)';
	distractors{4} = h(100:-1:1, 100:-1:1)';
	%Convert to RGB
	for t = 1:2
		rgb = zeros(100, 100, 3);
		for c = 1:3
			h = targets{t};
			h(h == 100) = params.stimbg(c);
			h(h == 99) = params.stimcol(c);
			rgb(:, :, c) = h;
		end
		targets{t} = rgb;
	end
	for t = 1:4
		rgb = zeros(100, 100, 3);
		for c = 1:3
			h = distractors{t};
			h(h == 100) = params.stimbg(c);
			h(h == 99) = params.stimcol(c);
			rgb(:, :, c) = h;
		end
		distractors{t} = rgb;
	end	
	
	%initialize screen (Psychtoolbox)
	PsychDefaultSetup(2);
	Screen('Preference', 'SkipSyncTests', 1);
	% Get the screen numbers
	screens = Screen('Screens');
	% Draw to the external screen if avaliable
	screenNumber = max(screens);
	if params.debugmode
		screen_rect = [0, 0, 640, 640]; %Set the screen rect
		display_rect = screen_rect;
	else
		w = Screen('Resolution', screenNumber).width;
		h = Screen('Resolution', screenNumber).height;
		hd = (w-h)/2;
		screen_rect = [0, 0, w, h];
		display_rect = [hd, 0, h+hd, h]
	end

	[window, windowRect] = PsychImaging('OpenWindow', screenNumber, params.screenbg, screen_rect, [], [], [], 16);
	Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
	% Get the size of the on screen window
	xpix = display_rect(3)-display_rect(1);
	ypix = display_rect(4)-display_rect(2);
	
	% Get the centre coordinate of the window
	[xc, yc] = RectCenter(windowRect);
	
	fixRect = [xc, yc, xc, yc] + [-xpix, -xpix, xpix, xpix]*.05;
	
	%Get the grid
	g_steps = 10;
	gridx = display_rect(1):((display_rect(3)-display_rect(1))/g_steps):display_rect(3);
	gridy = display_rect(2):((display_rect(4)-display_rect(2))/g_steps):display_rect(4);
	stimX = gridx(2)-gridx(1)-1;
	stimY = gridy(2)-gridy(1)-1;
	grid = CombVec(gridx(1:(end-1)), gridy((1:end-1)))';
	
	
	gridpos = CombVec(1:10, 1:10)';
	gridpos(:, 3) = 0;
	gridpos(gridpos(:, 1) > 5 & gridpos(:, 2) < 6, 3) = 1; %TR
	gridpos(gridpos(:, 1) > 5 & gridpos(:, 2) > 5, 3) = 2; %BR
	gridpos(gridpos(:, 1) < 6 & gridpos(:, 2) > 5, 3) = 3; %BL
	gridpos(gridpos(:, 1) < 6 & gridpos(:, 2) < 6, 3) = 4; %BL
	
	%save for easy access
	quadpos = cell();
	for q = 1:4
		quadpos{q} = find(gridpos(:, 3) == q)';
	end
	
	
	%Make stimulus textures
	for t = 1:2
		targets{t} = Screen('MakeTexture', window, targets{t});
	end
	for t = 1:4
		distractors{t} = Screen('MakeTexture', window, distractors{t});
	end
	
	%create a filename to save the data
	fname = sprintf('./data/%s_%s_%d-%d.txt', params.name, date(), clock()(4:5)); 
		 jqp
	%Give trials
	expRunning = 1;
	currentTrial = 1;
	expState = 'INITTRIAL';
	while expRunning
		%Check if we need to abort the experiment
		expState = abortCheck(expState);
		switch(expState)
			case 'INITTRIAL';
				%read trial data
				targetQuadrant = trials(currentTrial, 1);
				correctOrientation = trials(currentTrial, 2);
				
				%random position for each grid
				positions = [];
				tpos = 0;
				for q = 1:4
					quadpos{q} = quadpos{q}(randperm(numel(quadpos{q})));
					positions = [positions; grid(quadpos{q}(1:params.qStims), :)];
					%check the target should appear in the quadrant
					if targetQuadrant == q
						tpos = (q-1)*params.qStims + randi(params.qStims);
					end
				end
				ITIstart = tic;
				expState = 'ITI';
			
			case 'ITI'
				if toc(ITIstart) >= params.ITI
					expState = 'SPACEBAR';
					%Request spacebar press
					message = 'Press SPACEBAR to initiate the next trial';
					Screen('FillRect', window, params.stimbg, display_rect);
					DrawFormattedText(window, message, 'center', 'center', [1, 1, 1]);
					Screen('Flip', window);
				end
				
			case 'SPACEBAR'
				if ~isempty(getKeyResponse([32]))
					expState = 'FIXATION';
					%give fixation		
					Screen('FillRect', window, params.stimbg, display_rect);
					Screen('DrawLine', window, [1, 1, 1], fixRect(1), yc, fixRect(3), yc, 4);
					Screen('DrawLine', window, [1, 1, 1], xc, fixRect(2), xc, fixRect(4), 4);
					Screen('Flip', window);
					fixStart = tic;
				end
				
			case 'FIXATION'
				if toc(fixStart) >= params.fix_duration
					expState = 'SEARCH';
					%give search array
					Screen('FillRect', window, params.stimbg, display_rect);
					for s = 1:size(positions, 1)
						stimRect = [positions(s, 1), positions(s, 2), positions(s, 1), positions(s, 2)];
						stimRect = stimRect + [0, 0, stimX, stimY];
						if s == tpos
							Screen('DrawTexture', window, targets{correctOrientation}, [], stimRect);
						else
							Screen('DrawTexture', window, distractors{randi(4)}, [], stimRect);
						end
					end
					Screen('Flip', window);
					Rstart = tic;					
				end
				
			case 'SEARCH'
				key = getKeyResponse(params.optionKeys);
				if ~isempty(key)
					RT = toc(Rstart);
					expState = 'FEEDBACK';
					acc = params.optionKeys(correctOrientation) == key;
					if acc; fStr = 'Correct!'; else; fStr = 'Error!', end;
					Screen('FillRect', window, params.stimbg, display_rect);
					DrawFormattedText(window, fStr, 'center', 'center', [1, 1, 1]);
					DrawFormattedText(window, sprintf('RT: %6.0f', RT*1000), 10, display_rect(4)-20);
					Screen('Flip', window);
					feedStart = tic;
				end
				
			case 'FEEDBACK'
				if toc(feedStart) >= params.feedback_duration
					expState = 'TRIALEND';
				end
		
			case 'TRIALEND'
				%save data
				saveData(fname, [currentTrial,targetQuadrant,acc,RT]);
				if currentTrial == maxTrials
					expRunning = 0;
					expState = 'SESSIONFINISH';
				else
					currentTrial = currentTrial + 1;
					expState = 'INITTRIAL';
				end
				%Clear screen
				Screen('FillRect', window, params.screenbg, windowRect);
				Screen('FillRect', window, params.stimbg, display_rect);
				Screen('Flip', window);
				
			case {'SESSIONFINISH', 'ABORT'}
				%Close the window and textures we opened
				Screen('Closeall');
				expRunning = 0;
		end
	
	end
end

function theKey = getKeyResponse(keys)
	%This function returns a user-generated keystroke contained in keys.
	theKey = [];
	[pressed, ~, key] = KbCheck(); %Psychtoolbox function
	if pressed
		key = find(key);
		if ismember(key, keys)
			theKey = key;
		end
	end
end

function state = abortCheck(state)
	[pressed, ~, key] = KbCheck();
	if pressed
		keys = find(key); %Q and P
		if numel(keys) > 1
			if sum(keys) == 161
				state = 'ABORT';
			end
		end
	end
end

function saveData(fname, data)
	f = fopen(fname, 'a');
	fprintf(f, '%d\t%d\t%d\t%2.4f\n', ... %trial, target q, correct, RT
	data(1), data(2), data(3), data(4));
	fclose(f);
end