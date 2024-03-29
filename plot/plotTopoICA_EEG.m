function Fig = plotTopoICA_EEG(topo, locs, ICs2Plot)
    narginchk(1, 3);

    plotSize = autoPlotSize(size(topo, 2)); % topo is chan-by-IC

    if nargin < 3
        ICs2Plot = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if size(ICs2Plot, 1) ~= plotSize(1) || size(ICs2Plot, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        ICs2Plot = reshape(ICs2Plot(1):(ICs2Plot(1) + plotSize(1) * plotSize(2) - 1), plotSize(2), plotSize(1))';
    end

    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)

            if ICs2Plot(rIndex, cIndex) > size(topo, 2)
                continue;
            end

            ICNum = ICs2Plot(rIndex, cIndex);
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            topoplot(topo(:, ICNum), locs);
            title(['IC ', num2str(ICNum)]);
            colorbar;
        end
    
    end

    return;
end