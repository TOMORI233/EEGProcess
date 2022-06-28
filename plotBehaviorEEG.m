function [Fig, mAxe] = plotBehaviorEEG(trials, fs, color, legendStr, Fig, mAxe)
    narginchk(4, 6);
    margins = [0.1, 0.1, 0.1, 0.1];

    if nargin < 5
        Fig = figure;
    end

    if nargin == 5
        error("The number of input params should be 1 or 3");
    end
    
    ICI = [trials.ICI];
    ICIUnique = unique(ICI);

    nPush = [];
    nTotal = [];
    
    maximizeFig(Fig);
    
    for index = 1:length(ICIUnique)
        temp = trials(ICI == ICIUnique(index));
        nTotal = [nTotal, length(temp)];
        nPush = [nPush, length([temp.push])];
        RT = cell2mat(cellfun(@(x, y) (x - y) / fs, {temp.push}, {temp.onset}, 'UniformOutput', false));

        if nargin < 6
            mAxe(index + 1) = mSubplot(Fig, length(ICIUnique), 4, 4 * index, [1, 1], [0.1, 0.1, 0.15, 0.15]);
        end

        scatter(mAxe(index + 1), RT, 1:length(RT), 40, color, "filled");
        hold on;
        meanRT = mean(RT);
        yaxis = get(mAxe(index + 1), "YLim");
        stem(mAxe(index + 1), meanRT, yaxis(2), "Color", color, "LineStyle", "-", "LineWidth", 1.5);
%         xlim(mAxe(index + 1), [0, 800]);
        xlabel(mAxe(index + 1), 'Reaction Time (ms)');
        title(mAxe(index + 1), ['ICI = ', num2str(ICIUnique(index))]);
    end

    if nargin < 6
        mAxe(1) = mSubplot(Fig, 2, 2, 1, [1, 1], margins);
    end

    plot(mAxe(1), nPush ./ nTotal, "Color", color, "LineWidth", 2, "DisplayName", legendStr);
    hold on;
    xticks(mAxe(1), 1:length(ICIUnique));
    xticklabels(mAxe(1), ICIUnique);
    ylim(mAxe(1), [0 1]);
    yticks(mAxe(1), 0:0.2:1);
    xlabel(mAxe(1), "ICI");
    ylabel(mAxe(1), "Push Ratio");
    legend(mAxe(1), "Location", "best");

    for index = 1:length(nPush)
        text(mAxe(1), index, nPush(index) / nTotal(index), [num2str(nPush(index)), '/', num2str(nTotal(index))]);
    end

    return;
end