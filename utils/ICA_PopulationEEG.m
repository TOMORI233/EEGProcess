function [comp, ICs] = ICA_PopulationEEG(trialsEEG, fs, windowICA, varargin)
    % Description: perform ICA on data and loop reconstructing data with input ICs until you are satisfied
    % Input:
    %     trialsEEG: nTrial*1 cell array of trial data (nCh*nSample matrix)
    %     fs: raw sample rate for [trialsEEG], in Hz
    %     windowICA: time window for [trialsEEG], in ms
    %     chs2doICA: channel numbers
    %     EEGPos: config struct with fields [locs] and [neighbours]
    % Output:
    %     comp: result of ICA (FieldTrip) without field [trial]
    %     ICs: the input IC number array for data reconstruction

    mIp = inputParser;
    mIp.addRequired("trialsEEG", @iscell);
    mIp.addRequired("fs", @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
    mIp.addRequired("windowICA", @(x) validateattributes(x, {'numeric'}, {'numel', 2, 'increasing'}));
    mIp.addParameter("chs2doICA", [], @(x) validateattributes(x, {'numeric'}, {'integer', 'vector'}));
    mIp.addParameter("EEGPos", [], @isstruct);
    mIp.parse(trialsEEG, fs, windowICA, varargin{:});

    chs2doICA = mIp.Results.chs2doICA;
    EEGPos = mIp.Results.EEGPos;

    if isempty(chs2doICA)
        chs2doICA = 1:size(trialsEEG{1}, 1);
    end

    if isempty(EEGPos)
        EEGPos = EEGPos_Neuracle64;
    end

    %% Impl
    comp = mICA(trialsEEG, windowICA, fs, "chs2doICA", chs2doICA);
    % comp = realignIC(comp, windowICA);

    % IC Wave
    FigIC = plotRawWave(calchMean(comp.trial), calchStd(comp.trial), windowICA, "ICA");
    scaleAxes(FigIC, "y", "symOpts", "max");

    % IC topo
    channels = 1:size(trialsEEG{1}, 1);
    badCHs = channels(~ismember(channels, chs2doICA));
    plotTopoICA_EEG(insertRows(comp.topo, badCHs), EEGPos.locs);
    
    % Origin raw wave
    temp = interpolateBadChs(trialsEEG, badCHs, EEGPos.neighbours);
    FigWave(1) = plotRawWaveEEG(calchMean(temp), calchStd(temp), windowICA, "origin", EEGPos);
    scaleAxes(FigWave(1), "y", "symOpts", "max");
    
    % Remove bad channels in trialsEEG
    trialsEEG = cellfun(@(x) x(chs2doICA, :), trialsEEG, "UniformOutput", false);

    k = 'N';
    while ~any(strcmpi(k, {'y', ''}))
        try
            close(FigWave(2));
        end

        ICs = input('Input IC number for data reconstruction (empty for all): ');
        if isempty(ICs)
            ICs = 1:length(chs2doICA);
        end
        badICs = input('Input bad IC number: ');
        ICs(ismember(ICs, badICs)) = [];

        temp = reconstructData(trialsEEG, comp, ICs);
        temp = cellfun(@(x) insertRows(x, badCHs), temp, "UniformOutput", false);
        temp = interpolateBadChs(temp, badCHs, EEGPos.neighbours);
        FigWave(2) = plotRawWaveEEG(calchMean(temp), calchStd(temp), windowICA, "reconstruct", EEGPos);
        scaleAxes(FigWave(2), "y", "on", "symOpts", "max");

        k = validateInput('Press Y or Enter to continue or N to reselect ICs: ', @(x) isempty(x) || any(validatestring(x, {'y', 'n', 'N', 'Y', ''})), 's');
    end

    comp = rmfield(comp, ["trial", "time"]);

    return;
end