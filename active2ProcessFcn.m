function active2ProcessFcn(trialAll, trialsEEG, window, fs, params)
    % Ratio - with interval
    close all;
    parseStruct(params);
    mkdir(FIGPATH);

    interval = trialAll(1).interval;

    %% Data export
    % Behavior
    behaviorRes = calBehaviorRes(trialAll);
    save(fullfile(SAVEPATH, "Behavior_A2_Res.mat"), "behaviorRes");

    if dataOnlyOpt
        return;
    end

    %% Figures
    % Behavior
    plotBehaviorEEG_Click(trialAll, fs);
    mPrint(gcf, fullfile(FIGPATH, "Behavior active2.jpg"));

    % REG
    idx = [trialAll.type] == "REG" & [trialAll.correct];
    trials = trialAll(idx);
    trialsEEG_temp = trialsEEG(idx);
    ICIs = unique([trials.ICI])';

    for index = 1:length(ICIs)
        temp = trialsEEG_temp([trials.ICI] == ICIs(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            plotRawWaveEEG(chMean, [], window, 1000 + interval, ['REG ', num2str(ICIs(index))]);
            scaleAxes("x", [0, 2000 + interval]);
            scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
            mPrint(gcf, fullfile(FIGPATH, strcat("Active2 REG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
        end

    end

    % IRREG
    idx = [trialAll.type] == "IRREG" & ~[trialAll.miss];
    trials = trialAll(idx);
    trialsEEG_temp = trialsEEG(idx);
    ICIs = unique([trials.ICI])';

    for index = 1:length(ICIs)
        temp = trialsEEG_temp([trials.ICI] == ICIs(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            plotRawWaveEEG(chMean, [], window, 1000 + interval, ['IRREG ', num2str(ICIs(index))]);
            scaleAxes("x", [0, 2000 + interval]);
            scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
            mPrint(gcf, fullfile(FIGPATH, strcat("Active2 IRREG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
        end

    end

end