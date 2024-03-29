function active2ProcessFcn(trialAll, trialsEEG, window, fs, params)
    %% Ratio - with interval
    close all;
    parseStruct(params);
    mkdir(FIGPATH);
    mkdir(SAVEPATH);

    interval = trialAll(1).interval;

    %% BRI
    if exist("chsAvg.mat", "file") && exist("windowBRI4_A2.mat", "file")
        load("chsAvg.mat", "chsAvg");
        load("windowBRI4_A2.mat", "windowBRI");
        windowBeforeChange = [1500, 1600];
        tIdxBase = fix((windowBase(1) - window(1)) * fs / 1000) + 1:fix((windowBase(2) - window(1)) * fs / 1000);
        tIdxBase2 = fix((windowBeforeChange(1) - window(1)) * fs / 1000) + 1:fix((windowBeforeChange(2) - window(1)) * fs / 1000);
        tIdxBRI = fix((windowBRI(1) - window(1)) * fs / 1000) + 1:fix((windowBRI(2) - window(1)) * fs / 1000);
        BRI = cellfun(@(x) mean(x(chsAvg, tIdxBRI), 'all'), trialsEEG);
        BRIbase = cellfun(@(x) mean(x(chsAvg, tIdxBase), 'all'), trialsEEG);
        BRIbase2 = cellfun(@(x) mean(x(chsAvg, tIdxBase2), 'all'), trialsEEG); % BRI of wave before change
        save(fullfile(SAVEPATH, "BRI_A2.mat"), "BRI", "BRIbase", "BRIbase2", "window", "windowBRI", "windowBase", "windowBeforeChange", "chsAvg", "trialAll", "fs");
        
        if dataOnlyOpt
            return;
        end

    end

    %% Behavior
    behaviorRes = calBehaviorRes(trialAll);
    save(fullfile(SAVEPATH, "Behavior_A2_Res.mat"), "behaviorRes");

    if ~dataOnlyOpt
        plotBehaviorEEG_Click(trialAll, fs);
        mPrint(gcf, fullfile(FIGPATH, "Behavior active2.jpg"));
    end

    %% REG
    n = 1;
    idx = [trialAll.type] == "REG" & [trialAll.correct];
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
                plotRawWaveEEG(chMean, [], window, 1000 + interval, ['REG ', num2str(ICIs(index))]);
                scaleAxes("x", [0, 2000 + interval]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Active2 REG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
            end

        end

    end

    %% IRREG
    idx = [trialAll.type] == "IRREG" & ~[trialAll.miss];
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
                plotRawWaveEEG(chMean, [], window, 1000 + interval, ['IRREG ', num2str(ICIs(index))]);
                scaleAxes("x", [0, 2000 + interval]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Active2 IRREG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
            end

        end

    end

    save(fullfile(SAVEPATH, "chMean_A2.mat"), "chMeanData");
end