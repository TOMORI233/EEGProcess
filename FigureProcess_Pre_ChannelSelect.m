ccc;

cd(fileparts(mfilename("fullpath")));

EEGPos = EEGPos_Neuroscan64;
run(fullfile(pwd, "config/avgConfig_Neuroscan64.m"));

% EEGPos = EEGPos_Neuracle64;
% run(fullfile(pwd, "config/avgConfig_Neuracle64.m"));

locs = EEGPos.locs;
X = -[locs.Y];
Y = [locs.X];

channels = 1:length(X);

figure("WindowState", "maximized");
mSubplot(1, 1, 1, "shape", "fill", "paddings", [0.2, 0.2, 0.01, 0.01]);
scatter(X(ismember(channels, chs2Avg)), Y(ismember(channels, chs2Avg)), 700, "red", "filled");
hold on;
scatter(X(~ismember(channels, chs2Avg)), Y(~ismember(channels, chs2Avg)), 700, "red", "LineWidth", 1);
fplot(@(t) cos(t) / 1.1, @(t) sin(t), "Color", "k", "LineWidth", 2);
arrayfun(@(x, y, z) text(gca, x, y, z.labels, "HorizontalAlignment", "center", "FontWeight", "bold", "FontSize", 12), X, Y, locs);
xlim([-1, 1]);
ylim([-1, 1]);
set(gca, "Visible", "off");

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Channel Select");
mPrint(gcf, fullfile(FIGUREPATH, 'Neuroscan 64.png'), "-dpng", "-r300");
