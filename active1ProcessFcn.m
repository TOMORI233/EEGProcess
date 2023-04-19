function active1ProcessFcn(trialAll, trialsEEG, window, fs, params)
    close all;
    parseStruct(params);

    %% Behavior
    plotBehaviorEEG(trialAll([trialAll.ICI] ~= 0), fs);
    mPrint(gcf, fullfile(SAVEPATH, "Behavior active1.jpg"));

    %% REG
    idx = [trialAll.type] == "REG" & [trialAll.correct];
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
            mPrint(gcf, fullfile(SAVEPATH, strcat("REG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
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
            plotRawWaveEEG(chMean, [], window, 1000, ['IRREG ', num2str(ICIs(index))]);
            scaleAxes("x", [0, 2000]);
            scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
            mPrint(gcf, fullfile(SAVEPATH, strcat("IRREG-", strrep(num2str(ICIs(index)), '.', '_'), ".jpg")));
        end

    end

    %% Find channels with significant auditory reaction
    % Use RMS
    windowA = [0, 300]; % auditory window, ms
    tBaseIdx = fix((windowBase(1) - window(1)) * fs / 1000) + 1:fix((windowBase(2) - window(1)) * fs / 1000);
    tIdx = fix((windowA(1) - window(1)) * fs / 1000) + 1:fix((windowA(2) - window(1)) * fs / 1000);
    basePower = cellfun(@(x) mean(x(:, tBaseIdx) .^ 2, 2), changeCellRowNum(trialsEEG), "UniformOutput", false);
    erpPower = cellfun(@(x) mean(x(:, tIdx) .^ 2, 2), changeCellRowNum(trialsEEG), "UniformOutput", false);
    alpha = 0.01 / size(trialsEEG{1}, 1);
    res = cellfun(@(x, y) ttest(x, y, "Alpha", alpha), basePower, erpPower);

    temp = cell2mat(erpPower);
    t = linspace(0, max(cellfun(@mean, erpPower)), 1e4);
    step = t(2) - t(1);
    [f, xi] = ksdensity(temp, t);
    figure;
    plot(xi, cumsum(f) * step);
    chs0 = find(res == 1);
    chs = find(cellfun(@mean, erpPower) > xi(find(cumsum(f) * step > 0.6, 1)) & res == 1);
end