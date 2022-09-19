function Fig = plotRawWaveMultiEEG(chData, window, transTime, titleStr, EEGPos)
    narginchk(2, 5);

    if nargin < 3
        transTime = 1000; % ms
    end

    if nargin < 4
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 5
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

            if chNum > size(chData(1).chMean, 1) || ismember(chNum, [33, 43])
                continue;
            end
            
            mSubplot(Fig, plotSize(1), plotSize(2), EEGPos(chNum), [1, 1], margins, paddings);
            
            for dIndex = 1:length(chData)
                chMean = chData(dIndex).chMean;
                t = linspace(window(1), window(2), size(chMean, 2));
                plot(t, chMean(chNum, :), "LineWidth", 1.5, "Color", chData(dIndex).color);
                hold on;
            end

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

        if ~isempty(transTime)
            plot(allAxes(aIndex), transTime * ones(1, 2), yRange, "k--", "LineWidth", 1);
        end
        
    end

    return;
end
