ccc;

load("D:\Education\Lab\Projects\EEG\DATA\MAT DATA\pre\subject09\passive3\data.mat");
% load("D:\Education\Lab\Projects\EEG\DATA\MAT DATA\pre\subject10\passive3\data.mat");

ft_setPath2Top;

EEGPos = EEGPos_Neuroscan64;

EEGPos.channelNames([33, 43]) = [];

[elec, vol, mri, leadfield] = prepareSourceAnalysis(EEGPos);

%% 
idx = cellfun(@(x) find(ismember(upper(EEGPos.channelNames), upper(x))), elec.label);

trialsEEG1 = trialsEEG([trialAll.ICI] == 4 & [trialAll.type] == "REG");
trialsEEG2 = trialsEEG([trialAll.ICI] == 4.06 & [trialAll.type] == "REG");

trialsEEG1 = cutData(trialsEEG1, window, [1000, 1300]);
trialsEEG2 = cutData(trialsEEG2, window, [1000, 1300]);

[~, eeg_data1] = prepareFieldtripData(cellfun(@(x) x(idx, :), trialsEEG1, "UniformOutput", false), ...
                                 window, fs, EEGPos.channelNames(idx));
[~, eeg_data2] = prepareFieldtripData(cellfun(@(x) x(idx, :), trialsEEG2, "UniformOutput", false), ...
                                 window, fs, EEGPos.channelNames(idx));

source_interp1 = mSourceAnalysis(eeg_data1, vol, mri, leadfield);
source_interp2 = mSourceAnalysis(eeg_data2, vol, mri, leadfield);

source_diff = source_interp1;
source_diff.pow = source_interp2.pow - source_interp1.pow;

% 绘制3D大脑上的源定位结果
cfg = [];
cfg.method = 'ortho';
% cfg.method = 'slice';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, source_interp1);

cfg = [];
cfg.method = 'ortho';
% cfg.method = 'slice';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, source_interp2);

cfg = [];
cfg.method = 'ortho';
cfg.funcolormap = 'jet';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, source_diff);

cfg = [];
cfg.method = 'slice';
cfg.funcolormap = 'jet';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, source_diff);
