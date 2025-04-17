function [Fig2D, Fig3D] = mSourceplot(source, mri, method, titleStr)
narginchk(2, 4)

if nargin < 3
    method = 'slice';
end

if nargin < 4
    titleStr = [];
end

source_interp = mSourceInterp(source, mri);

% 2-D plot
cfg = [];
cfg.method = method;
cfg.funparameter = 'pow';
cfg.funcolormap = 'jet';
Fig2D = figure("WindowState", "maximized");
ft_sourceplot(cfg, source_interp);
if ~isempty(titleStr)
    addTitle2Fig(Fig2D, titleStr);
end

% 3-D plot
cfg = [];
cfg.method = 'surface';  % 3D 表面渲染
cfg.funparameter = 'pow';  % 指定 source 结果的数值
cfg.maskparameter = cfg.funparameter;  % 只显示有数据的区域
cfg.funcolormap = 'jet';
cfg.projmethod = 'nearest';
cfg.surffile = 'surface_white_both.mat';  % 使用 FieldTrip 自带大脑模板
Fig3D = figure("WindowState", "maximized");
ft_sourceplot(cfg, source_interp);
tar = get(Fig3D, "Children");
tar = tar(end); % Axes
sz_ratio = tar.Position(4) / tar.Position(3);
L = 0.4;
% left
ax(1) = copyobj(tar, Fig3D);
view(ax(1), -90, 0);
ax(1).Position = [0.05, 0.3, L, L * sz_ratio];
% top
ax(2) = copyobj(tar, Fig3D);
ax(2).Position = [0.3, 0.3, L, L * sz_ratio];
% right
ax(3) = copyobj(tar, Fig3D);
ax(3).Position = [0.55, 0.3, L, L * sz_ratio];
view(ax(3), 90, 0);
colormap(Fig3D, "jet");
scaleAxes(ax, "c", "symOpt", "max", "ignoreInvisible", false);
mColorbar(ax(3), "eastoutside");
delete(tar);

if ~isempty(titleStr)
    addTitle2Fig(Fig3D, titleStr);
end

return;
end