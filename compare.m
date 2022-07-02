window = [-1000, 3000];
ICIs = unique([trialsPassive1.ICI]);

for index = 1:length(ICIs)
    trials1 = trialsPassive1([trialsPassive1.ICI] == ICIs(index) & ([trialsPassive1.type] == "REG" | [trialsPassive1.type] == "PT"));
    [~, chData(1).chMean, ~, ~] = selectEEG(EEGDatasets(1), trials1, window);
    chData(1).color = "k";
    chData(1).legend = "passive";

    trials2 = trialsActive1([trialsActive1.ICI] == ICIs(index) & [trialsActive1.correct] & ([trialsActive1.type] == "REG" | [trialsActive1.type] == "PT"));
    [~, chData(2).chMean, ~, ~] = selectEEG(EEGDatasets(3), trials2, window);
    chData(2).color = "r";
    chData(2).legend = "active";

    Fig = plotRawWaveMultiEEG(chData, window, 1000, num2str(ICIs(index)));
    scaleAxes(Fig, "y", [-10, 10]);
    scaleAxes(Fig, "x", [0, 2000]);
    lines.X = 1000;
    lines.color = "k";
    addLines2Axes(Fig, lines);

%     Fig = plotTFACompare(chData(2).chMean, chData(1).chMean, fs0, fs, window, num2str(ICIs(index)));
%     scaleAxes(Fig, "x", [0, 2000]);
%     scaleAxes(Fig, "c", [], [-6, 6], "max");
%     lines.X = 1000;
%     lines.color = "w";
%     addLines2Axes(Fig, lines);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig);

%     print(Fig, ['..\Figs\Passive 1 vs Active 1\1hp\', strrep(num2str(ICIs(index)), '.', '_')], "-djpeg", "-r400");
end