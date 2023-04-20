function passive3ProcessFcn(trialAll, trialsEEG, window, fs, params)
    close all;
    parseStruct(params);
    mkdir(fullfile(FIGPATH, "Figs"));

    %% REG
    idx = [trialAll.type] == "REG";
    trials = trialAll(idx);
    trialsEEG_temp = trialsEEG(idx);
    ICIs = unique([trials.ICI])';

    for index = 1:length(ICIs)
        temp = trialsEEG_temp([trials.ICI] == ICIs(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            plotRawWaveEEG(chMean, [], window, 1000, ['REG ', num2str(ICIs(index))]);
            scaleAxes("x", [0, 2000]);
            scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
            mPrint(gcf, fullfile(FIGPATH, "Figs", strcat("Passive3 REG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
        end

    end

    %% IRREG
    idx = [trialAll.type] == "IRREG";
    trials = trialAll(idx);
    trialsEEG_temp = trialsEEG(idx);
    ICIs = unique([trials.ICI])';

    for index = 1:length(ICIs)
        temp = trialsEEG_temp([trials.ICI] == ICIs(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            plotRawWaveEEG(chMean, [], window, 1000, ['IRREG ', num2str(ICIs(index))]);
            scaleAxes("x", [0, 2000]);
            scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
            mPrint(gcf, fullfile(FIGPATH, "Figs", strcat("Passive3 IRREG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
        end

    end

    %% Find channels with significant auditory reaction
    % Use RMS
    windowOnset = [0, 300]; % auditory window, ms
    tBaseIdx = fix((windowBase(1) - window(1)) * fs / 1000) + 1:fix((windowBase(2) - window(1)) * fs / 1000);
    tIdx = fix((windowOnset(1) - window(1)) * fs / 1000) + 1:fix((windowOnset(2) - window(1)) * fs / 1000);
    rmsBase = cellfun(@(x) mean(x(:, tBaseIdx) .^ 2, 2), changeCellRowNum(trialsEEG), "UniformOutput", false);
    rmsOnset = cellfun(@(x) mean(x(:, tIdx) .^ 2, 2), changeCellRowNum(trialsEEG), "UniformOutput", false);
    alpha = 0.01 / size(trialsEEG{1}, 1);
    ttestResRMS = cellfun(@(x, y) ttest(x, y, "Alpha", alpha), rmsBase, rmsOnset);
    mSave(fullfile(SAVEPATH, "Ratio_ttest_RMS_res.mat"), "ttestResRMS", "rmsOnset", "rmsBase", "alpha");
end