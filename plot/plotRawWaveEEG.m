function Fig = plotRawWaveEEG(chMean, chErr, window, titleStr, EEGPos)
    narginchk(3, 5);

    if nargin < 4 || isempty(titleStr)
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 5
        EEGPos = EEGPos_Neuroscan64();
    end

    gridSize = EEGPos.grid;
    chsIgnore = getOr(EEGPos, "ignore");
    channelNames = getOr(EEGPos, "channelNames");

    Fig = figure("WindowState", "maximized");
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.1, 0.1, 0.03, 0.06];

    for rIndex = 1:gridSize(1)

        for cIndex = 1:gridSize(2)
            chNum = (rIndex - 1) * gridSize(2) + cIndex;

            if chNum > size(chMean, 1) || ismember(chNum, chsIgnore)
                continue;
            end
            
            t = linspace(window(1), window(2), size(chMean, 2));
            mSubplot(Fig, gridSize(1), gridSize(2), EEGPos.map(chNum), [1, 1], margins, paddings);
            
            if ~isempty(chErr)
                y1 = chMean(chNum, :) + chErr(chNum, :);
                y2 = chMean(chNum, :) - chErr(chNum, :);
                fill([t fliplr(t)], [y1 fliplr(y2)], [0, 0, 0], 'edgealpha', '0', 'facealpha', '0.3', 'DisplayName', 'Error bar');
                hold on;
            end

            plot(t, chMean(chNum, :), "k", "LineWidth", 1.5);
            hold on;

            xlim(window);
            if ~isempty(channelNames)
                title(['CH ', num2str(chNum), ' | ', channelNames{chNum}, titleStr]);
            else
                title(['CH ', num2str(chNum), titleStr]);
            end
        end

    end

    scaleAxes(Fig, "y", "on");

    return;
end
