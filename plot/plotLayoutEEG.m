function Figs = plotLayoutEEG(Figs, alphaValue)
    narginchk(1, 2);

    if nargin < 2
        alphaValue = 0.5;
    end
    
    for fIndex = 1:length(Figs)
        setAxes(Figs(fIndex), 'color', 'none');
        layAx = mSubplot(Figs(fIndex), 1, 1, 1, [1 1], zeros(4, 1));
        load('eegLayout.mat');
    
        image(layAx, eegLayout); hold on

        alpha(layAx, alphaValue);
        set(layAx, 'XTickLabel', []);
        set(layAx, 'YTickLabel', []);
        set(layAx, 'Box', 'off');
        set(layAx, 'visible', 'off');

        % Set as background
        allAxes = findobj(Figs(fIndex), "Type", "axes");
        set(Figs(fIndex), 'child', [allAxes; layAx]);
        drawnow;
    end

    return;
end
