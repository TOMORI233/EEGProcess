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
chsIgnore = getOr(EEGPos, "ignore");
locs = getOr(EEGPos, "locs");
channelNames = getOr(EEGPos, "channelNames");

if isempty(locs)

    Fig = figure("WindowState", "maximized");
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.1, 0.1, 0.03, 0.06];

    for rIndex = 1:gridSize(1)

        for cIndex = 1:gridSize(2)
            chNum = (rIndex - 1) * gridSize(2) + cIndex;

            if chNum > size(chData(1).chMean, 1) || ismember(chNum, chsIgnore)
                continue;
            end

            mSubplot(Fig, gridSize(1), gridSize(2), EEGPos.map(chNum), [1, 1], margins, paddings);
            hold(gca, "on");

            for dIndex = 1:length(chData)
                chMean = chData(dIndex).chMean;
                t = linspace(window(1), window(2), size(chMean, 2));
                legendStr = getOr(chData(dIndex), "legend", '');
                h = plot(t, chMean(chNum, :), "LineWidth", 1.5, "Color", chData(dIndex).color, "DisplayName", legendStr);

                if isempty(legendStr) || chNum > 1
                    setLegendOff(h);
                end

            end

            xlim(window);

            if ~isempty(channelNames)
                title([channelNames{chNum}, titleStr]);
            else
                title(['CH ', num2str(chNum), titleStr]);
            end

            yticks([]);
            yticklabels('');

            if chNum < (gridSize(1) - 1) * gridSize(2) + 1
                xticklabels('');
            end

        end

    end

else
    [~, ~, Th, Rd, ~] = readlocs(locs);
    Th = pi / 180 * Th; % convert degrees to radians
    [XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates
    channels = EEGPos.channels;

    % flip
    X = zeros(length(channels), 1);
    Y = zeros(length(channels), 1);
    idx = ~ismember(channels, chsIgnore);
    X(idx) = mapminmax(YTemp(idx), 0.2, 0.8);
    Y(idx) = mapminmax(XTemp(idx), 0.05, 0.92);
    dX = 0.05;
    dY = 0.06;

    Fig = figure("WindowState", "maximized");
    
    for chNum = 1:length(channels)

        if ismember(chNum, chsIgnore)
            continue;
        end

        axes('Position', [X(chNum) - dX / 2, Y(chNum) - dY / 2, dX, dY]);
        hold(gca, "on");

        for dIndex = 1:length(chData)
            chMean = chData(dIndex).chMean;
            t = linspace(window(1), window(2), size(chMean, 2));
            legendStr = getOr(chData(dIndex), "legend", '');
            h = plot(t, chMean(chNum, :), "LineWidth", 1.5, "Color", chData(dIndex).color, "DisplayName", legendStr);

            if isempty(legendStr) || chNum > 1
                setLegendOff(h);
            end

        end

        xlim(window);

        if ~isempty(channelNames)
            title(channelNames{chNum}, titleStr);
        else
            title(['CH ', num2str(chNum), titleStr]);
        end
        
    end
    

end

scaleAxes(Fig, "y", "on", "autoTh", [0, 1]);

return;
end
