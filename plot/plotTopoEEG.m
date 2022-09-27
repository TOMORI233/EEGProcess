function Fig = plotTopoEEG(comp, plotSize, ICs)
    narginchk(1, 3);

    if nargin < 2
        plotSize = [8, 8];
    end

    if nargin < 3
        ICs = reshape(1:(plotSize(1) * plotSize(2)), plotSize(2), plotSize(1))';
    end

    if size(ICs, 1) ~= plotSize(1) || size(ICs, 2) ~= plotSize(2)
        disp("chs option not matched with plotSize. Resize chs...");
        ICs = reshape(ICs(1):(ICs(1) + plotSize(1) * plotSize(2) - 1), plotSize(2), plotSize(1))';
    end

    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05, 0.05, 0.1, 0.1];
    paddings = [0.01, 0.03, 0.01, 0.01];
    topo = comp.topo;
    
    for rIndex = 1:plotSize(1)
    
        for cIndex = 1:plotSize(2)

            if ICs(rIndex, cIndex) > size(topo, 1)
                continue;
            end

            ICNum = ICs(rIndex, cIndex);
            mSubplot(Fig, plotSize(1), plotSize(2), (rIndex - 1) * plotSize(2) + cIndex, [1, 1], margins, paddings);
            topoplot(topo(:, ICNum), 'chan64.loc');
            colorbar;
        end
    
    end

    return;
end