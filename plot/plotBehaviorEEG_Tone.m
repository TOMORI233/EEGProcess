function [Fig, mAxe] = plotBehaviorEEG_Tone(trials, fs, color, legendStr, Fig, mAxe)
    narginchk(3, 6);
    margins = [0.1, 0.1, 0.1, 0.1];

    if nargin < 4
        legendStr = "";
    end

    if nargin < 5
        Fig = figure;
    end

    if nargin == 5
        error("[Fig] and [mAxe] should be input together");
    end
    
    freq = [trials.freq];
    freqUnique = unique(freq);

    nDiff = [];
    nTotal = [];
    
    maximizeFig(Fig);
    
    for index = 1:length(freqUnique)
        temp = trials(freq == freqUnique(index));
        nTotal = [nTotal, length(temp)];
        nDiff = [nDiff, length(find([temp.isDiff]))];

        RTDiff = cell2mat(cellfun(@(x, y) (x - y) / fs * 1000, {temp([temp.isDiff]).push}, {temp([temp.isDiff]).offset}, 'UniformOutput', false));
        RTSame = cell2mat(cellfun(@(x, y) (x - y) / fs * 1000, {temp(~[temp.isDiff]).push}, {temp(~[temp.isDiff]).offset}, 'UniformOutput', false));

        if nargin < 6
            mAxe(2 * index) = mSubplot(Fig, length(freqUnique), 4, 4 * index - 1, [1, 1], [0.1, 0.1, 0.15, 0.15]);
            mAxe(2 * index + 1) = mSubplot(Fig, length(freqUnique), 4, 4 * index, [1, 1], [0.1, 0.1, 0.15, 0.15]);
        end

        scatter(mAxe(2 * index), RTSame, 1:length(RTSame), 40, color, "filled", "square");
        hold(mAxe(2 * index), "on");
        meanRTSame = mean(RTSame);
        yaxis = get(mAxe(2 * index), "YLim");
        stem(mAxe(2 * index), meanRTSame, yaxis(2), "Color", color, "LineStyle", "-", "LineWidth", 1.5);
        xlim(mAxe(2 * index), [0, 2000]);
        xlabel(mAxe(2 * index), 'Reaction Time (ms)');
        title(mAxe(2 * index), ['Press for same, ICI = ', num2str(freqUnique(index))]);

        scatter(mAxe(2 * index + 1), RTDiff, 1:length(RTDiff), 40, color, "filled");
        hold(mAxe(2 * index + 1), "on");
        meanRTDiff = mean(RTDiff);
        yaxis = get(mAxe(2 * index + 1), "YLim");
        stem(mAxe(2 * index + 1), meanRTDiff, yaxis(2), "Color", color, "LineStyle", "-", "LineWidth", 1.5);
        xlim(mAxe(2 * index + 1), [0, 2000]);
        xlabel(mAxe(2 * index + 1), 'Reaction Time (ms)');
        title(mAxe(2 * index + 1), ['Press for diff, ICI = ', num2str(freqUnique(index))]);
    end

    if nargin < 6
        mAxe(1) = mSubplot(Fig, 2, 2, 1, [1, 1], margins);
    end

    plot(mAxe(1), nDiff ./ nTotal, "Color", color, "LineWidth", 2, "DisplayName", legendStr);
    hold(mAxe(1), "on");
    xticks(mAxe(1), 1:length(freqUnique));
    xticklabels(mAxe(1), freqUnique);
    ylim(mAxe(1), [0 1]);
    yticks(mAxe(1), 0:0.2:1);
    xlabel(mAxe(1), "ICI");
    ylabel(mAxe(1), "Press-for-diff Ratio");
    legend(mAxe(1), "Location", "best");

    for index = 1:length(nDiff)
        text(mAxe(1), index, nDiff(index) / nTotal(index), [num2str(nDiff(index)), '/', num2str(nTotal(index))]);
    end

    return;
end