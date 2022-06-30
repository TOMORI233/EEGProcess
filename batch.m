clear; clc; close all force;

%% Parameter settings
ROOTPATH = 'D:\Education\Lab\Projects\EEG\Data\20220630';
fs = 500; % Hz, for downsampling

%% Load data
files = dir(ROOTPATH);

for index = 1:length(files)
    [~, filename, ext] = fileparts(files(index).name);
    
    if strcmp(ext, ".cdt")
        temp = split(filename, " ");
        EEGData = loadcurry(fullfile(ROOTPATH, files(index).name));

        switch temp{2}
            case 'passive1'
                EEG1 = EEGData;
            case 'passive2'
                EEG2 = EEGData;
            case 'active1'
                EEG3 = EEGData;
            case 'active2'
                EEG4 = EEGData;
            case 'decoding'
                EEG5 = EEGData;
            otherwise
                error("Invalid file name for *.cdt");
        end

    end

end

load(fullfile(ROOTPATH, string(what(ROOTPATH).mat)));
fs0 = EEGData.srate;

%% Behavior process
for index = 1:5
    eval(['trials', num2str(index), ' = EEGBehaviorProcess2(data', num2str(index), ', EEG', num2str(index), ', ', num2str(index), ');']);
end

[Fig1, mAxe1] = plotBehaviorEEG(trials3([trials3.type] == "REG"), fs0, "r", "Reg Interval 0");
plotBehaviorEEG(trials4([trials4.type] == "REG"), fs0, "b", "Reg Interval 600", Fig1, mAxe1);

[Fig2, mAxe2] = plotBehaviorEEG(trials3([trials3.type] == "IRREG"), fs0, "r", "Irreg Interval 0");
plotBehaviorEEG(trials4([trials4.type] == "IRREG"), fs0, "b", "Irreg Interval 600", Fig2, mAxe2);

%% passive 1
window = [-1000, 3000];
chData = [];
ICIs = unique([trials1.ICI]);
colors = generateColorGrad(length(ICIs), 'rgb');
EEGDataset.data = EEG1.data(1:end - 1, :);
EEGDataset.fs = fs0;
EEGDataset.channels = 1:(size(EEG1.data, 1) - 1);
EEGDataset = EEGFilter(EEGDataset);
% comp = mICA_EEG(EEGDataset, trials1, window, fs);

for index = 1:length(ICIs)
    trials = trials1([trials1.ICI] == ICIs(index));
%     chData(index).chMean = comp.trial{[trials1.ICI] == ICIs(index)};
    [~, chData(index).chMean, ~] = selectEEG(EEGDataset, trials, window);
    chData(index).color = colors{index};
    chData(index).legend = num2str(ICIs(index));
end

Fig = plotRawWaveMulti(chData, window, "passive 1", [1, 2], [50, 51]);
scaleAxes(Fig, "y");
scaleAxes(Fig, "x", [800, 1600]);

%% passive 2
window = [-1000, 3000];
chData = [];
ICIs = unique([trials2.ICI]);
colors = generateColorGrad(length(ICIs), 'rgb');
EEGDataset.data = EEG2.data(1:end - 1, :);
EEGDataset.fs = fs0;
EEGDataset.channels = 1:(size(EEG2.data, 1) - 1);
EEGDataset = EEGFilter(EEGDataset);

for index = 1:length(ICIs)
    trials = trials2([trials2.ICI] == ICIs(index));
    [~, chData(index).chMean, ~] = selectEEG(EEGDataset, trials, window);
    chData(index).color = colors{index};
    chData(index).legend = string(num2str(ICIs(index)));
end

Fig = plotRawWaveMulti(chData, window, "passive 2", [4, 4], 50);
scaleAxes(Fig, "y", [-10, 10]);
scaleAxes(Fig, "x", [0, 3000]);

%% Active
window = [-1000, 3000];