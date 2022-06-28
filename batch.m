clear; clc; close all force;

%%
DATAPATH = 'D:\Education\Lab\Projects\EEG\Data\20220628\Acquisition 03_interval0.2Behav.cdt';
EEG = loadcurry(DATAPATH);
[trials1, trials2, trials3, trials4] = EEGBehaviorProcess(EEG);
EEGDataset.data = EEG.data(1:64, :);
EEGDataset.fs = EEG.srate;
EEGDataset.channels = 1:64;

fs = 500; % downsampling

%% Passive
% window = [-1000, 3000];
% comp = mICA_EEG(EEGDataset, trials3, window, fs);
% 
% t1 = [0, 1000];
% t2 = t1 + 300;
% comp = realignIC(comp, window, t1, t2);
% ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
% plotRawWave(ICMean, [], window, "ICA", [4, 5]);
% plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
% plotTopo(comp, [8, 8], [4, 5]);
% 
% comp = reverseIC(comp, input("IC to reverse: "));
% ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
% plotRawWave(ICMean, [], window, "ICA", [4, 5]);
% plotTFA(ICMean, fs, [], window, "ICA", [4, 5]);
% plotTopo(comp, [8, 8], [4, 5]);

%% Active 2
[Fig, mAxe] = plotBehaviorEEG(trials2([trials2.isReg] == true), EEGDataset.fs, "r", "reg");
plotBehaviorEEG(trials2([trials2.isReg] == false), EEGDataset.fs, "b", "irreg", Fig, mAxe);

window = [-1000, 3000];
comp = mICA_EEG(EEGDataset, trials2, window, fs);

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