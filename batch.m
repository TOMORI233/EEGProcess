clear; clc;
close all force;
addpath(genpath(fileparts(mfilename("fullpath"))));

%% Parameter settings
ROOTPATH = "D:\Education\Lab\Projects\EEG\Data\CDT\20220708";
th = 0.2;

temp = string(split(ROOTPATH, "\"));
dateStr = temp(end);

%% Load data
opts.fhp = 0.5;
opts.save = false;
opts.rules = rulesConfig([]);
[EEGDatasets, trialDatasets] = EEGPreprocess(ROOTPATH, opts);
fs0 = EEGDatasets(1).fs;
warning off;

%% Behavior process
trialsActive1 = trialDatasets([trialDatasets.protocol] == "active1").trialAll;
trialsActive2 = trialDatasets([trialDatasets.protocol] == "active2").trialAll;

[FigB1, mAxeB1] = plotBehaviorEEG(trialsActive1([trialsActive1.type] == "REG" & ~[trialsActive1.miss]), fs0, "r", "Reg Interval 0");
plotBehaviorEEG(trialsActive2([trialsActive2.type] == "REG" & ~[trialsActive2.miss]), fs0, "b", "Reg Interval 600", FigB1, mAxeB1);

[FigB2, mAxeB2] = plotBehaviorEEG(trialsActive1([trialsActive1.type] == "IRREG" & ~[trialsActive1.miss]), fs0, "r", "Irreg Interval 0");
plotBehaviorEEG(trialsActive2([trialsActive2.type] == "IRREG" & ~[trialsActive2.miss]), fs0, "b", "Irreg Interval 600", FigB2, mAxeB2);

[FigB3, mAxeB3] = plotBehaviorEEG_Tone(trialsActive1([trialsActive1.type] == "PT" & ~[trialsActive1.miss]), fs0, "r", "Tone");

BPATH = strcat("..\Figs\", dateStr, "\Behavior\");
mkdir(BPATH);
print(FigB1, strcat(BPATH, "BEHAVIOR_REG"), "-djpeg", "-r300");
print(FigB2, strcat(BPATH, "BEHAVIOR_IRREG"), "-djpeg", "-r300");
print(FigB3, strcat(BPATH, "BEHAVIOR_PT"), "-djpeg", "-r300");

%% Passive 3
window = [0, 2000];
trialAll = trialDatasets([trialDatasets.protocol] == "passive3").trialAll;
EEGDataset = EEGDatasets([trialDatasets.protocol] == "passive3");
ICIs = unique([trialAll.ICI]);
FIGPATH = strcat("..\Figs\", dateStr, "\Passive 3\");
mkdir(FIGPATH);

% Reg
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & ([trialAll.type] == "REG" | [trialAll.type] == "PT"));

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window, th);
    legendStr = strcat("passive 3 | REG ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1000, legendStr);
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 2000]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Reg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

% Irreg
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & [trialAll.type] == "IRREG");

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window, th);
    legendStr = strcat("passive 3 | IRREG", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1000, legendStr);
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 2000]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Irreg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

%% Active 1
window = [0, 2000];
trialAll = trialDatasets([trialDatasets.protocol] == "active1").trialAll;
EEGDataset = EEGDatasets([trialDatasets.protocol] == "active1");
ICIs = unique([trialAll.ICI]);
FIGPATH = strcat("..\Figs\", dateStr, "\Active 1\");
mkdir(FIGPATH);

% Reg
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & [trialAll.correct] & ([trialAll.type] == "REG" | ([trialAll.type] == "PT" & [trialAll.freq] ~= 250)));

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window, th);
    legendStr = strcat("active 1 | REG ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1000, legendStr);
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 2000]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Reg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

% Irreg
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & ~[trialAll.miss] & [trialAll.type] == "IRREG");

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window, th);
    legendStr = strcat("active 1 | IRREG", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1000, legendStr);
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 2000]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Irreg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

%% Active 2
window = [0, 2600];
trialAll = trialDatasets([trialDatasets.protocol] == "active2").trialAll;
EEGDataset = EEGDatasets([trialDatasets.protocol] == "active2");
ICIs = unique([trialAll.ICI]);
FIGPATH = strcat("..\Figs\", dateStr, "\Active 2\");
mkdir(FIGPATH);

% Reg
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & [trialAll.correct] & ([trialAll.type] == "REG" | ([trialAll.type] == "PT" & [trialAll.freq] ~= 250)));

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window, th);
    legendStr = strcat("active 2 | REG ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1600, legendStr);
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 2600]);
    lines.X = 1000;
    addLines2Axes(Fig, lines);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Reg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

% Irreg
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & ~[trialAll.miss] & [trialAll.type] == "IRREG");

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window, th);
    legendStr = strcat("active 2 | IRREG", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1600, legendStr);
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 2600]);
    lines.X = 1000;
    addLines2Axes(Fig, lines);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Irreg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

%% Active compare
window1 = [1000, 2000];
trialAll1 = trialDatasets([trialDatasets.protocol] == "active1").trialAll;
EEGDataset1 = EEGDatasets([trialDatasets.protocol] == "active1");

window2 = [1600, 2600];
trialAll2 = trialDatasets([trialDatasets.protocol] == "active2").trialAll;
EEGDataset2 = EEGDatasets([trialDatasets.protocol] == "active2");

ICIs = unique([trialAll1.ICI]);
ICIs(ICIs == 0 | ICIs == 8) = [];
FIGPATH = strcat("..\Figs\", dateStr, "\Active 1&2 compare\");
mkdir(FIGPATH);

% Reg
for index = 1:length(ICIs)
    trials1 = trialAll1([trialAll1.ICI] == ICIs(index) & [trialAll1.type] == "REG");
    trials2 = trialAll2([trialAll2.ICI] == ICIs(index) & [trialAll2.type] == "REG");
    [~, chData(1).chMean, ~] = selectEEG(EEGDataset1, trials1, window1, th);
    [~, chData(2).chMean, ~] = selectEEG(EEGDataset2, trials2, window2, th);
    chData(1).color = "k";
    chData(2).color = "r";
    Fig = plotRawWaveMultiEEG(chData, [0, 1000], [], num2str(ICIs(index)));
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 500]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Reg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

% Irreg
for index = 1:length(ICIs)
    trials1 = trialAll1([trialAll1.ICI] == ICIs(index) & [trialAll1.type] == "IRREG");
    trials2 = trialAll2([trialAll2.ICI] == ICIs(index) & [trialAll2.type] == "IRREG");

    if isempty(trials1) || isempty(trials2)
        continue;
    end

    [~, chData(1).chMean, ~] = selectEEG(EEGDataset1, trials1, window1, th);
    [~, chData(2).chMean, ~] = selectEEG(EEGDataset2, trials2, window2, th);
    chData(1).color = "k";
    chData(2).color = "r";
    Fig = plotRawWaveMultiEEG(chData, [0, 1000], [], num2str(ICIs(index)));
    scaleAxes(Fig, "y", [-5, 5]);
    scaleAxes(Fig, "x", [0, 500]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Irreg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end