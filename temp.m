window = [-1000, 3000];
trialsPassive1 = trialDatasets([trialDatasets.protocol] == "passive1").trialAll;

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

%     Fig = plotRawWaveMultiEEG(chData, window, 1000, "k-Passive | r-Active");
    Fig = plotRawWaveMulti(chData, window, ['ICI = ', num2str(ICIs(index))], [2, 2], 56);
    scaleAxes(Fig, "y", [-10, 10]);
    scaleAxes(Fig, "x", [0, 2000]);
    lines.X = 1000;
    addLines2Axes(Fig, lines);
%     setAxes(Fig, "Visible", "off");
%     plotLayoutEEG(Fig);

    print(Fig, strcat("..\Figs\Passive 1 vs Active 1\Example ch56-59\", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r400");
end