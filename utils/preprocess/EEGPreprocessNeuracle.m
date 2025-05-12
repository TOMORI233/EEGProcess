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
    warning("No MAT data found in your directory.");
    disp('Proceed without MAT data.');
else
    load(fullfile(temp.folder, temp.name), "rules", "trialsData");
    if ~exist("rules", "var") || ~exist("trialsData", "var")
        error("MAT data not matched. Related MAT data is missing.");
    end
end

%% Preprocess
codes = arrayfun(@(x) str2double(x.type), EEG.event); % marker
latency = [EEG.event.latency]'; % unit: sample
fs = EEG.srate; % Hz
if exist("trialsData", "var")
    trialAll = generalProcessFcn(trialsData, rules);
end

% exclude accidental codes
if exist("rules", "var")
    exIdx = isnan(codes) | ~ismember(codes, rules.code) | latency > size(EEG.data, 2) - fix(window(2) / 1000 * fs);
    latency(exIdx) = [];
end
latency = latency(find(arrayfun(@(x) str2double(x.type), EEG.event) == 1, 1):end);

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

        % Re-reference
        if strcmpi(opts.reref, "CAR")
            trialsEEG = cellfun(@(x) x - mean(x(channels, :), 1), trialsEEG, "UniformOutput", false);
        end

    else
        disp('ICA result does not exist. Performing ICA on data...');
        channels = 1:size(trialsEEG{1}, 1);
        plotRawWave(calchMean(trialsEEG), calchStd(trialsEEG), window);
        scaleAxes("y", [-20,20], "symOpts", "max");
        bc = validateInput(['Input extra bad channels (besides ', num2str(badChs(:)'), '): '], @(x) isempty(x) || all(fix(x) == x & x > 0));
        badChs = [badChs(:); bc(:)]';

        % first trial exclusion
        tIdx = excludeTrials(trialsEEG, 0.4, 20, "userDefineOpt", "off", "badCHs", badChs);
        trialsEEG(tIdx) = [];
        latency(tIdx) = [];

        if exist("trialAll", "var")
            trialAll(tIdx) = [];
        end

        if ~isempty(badChs)
            disp(['Channel ', num2str(badChs(:)'), ' are excluded from analysis.']);
            channels(badChs) = [];
        end

        % Re-reference
        if strcmpi(opts.reref, "CAR")
            trialsEEG = cellfun(@(x) x - mean(x(channels, :), 1), trialsEEG, "UniformOutput", false);
        end
        
        if isempty(nMaxIcaTrial)
            idx = 1:length(trialsEEG);
        else
            idx = 1:min(length(trialsEEG), nMaxIcaTrial);
        end
        
        [comp, ICs] = ICA_PopulationEEG(trialsEEG(idx), fs, window, "chs2doICA", channels, "EEGPos", EEGPos);
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
latency(exIdx) = [];

if exist("trialAll", "var")
    trialAll(exIdx) = [];
else
    trialAll = struct("trialNum", num2cell((1:length(trialsEEG))'));
end

% convert latency to time, unit: sec
latency = latency / fs;
trialAll = addfield(trialAll, "latency", latency);

return;
end