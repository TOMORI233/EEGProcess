function opts = preprocessConfigEEG(varargin)
% Default parameters for EEG preprocessing.
% You can change parameters with input name-value pairs.
% Copy this file to 'config\local' folder as your local config file.

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
opts.nMaxIcaTrial = 100; % If left empty, use all trials
opts.sameICAOpt = "off"; % If set "on", apply the ICA result of one 
                         % protocol to the others for one subject

% parse name-value pairs
for index = 1:2:nargin
    opts.(varargin{index}) = varargin{index + 1};
end

return;
end