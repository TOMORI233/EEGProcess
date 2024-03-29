function passive3ProcessFcn(trialAll, trialsEEG, window, fs, params)
    %% Ratio
    close all;
    parseStruct(params);
    mkdir(FIGPATH);
    mkdir(SAVEPATH);

    %% BRI
    if exist("chsAvg.mat", "file") && exist("windowBRI4.mat", "file")
        load("chsAvg.mat", "chsAvg");
        load("windowBRI4.mat", "windowBRI");
        windowBeforeChange = [900, 1000];
        tIdxBase = fix((windowBase(1) - window(1)) * fs / 1000) + 1:fix((windowBase(2) - window(1)) * fs / 1000);
        tIdxBase2 = fix((windowBeforeChange(1) - window(1)) * fs / 1000) + 1:fix((windowBeforeChange(2) - window(1)) * fs / 1000);
        tIdxBRI = fix((windowBRI(1) - window(1)) * fs / 1000) + 1:fix((windowBRI(2) - window(1)) * fs / 1000);
        BRI = cellfun(@(x) mean(x(chsAvg, tIdxBRI), 'all'), trialsEEG);
        BRIbase = cellfun(@(x) mean(x(chsAvg, tIdxBase), 'all'), trialsEEG);
        BRIbase2 = cellfun(@(x) mean(x(chsAvg, tIdxBase2), 'all'), trialsEEG); % BRI of wave before change
        save(fullfile(SAVEPATH, "BRI_P3.mat"), "BRI", "BRIbase", "BRIbase2", "window", "windowBRI", "windowBase", "windowBeforeChange", "chsAvg", "trialAll", "fs");
        return;
    end

    %% Find channels with significant auditory reaction | Use mean
    if exist("windowOnset.mat", "file")
        load("windowOnset.mat", "windowOnset"); % auditory window, ms
        tIdxBase = fix((windowBase(1) - window(1)) * fs / 1000) + 1:fix((windowBase(2) - window(1)) * fs / 1000);
        tIdx = fix((windowOnset(1) - window(1)) * fs / 1000) + 1:fix((windowOnset(2) - window(1)) * fs / 1000);
        avgBase = cellfun(@(x) mean(x(:, tIdxBase), 2), changeCellRowNum(trialsEEG), "UniformOutput", false);
        avgOnset = cellfun(@(x) mean(x(:, tIdx), 2), changeCellRowNum(trialsEEG), "UniformOutput", false);
        [~, p] = cellfun(@(x, y) ttest(x, y), avgBase, avgOnset);
        save(fullfile(SAVEPATH, "FindChs.mat"), "p", "avgOnset", "avgBase");

        if dataOnlyOpt
            return;
        end

    end

    %% REG
    n = 1;
    idx = [trialAll.type] == "REG";
    trials = trialAll(idx);
    trialsEEG_temp = trialsEEG(idx);
    ICIs = unique([trials.ICI])';

    for index = 1:length(ICIs)
        temp = trialsEEG_temp([trials.ICI] == ICIs(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            chMeanData(n, 1).chMean = chMean;
            chMeanData(n, 1).ICI = ICIs(index);
            chMeanData(n, 1).freq = 0;
            chMeanData(n, 1).type = "REG";
            n = n + 1;

            if ~dataOnlyOpt
                plotRawWaveEEG(chMean, [], window, 1000, ['REG ', num2str(ICIs(index))]);
                scaleAxes("x", [0, 2000]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Passive3 REG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
            end

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
            chMeanData(n, 1).chMean = chMean;
            chMeanData(n, 1).ICI = ICIs(index);
            chMeanData(n, 1).freq = 0;
            chMeanData(n, 1).type = "IRREG";
            n = n + 1;

            if ~dataOnlyOpt
                plotRawWaveEEG(chMean, [], window, 1000, ['IRREG ', num2str(ICIs(index))]);
                scaleAxes("x", [0, 2000]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Passive3 IRREG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
            end

        end

    end

    %% PT
    idx = [trialAll.type] == "PT";
    trials = trialAll(idx);
    trialsEEG_temp = trialsEEG(idx);
    freqs = unique([trials.freq])';

    for index = 1:length(freqs)
        temp = trialsEEG_temp([trials.freq] == freqs(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            chMeanData(n, 1).chMean = chMean;
            chMeanData(n, 1).ICI = 0;
            chMeanData(n, 1).freq = freqs(index);
            chMeanData(n, 1).type = "PT";
            n = n + 1;

            if ~dataOnlyOpt
                plotRawWaveEEG(chMean, [], window, 1000, ['PT ', num2str(freqs(index))]);
                scaleAxes("x", [0, 2000]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Passive3 PT-", strrep(num2str(freqs(index)), '.', '_'), ".jpg")));
            end

        end

    end

    save(fullfile(SAVEPATH, "chMean_P3.mat"), "chMeanData");
end