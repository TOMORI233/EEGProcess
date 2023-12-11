function [comp, ICs, FigTopoICA, FigWave, FigIC] = ICA_PopulationEEG(trialsEEG, fs, windowICA, chs2doICA)
    % Description: perform ICA on data and loop reconstructing data with input ICs until you are satisfied
    % Input:
    %     trialsEEG: nTrial*1 cell array of trial data (nCh*nSample matrix)
    %     fs: raw sample rate for [trialsEEG], in Hz
    %     windowICA: time window for [trialsEEG], in ms
    % Output:
    %     comp: result of ICA (FieldTrip) without field [trial]
    %     ICs: the input IC number array for data reconstruction
    %     FigTopoICA: figure of topo of all ICs
    %     FigWave: (1) is raw wave. (2) is reconstructed wave.
    %     FigIC: IC wave

    narginchk(3, 4);

    if nargin < 4
        chs2doICA = 1:size(trialsEEG{1}, 1);
    end

    comp0 = mICA(trialsEEG, windowICA, fs, "chs2doICA", chs2doICA);
    comp = realignIC(comp0, windowICA);

    EEGPos = EEGPosConfigNeuracle;
    LOCPATH = 'Neuracle_chan64.loc';

    % IC Wave
    ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
    ICStd = cell2mat(cellfun(@(x) std(x, [], 1), changeCellRowNum(comp.trial), "UniformOutput", false));
    FigIC = plotRawWave(ICMean, ICStd, windowICA, "ICA");
    scaleAxes(FigIC, "y", "symOpts", "max");

    % IC topo
    channels = 1:size(trialsEEG{1}, 1);
    badCHs = channels(~ismember(channels, chs2doICA));
    FigTopoICA = plotTopoEEG(insertRows(comp.topo, badCHs), LOCPATH);
    
    % Origin raw wave
    temp = changeCellRowNum(interpolateBadChs(trialsEEG, badCHs));
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
    FigWave(1) = plotRawWaveEEG(chMean, chStd, windowICA, "origin", EEGPos);
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
        temp = interpolateBadChs(temp, badCHs);
        chMean = cell2mat(cellfun(@mean, changeCellRowNum(temp), "UniformOutput", false));
        chStd = cell2mat(cellfun(@std, changeCellRowNum(temp), "UniformOutput", false));
        FigWave(2) = plotRawWaveEEG(chMean, chStd, windowICA, "reconstruct", EEGPos);
        scaleAxes(FigWave(2), "y", "on", "symOpts", "max");

        k = validateInput('Press Y or Enter to continue or N to reselect ICs: ', @(x) isempty(x) || any(validatestring(x, {'y', 'n', 'N', 'Y', ''})), 's');
    end

    comp.trial = [];

    return;
end