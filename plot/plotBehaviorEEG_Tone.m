function Fig = plotBehaviorEEG_Tone(trialAll, fs)
    margins = [0.1, 0.1, 0.1, 0.1];
    Fig = figure;
    maximizeFig(Fig);

    trialAll = trialAll([trialAll.type] == "PT" & ~[trialAll.miss]);
    freq = [trialAll.freq];
    freqUnique = unique(freq);

    nDiff = [];
    nTotal = [];

    mAxes = mSubplot(Fig, 2, 2, 1, [1, 1], margins);
    
    for index = 1:length(freqUnique)
        temp = trialAll(freq == freqUnique(index));
        nTotal = [nTotal, length(temp)];
        nDiff = [nDiff, length(find([temp.isDiff]))];

        RTDiff = cell2mat(cellfun(@(x, y) (x - y) / fs * 1000, {temp(~~[temp.isDiff]).push}, {temp(~~[temp.isDiff]).onset}, 'UniformOutput', false));
        RTSame = cell2mat(cellfun(@(x, y) (x - y) / fs * 1000, {temp(~[temp.isDiff]).push}, {temp(~[temp.isDiff]).onset}, 'UniformOutput', false));

        if nargin < 6
            mAxes(2 * index) = mSubplot(Fig, length(freqUnique), 4, 4 * index - 1, [1, 1], [0.1, 0.1, 0.15, 0.15]);
            mAxes(2 * index + 1) = mSubplot(Fig, length(freqUnique), 4, 4 * index, [1, 1], [0.1, 0.1, 0.15, 0.15]);
        end

        scatter(mAxes(2 * index), RTSame, 1:length(RTSame), 40, "r", "filled", "square");
        hold(mAxes(2 * index), "on");
        meanRTSame = mean(RTSame);
        yaxis = get(mAxes(2 * index), "YLim");
        stem(mAxes(2 * index), meanRTSame, yaxis(2), "Color", "r", "LineStyle", "-", "LineWidth", 1.5);
        xlim(mAxes(2 * index), [2000, 4000]);
        xlabel(mAxes(2 * index), 'Reaction Time From Sound Onset (ms)');
        title(mAxes(2 * index), ['Press for same, f = ', num2str(freqUnique(index)), ' Hz']);

        scatter(mAxes(2 * index + 1), RTDiff, 1:length(RTDiff), 40, "r", "filled");
        hold(mAxes(2 * index + 1), "on");
        meanRTDiff = mean(RTDiff);
        yaxis = get(mAxes(2 * index + 1), "YLim");
        stem(mAxes(2 * index + 1), meanRTDiff, yaxis(2), "Color", "r", "LineStyle", "-", "LineWidth", 1.5);
        xlim(mAxes(2 * index + 1), [2000, 4000]);
        xlabel(mAxes(2 * index + 1), 'Reaction Time From Sound Onset (ms)');
        title(mAxes(2 * index + 1), ['Press for diff, f = ', num2str(freqUnique(index)), ' Hz']);
    end

    plot(mAxes(1), nDiff ./ nTotal, "Color", "r", "LineWidth", 2, "DisplayName", "Tone");
    set(mAxes(1), "FontSize", 12);
    hold(mAxes(1), "on");
    xticks(mAxes(1), 1:length(freqUnique));
    xticklabels(mAxes(1), freqUnique);
    ylim(mAxes(1), [0 1]);
    yticks(mAxes(1), 0:0.2:1);
    xlabel(mAxes(1), "Deviant Frequency (Hz)");
    ylabel(mAxes(1), "Press-for-diff Ratio");
    legend(mAxes(1), "Location", "best");

    for index = 1:length(nDiff)
        text(mAxes(1), index, nDiff(index) / nTotal(index), [num2str(nDiff(index)), '/', num2str(nTotal(index))], "FontSize", 12);
    end

    return;
end