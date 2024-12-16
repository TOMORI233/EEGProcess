ccc;

% subject with good consciousness
data1 = load("..\DATA\MAT DATA - coma\temp\2024041802\151\chMean.mat"); % ding
data2 = load("..\DATA\MAT DATA - coma\temp\2024053101\151\chMean.mat"); % ding
data1_raw = load("..\DATA\MAT DATA - coma\pre\2024041802\151\data.mat"); % ding
data2_raw = load("..\DATA\MAT DATA - coma\pre\2024053101\151\data.mat"); % ding

% subject with bad consciousness
% data1 = load("..\DATA\MAT DATA - coma\temp\2024041901\151\chMean.mat"); % liu
% data2 = load("..\DATA\MAT DATA - coma\temp\2024053102\151\chMean.mat"); % liu

%% 
windowBase0 = [-200, 0];
windowOnset = [0, 250];
windowBase = [800, 1000];
windowChange = [1000, 1300];

nperm = 1e3;
alphaVal = 0.01;
fs = 1e3;

%% 
chData(1).chMean = data1.chData(3).chMean;
chData(1).color = "k";
chData(2).chMean = data2.chData(3).chMean;
chData(2).color = "k";

Fig1 = plotRawWaveMultiEEG(chData(1), data1.window, [], EEGPos_Neuracle64);
Fig2 = plotRawWaveMultiEEG(chData(2), data1.window, [], EEGPos_Neuracle64);
scaleAxes([Fig1, Fig2], "x", [-300, 2500]);
scaleAxes([Fig1, Fig2], "y", [-5, 5]);
addLines2Axes([Fig1, Fig2], struct("X", {0; 1000; 2000}, "color", [255 128 0] / 255, "width", 1.5));
addLines2Axes([Fig1, Fig2], struct("Y", 0, ...
                                   "color", "k", ...
                                   "style", "-", ...
                                   "width", 0.5), ...
                                   "Layer", "bottom");
allAxes = findobj([Fig1, Fig2], "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).TickLength = [0, 0];
    allAxes(aIndex).Title.FontSize = 12;
    allAxes(aIndex).XAxis.Visible = "off";
    allAxes(aIndex).YAxis.Visible = "off";
end
addScaleEEG(Fig1, EEGPos_Neuracle64, ' ms', ' \muV');
addScaleEEG(Fig2, EEGPos_Neuracle64, ' ms', ' \muV');
print(Fig1, '..\temp\example_coma.jpg', '-djpeg', '-r900');
print(Fig2, '..\temp\example_recover.jpg', '-djpeg', '-r900');

chData(2).color = "r";
plotRawWaveMulti(chData, data1.window);
addLines2Axes(struct("X", {0; 1000; 2000}, "color", [255 128 0] / 255, "width", 2));

chs2Ignore = 60:64;
GFP = calGFP({chData.chMean}', chs2Ignore);
t = linspace(data1.window(1), data1.window(2), length(GFP{1}));

%% RM change
RM_base = cellfun(@(x) mean(x(t >= windowBase(1) & t <= windowBase(2))), GFP);
RM_change = cellfun(@(x) max(x(t >= windowChange(1) & t <= windowChange(2))), GFP);
RM_delta_change = RM_change - RM_base;

RM_base0 = cellfun(@(x) mean(x(t >= windowBase0(1) & t <= windowBase0(2))), GFP);
RM_onset = cellfun(@(x) max(x(t >= windowOnset(1) & t <= windowOnset(2))), GFP);
RM_delta_onset = RM_onset - RM_base0;

%% Example channel
figure("WindowState", "maximized");
mSubplot(1, 1, 1);
plot(t, chData(1).chMean(58, :)', "Color", "k", "LineWidth", 2, "DisplayName", "Before");
hold on;
plot(t, chData(2).chMean(58, :)', "Color", "r", "LineWidth", 2, "DisplayName", "After");
legend;
title("O1");
addLines2Axes(struct("X", {0; 1000; 2000}, "color", [255 128 0] / 255, "width", 2));

%% 
% trialsEEG1 = cutData(data1_raw.trialsEEG([data1_raw.trialAll.ICI2] == 5), data1_raw.window, data1.window);
% trialsEEG2 = cutData(data2_raw.trialsEEG([data2_raw.trialAll.ICI2] == 5), data2_raw.window, data2.window);
% p = wavePermTest(trialsEEG1, trialsEEG2, nperm, "Tail", "both", "Type", "GFP", "chs2Ignore", chs2Ignore);
% h = fdr_bh(p, alphaVal, 'dep');
% h = double(h);
% h(h == 0) = nan;
% h(h == 1) = 0;
figure("WindowState", "maximized");
mSubplot(1, 1, 1);
plot(t, GFP{1}, "Color", "k", "LineWidth", 2, "DisplayName", "Before");
hold on;
plot(t, GFP{2}, "Color", "r", "LineWidth", 2, "DisplayName", "After");
% scatter(t, h, 50, "yellow", "filled");
legend;
addLines2Axes(struct("X", {0; 1000; 2000}, "color", [255 128 0] / 255, "width", 2));

%% Figure results
[t(:) - 1000 - 5, chData(1).chMean(58, :)', chData(2).chMean(58, :)'];

[t(:) - 1000 - 5, GFP{1}(:), GFP{2}(:)];
