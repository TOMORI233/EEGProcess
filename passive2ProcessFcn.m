function passive2ProcessFcn(trialAll, trialsEEG, window, fs, params)
    %% Variance
    close all;
    parseStruct(params);
    mkdir(FIGPATH);

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

    mSave(fullfile(SAVEPATH, "chMean_P2.mat"), "chMeanData");
end