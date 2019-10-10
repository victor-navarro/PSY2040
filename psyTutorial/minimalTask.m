%This task is a minimal example of a categorization task
%First, set some parameters
ITI = 0.5; %Intertrial interval (in seconds)
feedback_duration = 1; %Feedback duration (in seconds)
ntrials = 10; %Number of trials
dvalues = 10; %number of values for each dimension
colors = linspace([1, 0, 0], [0, 0, 1], dvalues)'; %color dimension goes from red to blue
sizes = linspace(25, 50, dvalues); %size dimension goes from 25 to 50 pixels (radius)
keys = [70, 74]; %keyboard codes for response keys (F or J);

%generate stimuli
as = [randi([1, dvalues/2], ntrials/2, 1), randi(dvalues, ntrials/2, 1), ones(ntrials/2, 1)*keys(1)]; %first value is color index, second value is size index, third is correct key (F or J, 70 or 74)
bs = [randi([dvalues/2+1, dvalues], ntrials/2, 1), randi(dvalues, ntrials/2, 1), ones(ntrials/2, 1)*keys(2)];
%combine
trials = [as; bs];
%randomize
trials = trials(randperm(ntrials), :);

%initialize screen (Psychtoolbox)
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
% Get the screen numbers
screens = Screen('Screens');
% Draw to the external screen if avaliable
screenNumber = max(screens);
screen_rect = [0, 0, 640, 360]; %Set the screen rect
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0, 0, 0], screen_rect, [], [], [], 16);
% Get the size of the on screen window
[xpix, ypix] = Screen('WindowSize', window);
% Get the centre coordinate of the window
[xc, yc] = RectCenter(windowRect);

%give trials
for t = 1:ntrials
	%Give ITI
	WaitSecs(ITI);
	%Present stimulus
	theColor = colors(trials(t, 1), :);
	theSize = sizes(trials(t, 2));
	%Calculate the stimulus coordinates [fromX, fromY, toX, toY]
	stimRect = [xc, yc, xc, yc] + [-theSize, -theSize, theSize, theSize];
	%show stimulus
	Screen('FillRect', window, [0, 0, 0], windowRect); %Fill the screen with black [0, 0, 0]
	Screen('FillOval', window, theColor, stimRect); %Draw the circle
	Screen('Flip', window); %Sweep the screen with the things we drew
	
	%get response
	correct_key = trials(t, 3);
	valid = 0; %For while loop
	while ~valid
		[~, pressed] = KbWait(); %Get a user-generated keystroke
		pressed = find(pressed); %convert it to keyboard code
		if ismember(pressed, keys) %Check if the pressed key is a response key
			valid = 1; %If it is, get out of the while loop, otherwise loop again
		end
	end
	
	%give feedback
	accuracy = pressed == correct_key; %is the pressed key the correct key?
	if accuracy; fString = 'Correct!'; else fString = 'Error!'; end %get the feedback message, based on accuracy
	Screen('FillRect', window, [0, 0, 0], windowRect);
	DrawFormattedText(window, fString, 'center', 'center', [1, 1, 1]); %Draw message in white, centered in the screen
	Screen('Flip', window);
	WaitSecs(feedback_duration); %Hold the message on the screen, before clearning the screen for the next trial
	Screen('FillRect', window, [0, 0, 0], windowRect); %clear the screen
	Screen('Flip', window);
end

%Close the window we opened
Screen('Close', window);