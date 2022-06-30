function comp = mICA_EEG(EEGDataset, trials, window, fs)
    % Description: Split data by trials onset time and window. Filter and
    %              resample data. Perform ICA on data.
    % Input:
    %     EEGDataset: a struct with fields [data], [fs] and [channels]
    %     trials: n*1 struct array of trial information
    %     window: time window of interest of each trial
    %     fs: sample rate for downsampling, < fs0
    % Output:
    %     comp: result of ICA (FieldTrip)

    narginchk(3, 4);

    if nargin < 4
        fs = 500; % Hz, for downsampling
    end

    %% Preprocessing
    disp("Preprocessing...");
    fs0 = EEGDataset.fs;
    channels = EEGDataset.channels;
    [trialsEEG, ~, ~, sampleinfo] = selectEEG(EEGDataset, trials, window);
    t = linspace(window(1), window(2), size(trialsEEG{1}, 2)) / 1000;

    cfg = [];
    cfg.trials = true(length(trialsEEG), 1);
    data.trial = trialsEEG';
    data.time = repmat({t}, 1, length(trials));
    data.label = cellfun(@(x) num2str(x), num2cell(channels)', 'UniformOutput', false);
    data.fsample = fs0;
    data.trialinfo = ones(length(trials), 1);
    data.sampleinfo = sampleinfo;
    data = ft_selectdata(cfg, data);

    % Filter
    cfg = [];
    cfg.demean = 'no';
    cfg.lpfilter = 'yes';
    cfg.lpfreq = 100;
    cfg.hpfilter = 'yes';
    cfg.hpfreq = 1;
    cfg.hpfiltord = 3;
    cfg.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
    data = ft_preprocessing(cfg, data);

    %% Resampling
    disp("Resampling...");

    if fs < fs0
        cfg = [];
        cfg.resamplefs = fs;
        cfg.trials = (1:length(data.trial))';
        data = ft_resampledata(cfg, data);
    else
        warning("resamplefs should not be greater than fsample. Skip resampling.");
    end

    %% ICA
    disp("Performing ICA...");
    cfg = [];
    cfg.method = 'runica';
    comp = ft_componentanalysis(cfg, data);

    disp("ICA done.");

    save("comp.mat", "comp");
    return;
end
