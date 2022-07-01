function Fig = plotRawWaveEEG(chMean, chStd, window, transTime, titleStr, EEGPos)
    narginchk(3, 6);

    if nargin < 4
        transTime = 1000; % ms
    end

    if nargin < 5
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 6
        EEGPos = EEGPosConfig();
    end

    Fig = figure;
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.1, 0.1, 0.03, 0.06];
    maximizeFig(Fig);
    plotSize = [10, 9];

    for rIndex = 1:plotSize(1)

        for cIndex = 1:plotSize(2)
            chNum = (rIndex - 1) * plotSize(2) + cIndex;

            if chNum > size(chMean, 1) || ismember(chNum, [33, 43])
                continue;
            end
            
            t = linspace(window(1), window(2), size(chMean, 2));
            mSubplot(Fig, plotSize(1), plotSize(2), EEGPos(chNum), [1, 1], margins, paddings);
            
            if ~isempty(chStd)
                y1 = chMean(chNum, :) + chStd(chNum, :);
                y2 = chMean(chNum, :) - chStd(chNum, :);
                fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
                hold on;
            end

            plot(t, chMean(chNum, :), "k", "LineWidth", 1.5);
            hold on;

            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);

            if ~any([1, 4, 6, 15, 24, 34, 44, 53, 60, 61] == chNum)
                yticks([]);
                yticklabels('');
            end

            if chNum < (plotSize(1) - 1) * plotSize(2) + 1
                xticklabels('');
            end

        end

    end

    yRange = scaleAxes(Fig);
    allAxes = findobj(Fig, "Type", "axes");

    for aIndex = 1:length(allAxes)
        plot(allAxes(aIndex), [0, 0], yRange, "k--", "LineWidth", 1);
        plot(allAxes(aIndex), transTime * ones(1, 2), yRange, "k--", "LineWidth", 1);
    end

    return;
end
