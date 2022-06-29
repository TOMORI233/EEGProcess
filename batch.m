clear; clc; close all force;

%%
DATAPATH = 'D:\Education\Lab\Projects\EEG\Data\20220628\Acquisition 03_interval0.2Behav.cdt';
EEG = loadcurry(DATAPATH);
rules = rulesConfig_20220628;
[trialsPassive, trialsActive] = EEGBehaviorProcess(EEG, rules);
EEGDataset.data = EEG.data(1:64, :);
EEGDataset.fs = EEG.srate;
EEGDataset.channels = 1:64;

fs = 500; % downsampling

%% Active
plotBehaviorEEG(trialsActive([trialsActive.type] == "REG"), EEGDataset.fs, 2200, "r", "reg");

window = [-1000, 3000];
comp = mICA_EEG(EEGDataset, trialsActive, window, fs);

chMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));

t1 = [0, 1000];
t2 = t1 + 300;
comp = realignIC(comp, window, t1, t2);
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
plotRawWave(ICMean, [], window, "ICA", [4, 5]);
plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
plotTopo(comp, [8, 8], [4, 5]);

comp = reverseIC(comp, input("IC to reverse: "));
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
plotRawWave(ICMean, [], window, "ICA", [4, 5]);
plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
plotTopo(comp, [8, 8], [4, 5]);