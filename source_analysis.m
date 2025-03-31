ccc;

% load("D:\Education\Lab\Projects\EEG\DATA\MAT DATA\pre\subject09\passive3\data.mat");
load("D:\Education\Lab\Projects\EEG\DATA\MAT DATA\pre\subject10\passive3\data.mat");

% 加载标准三层头模型（BEM）
load('standard_bem.mat'); % 头模型
load('standard_mri.mat');  % MRI

ft_setPath2Top;

%% 
% 导入电极位置信息
% elec = ft_read_sens('C:\Users\TOMORI\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\EEGLAB\functions\supportfiles\Standard-10-5-Cap385.sfp');
load("D:\Education\Lab\Projects\EEG\Docs\Manuscript\Communications Biology\Revision 1\Neuroscan quick-cap electrode info.mat");

EEGPos = EEGPos_Neuroscan64;
idx = ismember(upper(elec.label), upper(EEGPos.channelNames));
elec.chanpos = elec.chanpos(idx, :);
elec.chantype = elec.chantype(idx, :);
elec.chanunit = elec.chanunit(idx, :);
elec.elecpos = elec.elecpos(idx, :);
elec.label = elec.label(idx, :);

elec = ft_convert_units(elec, 'mm');
vol = ft_convert_units(vol, 'mm');

cfg = [];
cfg.grid.resolution = 10; % 网格点10mm分辨率
cfg.grid.unit = 'mm';
cfg.headmodel = vol;
cfg.elec = elec;

leadfield = ft_prepare_leadfield(cfg);

% 检查网格是否与头模型匹配
figure;
ft_plot_mesh(leadfield.pos(leadfield.inside, :));
hold on;
ft_plot_sens(elec, 'style', 'r.');
title('Leadfield 检查');
view(90, 0);

%% adjust
cfg = [];
cfg.method = 'interactive';
cfg.headshape = vol.bnd(1);
cfg.elec = elec;
elec = ft_electroderealign(cfg);

cfg = [];
cfg.grid.resolution = 10; % 网格点10mm分辨率
cfg.grid.unit = 'mm';
cfg.headmodel = vol;
cfg.elec = elec;

leadfield = ft_prepare_leadfield(cfg);

figure;
ft_plot_mesh(leadfield.pos(leadfield.inside, :));
hold on;
ft_plot_sens(elec, 'style', 'r.');
title('Leadfield 检查');
view(135, 30);

%% 
labels = intersect(EEGPos.channelNames, elec.label);
idx = ismember(EEGPos.channelNames, labels);

trialsEEG1 = trialsEEG([trialAll.ICI] == 4 & [trialAll.type] == "REG");
trialsEEG2 = trialsEEG([trialAll.ICI] == 4.06 & [trialAll.type] == "REG");

trialsEEG1 = cutData(trialsEEG1, window, [1000, 1300]);
trialsEEG2 = cutData(trialsEEG2, window, [1000, 1300]);

eeg_data1 = prepareFieldtripData(cellfun(@(x) x(idx, :), trialsEEG1, "UniformOutput", false), ...
                                 window, fs, EEGPos.channelNames(idx));
eeg_data2 = prepareFieldtripData(cellfun(@(x) x(idx, :), trialsEEG2, "UniformOutput", false), ...
                                 window, fs, EEGPos.channelNames(idx));

% 事件锁定ERP
cfg = [];
cfg.trials = find(eeg_data1.trialinfo == 1); % 按事件选取 trials
avg_data1 = ft_timelockanalysis(cfg, eeg_data1);

cfg = [];
cfg.trials = find(eeg_data2.trialinfo == 1); % 按事件选取 trials
avg_data2 = ft_timelockanalysis(cfg, eeg_data2);

% 配置反问题求解
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = 'all'; % 让它用所有时间窗
data_cov1 = ft_timelockanalysis(cfg, avg_data1);
data_cov2 = ft_timelockanalysis(cfg, avg_data2);

cfg = [];
cfg.method = 'eloreta';
cfg.grid = leadfield;
cfg.headmodel = vol;
cfg.senstype = 'eeg';
cfg.eloreta.lambda = 0.05; % 加入正则化防止过拟合
cfg.eloreta.keepmom = 'yes'; % 保留每个源点的时间序列

source1 = ft_sourceanalysis(cfg, data_cov1);
source2 = ft_sourceanalysis(cfg, data_cov2);

% 将源数据投影到标准脑
cfg = [];
cfg.parameter = 'pow';
cfg.interpmethod = 'linear';
cfg.downsample = 2;

source_interp1 = ft_sourceinterpolate(cfg, source1, mri);
source_interp2 = ft_sourceinterpolate(cfg, source2, mri);

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
% cfg.method = 'ortho';
cfg.method = 'slice';
cfg.funcolormap = 'jet';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, source_diff);
