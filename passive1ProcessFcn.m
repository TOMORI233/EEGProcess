function passive1ProcessFcn(trialAll, trialsEEG, window, fs, params)
    %% Length
    close all;
    parseStruct(params);
    mkdir(FIGPATH);

    if exist("chsAvg.mat", "file") && exist("windowBRI4.mat", "file") && exist("windowBRI8.mat", "file") && exist("windowBRI16.mat", "file") && exist("windowBRI32.mat", "file")
        load("chsAvg.mat", "chsAvg");
        windowBeforeChange = [900, 1000]; % ms
        tIdxBase = fix((windowBase(1) - window(1)) * fs / 1000) + 1:fix((windowBase(2) - window(1)) * fs / 1000);
        tIdxBase2 = fix((windowBeforeChange(1) - window(1)) * fs / 1000) + 1:fix((windowBeforeChange(2) - window(1)) * fs / 1000);
        BRIbase = cellfun(@(x) mean(x(chsAvg, tIdxBase), 'all'), trialsEEG);
        BRIbase2 = cellfun(@(x) mean(x(chsAvg, tIdxBase2), 'all'), trialsEEG); % BRI of wave before change
        BRI = zeros(length(trialAll), 1);

        % Base ICI = 4
        load("windowBRI4.mat", "windowBRI");
        tIdxBRI = fix((windowBRI(1) - window(1)) * fs / 1000) + 1:fix((windowBRI(2) - window(1)) * fs / 1000);
        idx = [trialAll.ICI] == 4.06;
        BRI(idx) = cellfun(@(x) mean(x(chsAvg, tIdxBRI), 'all'), trialsEEG(idx));
        
        % Base ICI = 8
        load("windowBRI8.mat", "windowBRI");
        tIdxBRI = fix((windowBRI(1) - window(1)) * fs / 1000) + 1:fix((windowBRI(2) - window(1)) * fs / 1000);
        idx = [trialAll.ICI] == 8.12;
        BRI(idx) = cellfun(@(x) mean(x(chsAvg, tIdxBRI), 'all'), trialsEEG(idx));

        % Base ICI = 16
        load("windowBRI16.mat", "windowBRI");
        tIdxBRI = fix((windowBRI(1) - window(1)) * fs / 1000) + 1:fix((windowBRI(2) - window(1)) * fs / 1000);
        idx = [trialAll.ICI] == 16.24;
        BRI(idx) = cellfun(@(x) mean(x(chsAvg, tIdxBRI), 'all'), trialsEEG(idx));

        % Base ICI = 32
        load("windowBRI32.mat", "windowBRI");
        tIdxBRI = fix((windowBRI(1) - window(1)) * fs / 1000) + 1:fix((windowBRI(2) - window(1)) * fs / 1000);
        idx = [trialAll.ICI] == 32.48;
        BRI(idx) = cellfun(@(x) mean(x(chsAvg, tIdxBRI), 'all'), trialsEEG(idx));

        save(fullfile(SAVEPATH, "BRI_P1.mat"), "BRI", "BRIbase", "BRIbase2", "window", "windowBRI", "windowBase", "windowBeforeChange", "chsAvg", "trialAll", "fs");
        return;
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
            chMeanData(n, 1).type = "REG";
            n = n + 1;
            
            if ~dataOnlyOpt
                plotRawWaveEEG(chMean, [], window, 1000, ['REG ', num2str(ICIs(index))]);
                scaleAxes("x", [0, 2000]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Passive1 REG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
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
            chMeanData(n, 1).type = "IRREG";
            n = n + 1;
            
            if ~dataOnlyOpt
                plotRawWaveEEG(chMean, [], window, 1000, ['IRREG ', num2str(ICIs(index))]);
                scaleAxes("x", [0, 2000]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Passive1 IRREG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
            end

        end

    end

    mSave(fullfile(SAVEPATH, "chMean_P1.mat"), "chMeanData");
end