%% plot config
set(0, "DefaultFigureWindowState", "maximized");
set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontSize", 1.1);
set(0, "DefaultAxesTitleFontWeight", "bold");

%% window config
windowBase0 = [-200, 0]; % ms
if exist("interval", "var")
    windowBase = 1000 + interval + [-200, 0]; % ms
end
windowBand = [-25, 25]; % ms

rmfcn = @mean;