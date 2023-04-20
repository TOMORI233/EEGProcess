function Fig = plotBehaviorEEG_Click(trialAll, fs)
    margins = [0.1, 0.1, 0.1, 0.1];
    Fig = figure;
    maximizeFig(Fig);

    types = ["REG", "IRREG"];
    colors = ["r", "b"];
    legends = ["REG", "IRREG"];

    trialAll = trialAll(([trialAll.type] == "REG" | [trialAll.type] == "IRREG") & ~[trialAll.miss]);
    ICIUnique = unique([trialAll.ICI]);
    mAxe = mSubplot(Fig, 2, 2, 1, 1, margins);
    mAxe(2) = mSubplot(Fig, 2, 2, 3, 1, margins);

    for index = 1:length(ICIUnique)
        mAxe(2 + 2 * index - 1) = mSubplot(Fig, length(ICIUnique), 4, 4 * index - 1, [1, 1], [0.1, 0.1, 0.15, 0.15]);
        mAxe(2 + 2 * index) = mSubplot(Fig, length(ICIUnique), 4, 4 * index, [1, 1], [0.1, 0.1, 0.15, 0.15]);
    end
    
    for tIndex = 1:length(types)
        trials = trialAll([trialAll.type] == types(tIndex));
    
        nDiff = [];
        nTotal = [];
    
        for index = 1:length(ICIUnique)
            temp = trials([trials.ICI] == ICIUnique(index));

            nTotal = [nTotal, length(temp)];
            nDiff = [nDiff, length(find([temp.isDiff]))];
    
            RTDiff = cell2mat(cellfun(@(x, y) (x - y) / fs * 1000, {temp(~~[temp.isDiff]).push}, {temp(~~[temp.isDiff]).onset}, 'UniformOutput', false));
            RTSame = cell2mat(cellfun(@(x, y) (x - y) / fs * 1000, {temp(~[temp.isDiff]).push}, {temp(~[temp.isDiff]).onset}, 'UniformOutput', false));
    
            scatter(mAxe(2 + 2 * index - 1), RTSame, 1:length(RTSame), 40, colors(tIndex), "filled", "square");
            hold(mAxe(2 + 2 * index - 1), "on");
            meanRTSame = mean(RTSame);
            yaxis = get(mAxe(2 + 2 * index - 1), "YLim");
            stem(mAxe(2 + 2 * index - 1), meanRTSame, yaxis(2), "Color", colors(tIndex), "LineStyle", "-", "LineWidth", 1.5);
            xlim(mAxe(2 + 2 * index - 1), [2000, 4000]);
            xlabel(mAxe(2 + 2 * index - 1), 'Reaction Time From Sound Onset (ms)');
            title(mAxe(2 + 2 * index - 1), ['Press for same, ICI = ', num2str(ICIUnique(index))]);
    
            scatter(mAxe(2 + 2 * index), RTDiff, 1:length(RTDiff), 40, colors(tIndex), "filled");
            hold(mAxe(2 + 2 * index), "on");
            meanRTDiff = mean(RTDiff);
            yaxis = get(mAxe(2 + 2 * index), "YLim");
            stem(mAxe(2 + 2 * index), meanRTDiff, yaxis(2), "Color", colors(tIndex), "LineStyle", "-", "LineWidth", 1.5);
            xlim(mAxe(2 + 2 * index), [2000, 4000]);
            xlabel(mAxe(2 + 2 * index), 'Reaction Time From Sound Onset (ms)');
            title(mAxe(2 + 2 * index), ['Press for diff, ICI = ', num2str(ICIUnique(index))]);
        end
    
        temp = nDiff ./ nTotal;
        nanIdx = isnan(temp);
        plot(mAxe(tIndex), temp(~nanIdx), "Color", colors(tIndex), "LineWidth", 2, "DisplayName", legends(tIndex));
        set(mAxe(tIndex), "FontSize", 12);
        hold(mAxe(tIndex), "on");
        xticks(mAxe(tIndex), 1:length(ICIUnique(~nanIdx)));
        xticklabels(mAxe(tIndex), ICIUnique(~nanIdx));
        ylim(mAxe(tIndex), [0 1]);
        yticks(mAxe(tIndex), 0:0.2:1);
        xlabel(mAxe(tIndex), "ICI");
        ylabel(mAxe(tIndex), "Press-for-diff Ratio");
        legend(mAxe(tIndex), "Location", "northwest");

        nDiff = nDiff(~nanIdx);
        nTotal = nTotal(~nanIdx);
        for index = 1:length(temp(~nanIdx))
            text(mAxe(tIndex), index, nDiff(index) / nTotal(index), [num2str(nDiff(index)), '/', num2str(nTotal(index))], "FontSize", 12);
        end
    end
    
    return;
end