function passive2ProcessFcn(trialAll, trialsEEG, window, fs, params)
    %% Variance
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
        save(fullfile(SAVEPATH, "BRI_P2.mat"), "BRI", "BRIbase", "BRIbase2", "window", "windowBRI", "windowBase", "windowBeforeChange", "chsAvg", "trialAll", "fs");
        
        if dataOnlyOpt
            return;
        end

    end

    %% chMean
    n = 1;
    vars = unique([trialAll.variance])';

    for index = 1:length(vars)
        temp = trialsEEG([trialAll.variance] == vars(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            chMeanData(n, 1).chMean = chMean;
            chMeanData(n, 1).variance = vars(index);
            n = n + 1;
            
            if ~dataOnlyOpt
                plotRawWaveEEG(chMean, [], window, 1000, ['Var ', num2str(vars(index))]);
                scaleAxes("x", [0, 2000]);
                scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
                mPrint(gcf, fullfile(FIGPATH, strcat("Passive2 Variance-", num2str(vars(index)), ".jpg")));
            end

        end

    end

    save(fullfile(SAVEPATH, "chMean_P2.mat"), "chMeanData");
end