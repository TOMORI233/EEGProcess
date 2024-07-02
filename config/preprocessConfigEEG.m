function opts = preprocessConfigEEG()
% Default parameters for EEG preprocessing

% EEG pos file
opts.EEGPos = [];

% for trial segmentation
opts.window = [-1000, 3000]; % ms

% for baseline correction
opts.windowBase = [-300, 0]; % ms

% for filter
opts.fhp = 0.5; % Hz
opts.flp = 40; % Hz

% for trial exclusion
opts.tTh = 0.2;
opts.chTh = 20;
opts.absTh = [];
opts.badChs = [];

% for ICA
opts.icaOpt = "on";
opts.ICAPATH = [];
opts.nMaxIcaTrial = 100; % if left empty, use all trials

return;
end