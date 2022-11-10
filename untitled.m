%% ICA
window  = [-1000, 2000];

EEGDataset = EEGDatasets(3);
trialAll = trialDatasets(3).trialAll;
comp0 = mICA_EEG(EEGDataset, trialAll, window, EEGDataset.fs);

[trialsEEG1, ~, ~, sampleinfo1] = selectEEG(EEGDatasets(1), trialDatasets(1).trialAll, window);
[trialsEEG3, ~, ~, sampleinfo3] = selectEEG(EEGDatasets(3), trialDatasets(3).trialAll, window);

comp2 = mICA2([trialsEEG1; trialsEEG3], [sampleinfo1; sampleinfo3], EEGDatasets(1).channels, window, EEGDatasets(1).fs, EEGDatasets(1).fs);

t1 = [-2000, -1500, -1000, -500, 0];
t2 = t1 + 200;
% comp = realignIC(comp0, window, t1, t2);
comp = realignIC(comp2, window);
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
ICStd = cell2mat(cellfun(@(x) std(x, [], 1), changeCellRowNum(comp.trial), "UniformOutput", false));
Fig1(1) = plotRawWave(ICMean, ICStd, window, "ICA");
Fig1(2) = plotTFA(ICMean, EEGDataset.fs, [], window, "ICA");
Fig1(3) = plotTopoEEG(comp);
scaleAxes(Fig1(1), "y", [-0.2, 0.2]);
scaleAxes(Fig1(2), "c", [0, 0.2]);

% reconstruct
trialsEEG = selectEEG(EEGDataset, trialAll([trialAll.ICI] == 4.06), window);
[~, chMean] = reconstructData(trialsEEG, comp2, 1:32);
plotRawWaveEEG(chMean, [], window, 1000);

comp = reverseIC(comp, input("Input ICs to reverse: "));
ICMean = cell2mat(cellfun(@mean, changeCellRowNum(comp.trial), "UniformOutput", false));
plotRawWave(ICMean, [], window, "ICA");
plotTopoEEG(comp, [1, 1], 1);