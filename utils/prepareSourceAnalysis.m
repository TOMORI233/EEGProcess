function [elec, vol, mri, leadfield] = prepareSourceAnalysis(EEGPos)
% This function loads standard head model, MRI model, and standard 10-20 
% electrode position and computes leadfield for source analysis.

load('standard_bem.mat', 'vol'); % head model
load('standard_mri.mat', 'mri');  % MRI
elec = ft_read_sens('standard_1020.elc'); % standard electrode position

% only include electrodes in standard 10-20 system
idx = ismember(upper(elec.label), upper(EEGPos.channelNames));
elec.chanpos  = elec.chanpos (idx, :);
elec.chantype = elec.chantype(idx);
elec.chanunit = elec.chanunit(idx);
elec.elecpos  = elec.elecpos (idx, :);
elec.label    = elec.label   (idx);

% unit conversion
elec = ft_convert_units(elec, 'mm');
vol  = ft_convert_units(vol,  'mm');

% leadfield check
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
title('Leadfield');
view(90, 0);

return;
end