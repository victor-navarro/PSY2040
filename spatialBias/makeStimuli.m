function [targets, distractors] = makeStimuli(params)
	
	%make stimuli
	distractors = cell();		
	targets = cell();
	dev = 15;
	padding = 20;
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
	
	%the others are transpose of these distractors
	for t = 1:4
		distractors{4+t} = distractors{t}';
	end
	
	%Convert to RGB (tensor)
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
	for t = 1:8
		rgb = zeros(100, 100, 3);
		for c = 1:3
			h = distractors{t};
			h(h == 100) = params.stimbg(c);
			h(h == 99) = params.stimcol(c);
			rgb(:, :, c) = h;
		end
		distractors{t} = rgb;
	end
	

end