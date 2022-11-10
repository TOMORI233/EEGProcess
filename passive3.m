%% Passive 3
window = [0, 2000];
trialAll = trialDatasets([trialDatasets.protocol] == "passive3").trialAll;
EEGDataset = EEGDatasets([trialDatasets.protocol] == "passive3");
ICIs = unique([trialAll.ICI]);
FIGPATH = strcat("..\Figs\", dateStr, "\Passive 3\");
mkdir(FIGPATH);

colors = generateColorGrad(length(ICIs), 'rgb');

% Reg
Fig = figure;

for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & ([trialAll.type] == "REG" | [trialAll.type] == "PT"));

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window, th);

    t = linspace(window(1), window(2), size(chMean, 2));
    plot(t, chMean(55, :), "LineWidth", 1.5, "Color", colors{index});
    hold on;
end

titleStr = "passive 3 | REG";
% Fig = plotRawWaveMultiEEG(chData, window, 1000, titleStr);
scaleAxes(Fig, "y", [], yscale);
scaleAxes(Fig, "x", [0, 2000]);
% setAxes(Fig, "Visible", "off");
print(Fig, strcat(FIGPATH, "Reg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");