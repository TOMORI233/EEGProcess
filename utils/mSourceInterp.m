function source_interp = mSourceInterp(source, mri)
% 将源数据投影到标准脑
cfg = [];
cfg.parameter = 'pow';
cfg.interpmethod = 'linear';
cfg.downsample = 2;
source_interp = ft_sourceinterpolate(cfg, source, mri);

return;
end