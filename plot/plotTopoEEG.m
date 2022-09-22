function Fig = plotTopoEEG(comp, plotSize, EEGPos)
    narginchk(1, 3);

    if nargin < 2
        plotSize = [8, 8];
    end

    if nargin < 3
        EEGPos = EEGPosConfig();
    end

    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    topo = comp.topo;
    topoSize = [10, 9];
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)
            ICNum = (rIndex - 1) * plotSize(2) + cIndex;

            if ICNum > size(topo, 1)
                continue;
            end

            mSubplot(Fig, plotSize(1), plotSize(2), ICNum, 1, margins, paddings);
            N = 5;
            temp = zeros(1, topoSize(1) * topoSize(2));
            temp(EEGPos) = topo(:, ICNum);
            C = flipud(reshape(temp, topoSize)');
            C = interp2(C, N);
            C = imgaussfilt(C, 8);
            X = linspace(1, topoSize(2), size(C, 2));
            Y = linspace(1, topoSize(1), size(C, 1));
            imagesc("XData", X, "YData", Y, "CData", C); hold on;
            contour(X, Y, C, "LineColor", "k");
            [~, idx] = max(topo(:, ICNum));
            title(['IC ', num2str(ICNum), ' | max - ', num2str(idx)]);
            xlim([1 topoSize(2)]);
            ylim([1 topoSize(1)]);
            xticklabels('');
            yticklabels('');
        end
    
    end

    return;
end