function source = mSourceAnalysis(data, elec, vol, leadfield)
cfg = [];
cfg.method = 'eloreta';
cfg.grid = leadfield;
cfg.headmodel = vol;
cfg.elec = elec;
cfg.senstype = 'eeg';
cfg.eloreta.lambda = 0.05; % 加入正则化防止过拟合
cfg.eloreta.keepmom = 'yes'; % 保留每个源点的时间序列
source = ft_sourceanalysis(cfg, data);

return;
end