function [trialsEEG, trialAll, fs, varargout] = EEGPreprocessNeuracle(ROOTPATH, opts)
narginchk(1, 2);

if nargin < 2
    opts = [];
end

%% Parameter settings
opts = getOrFull(opts, preprocessConfigEEG);
window = opts.window; % variable name conflicts with built-in function
parseStruct(opts);

%% Data loading
% convert ROOTPATH to char
ROOTPATH = char(ROOTPATH);
if ~strcmp(ROOTPATH(end), '\')
    ROOTPATH = [ROOTPATH, '\'];
end

% read from BDF data
EEG = readbdfdata({'data.bdf', 'evt.bdf'}, ROOTPATH);
if exist(fullfile(ROOTPATH, 'data.1.bdf'), 'file')
    EEG1 = readbdfdata({'data.1.bdf'}, ROOTPATH);
    EEG.data = [EEG.data, EEG1.data];
end

% load MAT data
temp = dir(fullfile(ROOTPATH, '*.mat'));
if numel(temp) > 1
    error("More than 1 MAT data found in your directory.");
elseif isempty(temp)
    error("No MAT data found in your directory.");
end
load(fullfile(temp.folder, temp.name), "rules", "trialsData");
if ~exist("rules", "var") || ~exist("trialsData", "var")
    error("Related MAT data is missing.");
end

%% Preprocess
codes = arrayfun(@(x) str2double(x.type), EEG.event); % marker
latency = [EEG.event.latency]'; % unit: sample
fs = EEG.srate; % Hz
controlIdx = find(rules.ICI1 == rules.ICI2);
trialAll = generalProcessFcn(trialsData, rules, controlIdx);

% exclude accidental codes
exIdx = isnan(codes) | ~ismember(codes, rules.code) | latency > size(EEG.data, 2) - fix(window(2) / 1000 * fs);
latency(exIdx) = [];

% filter
EEG.data = ECOGFilter(EEG.data, fhp, flp, fs, "Notch", "on");

% epoching
trialsEEG = arrayfun(@(x) EEG.data(:, x + fix(window(1) / 1000 * fs):x + fix(window(2) / 1000 * fs)), latency, "UniformOutput", false);

% ICA
if strcmpi(icaOpt, "on") && nargout >= 4
    if ~isempty(ICAPATH) && exist(fullfile(ICAPATH, "ICA res.mat"), "file")
        load(fullfile(ICAPATH, "ICA res.mat"), "-mat", "comp");
        channels = comp.channels;
        ICs = comp.ICs;
        badChs = comp.badChs;
    else
        disp('ICA result does not exist. Performing ICA on data...');
        channels = 1:size(trialsEEG{1}, 1);
        plotRawWave(calchMean(trialsEEG), calchStd(trialsEEG), window);
        bc = validateInput(['Input extra bad channels (besides ', num2str(badChs(:)'), '): '], @(x) isempty(x) || all(fix(x) == x & x > 0));
        badChs = [badChs(:); bc(:)]';

        % first trial exclusion
        tIdx = excludeTrials(trialsEEG, 0.4, 20, "userDefineOpt", "off", "badCHs", badChs);
        trialsEEG(tIdx) = [];
        trialAll(tIdx) = [];

        if ~isempty(badChs)
            disp(['Channel ', num2str(badChs(:)'), ' are excluded from analysis.']);
            channels(badChs) = [];
        end
        
        [comp, ICs] = ICA_PopulationEEG(trialsEEG, fs, window, "chs2doICA", channels, "EEGPos", EEGPos);
    end
    
    % reconstruct data
    trialsEEG = cellfun(@(x) x(channels, :), trialsEEG, "UniformOutput", false);
    trialsEEG = reconstructData(trialsEEG, comp, ICs);
    trialsEEG = cellfun(@(x) insertRows(x, badChs), trialsEEG, "UniformOutput", false);
    trialsEEG = interpolateBadChs(trialsEEG, badChs, EEGPos.neighbours);

    comp.channels = channels;
    comp.ICs = ICs;
    comp.badChs = badChs;

    varargout{1} = comp;
end

% baseline correction
trialsEEG = baselineCorrection(trialsEEG, fs, window, windowBase);

% exclude bad trials
params = {trialsEEG, tTh, chTh};
if ~isempty(absTh)
    params = [params, {"absTh", absTh}];
end
if ~isempty(badChs)
    params = [params, {"badCHs", badChs}];
end
exIdx = excludeTrials(params{:});
trialsEEG(exIdx) = [];
trialAll(exIdx) = [];

return;
end