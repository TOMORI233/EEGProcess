function passive1ProcessFcn(trialAll, trialsEEG, window, fs, params)
    % Length
    close all;
    parseStruct(params);
    mkdir(FIGPATH);

    if dataOnlyOpt
        return;
    end

    %% Figures
    % REG
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
            mPrint(gcf, fullfile(FIGPATH, strcat("Passive1 REG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
        end

    end

    % IRREG
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
            mPrint(gcf, fullfile(FIGPATH, strcat("Passive1 IRREG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
        end

    end

end