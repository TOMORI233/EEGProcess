ccc;

%% Path
cd(fileparts(mfilename("fullpath")));
FIGUREPATH = getAbsPath("..\Figures\healthy\population\Channel Select");

%% Load
% EEGPos = EEGPos_Neuroscan64;
% run(fullfile(pwd, "config/avgConfig_Neuroscan64.m"));
% FILENAME = fullfile(FIGUREPATH, 'Neuroscan 64.png');

EEGPos = EEGPos_Neuracle64;
run(fullfile(pwd, "config/avgConfig_Neuracle64.m"));
FILENAME = fullfile(FIGUREPATH, 'Neuracle 64.png');

%% Params & conversion
locs = EEGPos.locs;
[~, ~, Th, Rd, ~] = readlocs(locs);
Th = pi / 180 * Th; % convert degrees to radians
[XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates

% remove ignored channels
channels = 1:length(locs);
idx = ~ismember(channels, getOr(EEGPos, "ignore"));
channels = channels(idx);
XTemp = XTemp(idx);
YTemp = YTemp(idx);

% flip & normalize
X = mapminmax(YTemp, -1, 1);
Y = mapminmax(XTemp, -1, 1);

%% Plot
figure("WindowState", "maximized");
mSubplot(1, 1, 1, "shape", "square-min");
scatter(X(ismember(channels, chs2Avg)), Y(ismember(channels, chs2Avg)), 700, "red", "filled");
hold on;
scatter(X(~ismember(channels, chs2Avg)), Y(~ismember(channels, chs2Avg)), 700, "red", "LineWidth", 1);
arrayfun(@(x, y, z) text(gca, x, y, z.labels, "HorizontalAlignment", "center", "FontWeight", "bold", "FontSize", 12), X, Y, locs(idx));

% fplot(@(t) 1.15 * cos(t), @(t) 1.15 * sin(t), "Color", "k", "LineWidth", 2);
% set(gca, "XLimitMethod", "tight");
% set(gca, "YLimitMethod", "tight");
% syncXY;

set(gca, "Visible", "off");
mPrint(gcf, FILENAME, "-dpng", "-r300");
