function Fig = plotRawWaveEEG(chMean, chStd, window, titleStr, EEGPos)
    narginchk(3, 5);

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
        end

    end

    scaleAxes(Fig);

    return;
end
