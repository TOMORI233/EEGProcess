clearvars -except data;
clc; close all force;
addpath(genpath(fileparts(mfilename("fullpath"))));
run("EEGPosConfig.m");

%% Parameter settings
CDTPATH = "D:\Education\Lab\Projects\EEG\Data\CDT\20220630\Acquisition passive1.cdt";
window = [-1000, 3000];
opts.fhp = 0.5;
opts.flp = 100;

% specify protocol here
trialsData = data(3);
pID = 3;

%% Load data
EEG = loadcurry(char(CDTPATH));
EEGDataset.protocol = "passive1";
EEGDataset.data = EEG.data(1:end - 1, :);
EEGDataset.fs = EEG.srate;
EEGDataset.channels = 1:size(EEGDataset.data, 1);
EEGDataset.event = EEG.event;
EEGDataset = EEGFilter(EEGDataset, opts.fhp, opts.flp);
fs0 = EEGDataset.fs;

trialAll = EEGBehaviorProcess(trialsData, EEGDataset, pID);

%% ERP
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
%     plotLayoutEEG(Fig, 0.3);
end