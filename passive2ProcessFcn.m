function passive2ProcessFcn(trialAll, trialsEEG, window, fs, params)
    % Variance
    close all;
    parseStruct(params);
    mkdir(fullfile(SAVEPATH, "Figs"));

    vars = unique([trialAll.variance])';

    for index = 1:length(vars)
        temp = trialsEEG([trialAll.variance] == vars(index));

        if ~isempty(temp)
            chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum(temp), "UniformOutput", false));
            plotRawWaveEEG(chMean, [], window, 1000, ['Var | ', num2str(vars(index))]);
            scaleAxes("x", [0, 2000]);
            scaleAxes("y", "cutoffRange", [-20, 20], "symOpt", "max");
            mPrint(gcf, fullfile(SAVEPATH, "Figs", strcat("Passive2 Variance-", num2str(vars(index)), ".jpg")));
        end

    end

end