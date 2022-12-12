clear; clc;
close all force;
addpath(genpath(fileparts(mfilename("fullpath"))));

%% Parameter settings
ROOTPATH = "D:\Education\Lab\Projects\EEG\Data\CDT\20220906\Subject1";
th = 0.2;
yscale = [-10, 10];

temp = string(split(ROOTPATH, "\"));
dateStr = strcat(temp(end - 1), "-", temp(end));

%% Load data
opts.fhp = 0.5;
opts.flp = 100;
opts.save = false;
opts.rules = rulesConfig();
[EEGDatasets, trialDatasets] = EEGPreprocess(ROOTPATH, opts);
fs0 = EEGDatasets(1).fs;
warning off;


%% passive1
window = [0, 1000];
trialAll = trialDatasets([trialDatasets.protocol] == "passive1").trialAll;
EEGDataset = EEGDatasets([trialDatasets.protocol] == "passive1");
fs = EEGDataset.fs;
ICIs = unique([trialAll.ICI]);
FIGPATH = strcat("..\Figs\", dateStr, "\Synchronization\");
mkdir(FIGPATH);

% Reg
for index = 1:length(ICIs)

    trials = trialAll([trialAll.ICI] == ICIs(index) & [trialAll.type] == "REG");
    [trialsEEG, ~, ~] = selectEEG(EEGDataset, trials, window, th);

    t = linspace(window(1), window(2), size(trialsEEG{1}, 2));

    if isempty(trials)
        continue;
    end

    % FFT
    [~, tIdx] = findWithinInterval(t, window);
    [ff, PMean]  = trialsECOGFFT(trialsEEG, fs, tIdx, [], "magnitude");

    legendStr = strcat("decoding | REG ", string(num2str(ICIs(index))));
    Fig = plotRawWaveEEG(PMean, [], [ff(1), ff(end)], [], legendStr);
    scaleAxes(Fig, "y", [], [0 300]);
    scaleAxes(Fig, "x", [0, 100]);
    setAxes(Fig, "Visible", "off");
    plotLayoutEEG(Fig, 0.3);
    print(Fig, strcat(FIGPATH, "Reg_", strrep(num2str(ICIs(index)), '.', '_')), "-djpeg", "-r300");
end
