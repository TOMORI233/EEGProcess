cfg = [];
cfg.parameter = 'pow';
cfg.interpmethod = 'linear';
cfg.downsample = 1;
cfg.coordsys = 'mni';
source_diff.coordsys = 'mni';
source_interp = ft_sourceinterpolate(cfg, source_diff, atlas);

cfg = [];
cfg.parameter = 'pow';
cfg.method = 'mean';  % 或 'max', 'sum', 视分析目的而定
parcel = ft_sourceparcellate(cfg, source_interp, atlas);

dummy=atlas;
for i=1:length(parcel.pow)
      dummy.tissue(find(dummy.tissue==i))=parcel.pow(i);
end

source_interp.parcel=dummy.tissue;
source_interp.coordsys = 'mni';
cfg=[];
cfg.method = 'ortho';
cfg.funparameter = 'parcel';
cfg.funcolormap    = 'jet';
cfg.renderer = 'zbuffer';
cfg.location = [-42 -20 6];
cfg.atlas = atlas;
ft_sourceplot(cfg,source_interp);