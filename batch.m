clear; clc; close all force;
addpath(genpath(fileparts(mfilename("fullpath"))));

%% Parameter settings
ROOTPATH = "D:\Education\Lab\Projects\EEG\Data\CDT\20220630";
fs = 500; % Hz, for downsampling
window = [-1000, 3000];
run("EEGPosConfig.m");

%% Load data
opts.fhp = 1;
[EEGDatasets, trialDatasets] = EEGPreprocess(ROOTPATH, opts);
fs0 = EEGDatasets(1).fs;

%% Behavior process
trialsActive1 = trialDatasets([trialDatasets.protocol] == "active1").trialAll;
trialsActive2 = trialDatasets([trialDatasets.protocol] == "active2").trialAll;

[FigB1, mAxeB1] = plotBehaviorEEG(trialsActive1([trialsActive1.type] == "REG"), fs0, "r", "Reg Interval 0");
plotBehaviorEEG(trialsActive2([trialsActive2.type] == "REG"), fs0, "b", "Reg Interval 600", FigB1, mAxeB1);

[FigB2, mAxeB2] = plotBehaviorEEG(trialsActive1([trialsActive1.type] == "IRREG"), fs0, "r", "Irreg Interval 0");
plotBehaviorEEG(trialsActive2([trialsActive2.type] == "IRREG"), fs0, "b", "Irreg Interval 600", FigB2, mAxeB2);

%% Passive 1
trialAll = trialDatasets(1).trialAll;
EEGDataset = EEGDatasets(1);
ICIs = unique([trialAll.ICI]);
    
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & ([trialAll.type] == "REG" | [trialAll.type] == "PT"));

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window);
    legendStr = strcat("passive 1 | ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1000, legendStr);
    scaleAxes(Fig, "y", [-10, 10]);
    scaleAxes(Fig, "x", [0, 2000]);
%     setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
%     print(Fig, strcat("..\Figs\Irreg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

%% Passive 2
trialAll = trialDatasets(2).trialAll;
EEGDataset = EEGDatasets(2);
ICIs = unique([trialAll.ICI]);
    
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & [trialAll.type] == "REG");

    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window);
    legendStr = strcat("passive 2 | ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1600, legendStr);
    scaleAxes(Fig, "y", [-10, 10]);
    scaleAxes(Fig, "x", [0, 2000]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
%     print(Fig, strcat("..\Figs\Irreg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end

%% Active 1
trialAll = trialDatasets(3).trialAll;
EEGDataset = EEGDatasets(3);
ICIs = unique([trialAll.ICI]);
    
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & [trialAll.correct] & ([trialAll.type] == "REG" | [trialAll.type] == "PT"));
    
    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window);
    legendStr = strcat("active 1 | ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1000, legendStr);
    scaleAxes(Fig, "y", [-10, 10]);
    scaleAxes(Fig, "x", [0, 2000]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
end

%% Active 2
trialAll = trialDatasets(4).trialAll;
EEGDataset = EEGDatasets(4);
ICIs = unique([trialAll.ICI]);
    
for index = 1:length(ICIs)
    trials = trialAll([trialAll.ICI] == ICIs(index) & [trialAll.correct] & [trialAll.type] == "REG");
    
    if isempty(trials)
        continue;
    end

    [~, chMean, ~] = selectEEG(EEGDataset, trials, window);
    legendStr = strcat("active 2 | ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(chMean, [], window, 1600, legendStr);
    scaleAxes(Fig, "y", [-10, 10]);
    scaleAxes(Fig, "x", [0, 2000]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
end