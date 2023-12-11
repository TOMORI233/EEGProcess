function Fig = plotRawWaveMultiEEG(chData, window, titleStr, EEGPos)
    narginchk(2, 4);

    if nargin < 3 || isempty(titleStr)
        titleStr = '';
    else
        titleStr = [' | ', char(titleStr)];
    end

    if nargin < 4
        EEGPos = EEGPos_Neuroscan64();
    end

    gridSize = EEGPos.grid;

    Fig = figure;
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.1, 0.1, 0.03, 0.06];
    maximizeFig(Fig);

    for rIndex = 1:gridSize(1)

        for cIndex = 1:gridSize(2)
            chNum = (rIndex - 1) * gridSize(2) + cIndex;

            if chNum > size(chData(1).chMean, 1)
                continue;
            end
            
            mSubplot(Fig, gridSize(1), gridSize(2), EEGPos.map(chNum), [1, 1], margins, paddings);
            
            for dIndex = 1:length(chData)
                chMean = chData(dIndex).chMean;
                t = linspace(window(1), window(2), size(chMean, 2));
                plot(t, chMean(chNum, :), "LineWidth", 1.5, "Color", chData(dIndex).color, "DisplayName", chData(dIndex).legend);
                hold on;
            end

            xlim(window);
            title(['CH ', num2str(chNum), titleStr]);
            yticks([]);
            yticklabels('');

            if chNum < (gridSize(1) - 1) * gridSize(2) + 1
                xticklabels('');
            end

        end

    end

    scaleAxes(Fig);

    return;
end
