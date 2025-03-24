ccc;

% 导入电极位置信息
elec = ft_read_sens('C:\Users\TOMORI\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\EEGLAB\functions\supportfiles\Standard-10-5-Cap385.sfp');
EEGPos = EEGPos_Neuroscan64;
idx = ismember(elec.label, EEGPos.channelNames);
elec.chanpos = elec.chanpos(idx, :);
elec.chantype = elec.chantype(idx, :);
elec.chanunit = elec.chanunit(idx, :);
elec.elecpos = elec.elecpos(idx, :);
elec.label = elec.label(idx, :);

% 检查导入结果
figure;
ft_plot_sens(elec);
title('电极位置检查');

% 加载标准三层头模型（BEM）
load('standard_bem.mat'); % 头模型
load('standard_mri.mat');  % MRI

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
view(135, 30);

%% 
% 事件锁定ERP
cfg = [];
cfg.trials = find(eeg_data.trialinfo == 1); % 按事件选取 trials
avg_data = ft_timelockanalysis(cfg, eeg_data);

% 配置反问题求解
cfg = [];
cfg.method = 'eloreta'; % sLORETA 算法
cfg.grid = leadfield;
cfg.headmodel = vol;

source = ft_sourceanalysis(cfg, avg_data);
