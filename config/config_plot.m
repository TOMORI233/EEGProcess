%% plot config
set(0, "DefaultFigureWindowState", "maximized");
set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontSize", 1.1);
set(0, "DefaultAxesTitleFontWeight", "bold");

%% window config
if exist("interval", "var")
    windowBase = 1000 + interval + [-200, 0]; % ms, change baseline
end

windowBase0  = [-500, -300]; % ms, onset baseline
windowOnset  = [0, 250]; % ms

windowBand = [-25, 25]; % ms

%% RM computation
% rmfcn = @mean;
rmfcn = path2func(fullfile(matlabroot, "toolbox/matlab/datafun/rms.m"));