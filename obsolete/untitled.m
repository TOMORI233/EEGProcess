%% IRREG4-4 correct vs wrong
ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHsC = dir(fullfile(ROOTPATH, '**\active1\chMeanC.mat'));
DATAPATHsC = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHsC, "UniformOutput", false);
DATAPATHsW = dir(fullfile(ROOTPATH, '**\active1\chMeanW.mat'));
DATAPATHsW = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHsW, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHsC, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'active1\chMeanC.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio No-Gapped Attentive (Independent)");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

interval = 0;
nperm = 1e3;
alphaVal = 0.05;

run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

%% Load
window = load(DATAPATHsC{1}).window;
fs = load(DATAPATHsC{1}).fs;
dataC = cellfun(@(x) load(x).chData, DATAPATHsC, "UniformOutput", false);
dataW = cellfun(@(x) load(x).chData, DATAPATHsW, "UniformOutput", false);

rmfcn = @mean;
rms = path2func(fullfile(matlabroot, "toolbox/matlab/datafun/rms.m"));

ICI2 = 4;
Type = "IRREG";

dataC1 = cellfun(@(x) x([x.ICI] == ICI2 & [x.type] == Type), dataC, "UniformOutput", false);
dataW1 = cellfun(@(x) x([x.ICI] == ICI2 & [x.type] == Type), dataW, "UniformOutput", false);

subjectIdx0 = ~cellfun(@(x, y) isempty(x) | isempty(y), dataC1, dataW1);
dataC1 = cellfun(@(x) x.chMean, dataC1, "UniformOutput", false, "ErrorHandler", @mErrorFcn);
dataW1 = cellfun(@(x) x.chMean, dataW1, "UniformOutput", false, "ErrorHandler", @mErrorFcn);

% Normalize
dataC1 = cellfun(@(x) x ./ std(x, [], 2), dataC1, "UniformOutput", false, "ErrorHandler", @mErrorFcn);
dataW1 = cellfun(@(x) x ./ std(x, [], 2), dataW1, "UniformOutput", false, "ErrorHandler", @mErrorFcn);

%% behavior
DATAPATHs = dir(fullfile(ROOTPATH, '**\active1\behavior.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);
dataBehavior = cellfun(@(x) load(x), DATAPATHs);
ratio = zeros(length(dataBehavior), 1);
for index = 1:length(dataBehavior)
    temp = dataBehavior(index).behaviorRes;
    subjectIdx1 = [temp.ICI] == ICI2 & [temp.type] == Type;
    ratio(index) = temp(subjectIdx1).nDiff / temp(subjectIdx1).nTotal;
end

subjectIdx1 = ratio >= 0.3 & ratio <= 0.7;

%% wave of all channels
chData(1).chMean = calchMean(dataC1(subjectIdx0 & subjectIdx1));
chData(1).chErr = calchErr(dataC1(subjectIdx0 & subjectIdx1));
chData(1).color = "r";
chData(1).legend = "correct";
chData(2).chMean = calchMean(dataW1(subjectIdx0 & subjectIdx1));
chData(2).chErr = calchErr(dataW1(subjectIdx0 & subjectIdx1));
chData(2).color = "k";
chData(2).legend = "wrong";
plotRawWaveMultiEEG(chData, window, [], EEGPos);
addLines2Axes(struct("X", {0; 1000; 2000}, "color", [255 128 0] / 255, "width", 1.5));
scaleAxes("x", [900, 1500]);
scaleAxes("y", "on", "symOpt", "max");

%% average wave of selected channels
chDataAvg = chData;
chDataAvg = addfield(chDataAvg, "chMean", arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataAvg, "UniformOutput", false));
chDataAvg = rmfield(chDataAvg, "chErr");
plotRawWaveMulti(chDataAvg, window);
addLines2Axes(struct("X", {0; 1000; 2000}, "color", [255 128 0] / 255, "width", 1.5));
scaleAxes("x", [900, 1500]);
scaleAxes("y", "on", "symOpt", "max");

% determine RM window
t = linspace(window(1), window(2), size(chData(1).chMean, 2))';
tIdx = t > 1000 & t < 1500;
[~, peakTime] = maxt(chDataAvg(1).chMean(tIdx), t(tIdx));

windowChange = peakTime + [-25, 25];

%% RM
RM_changeC = cellfun(@(x) rmfcn(x, 2), ...
                     cutData(dataC1(subjectIdx0 & subjectIdx1), window, windowChange), ...
                     "UniformOutput", false);
RM_changeW = cellfun(@(x) rmfcn(x, 2), ...
                     cutData(dataW1(subjectIdx0 & subjectIdx1), window, windowChange), ...
                     "UniformOutput", false);
RM_baseC = cellfun(@(x) rmfcn(x, 2), ...
                   cutData(dataC1(subjectIdx0 & subjectIdx1), window, windowBase), ...
                   "UniformOutput", false);
RM_baseW = cellfun(@(x) rmfcn(x, 2), ...
                   cutData(dataW1(subjectIdx0 & subjectIdx1), window, windowBase), ...
                   "UniformOutput", false);

RM_changeC = cat(2, RM_changeC{:});
RM_changeW = cat(2, RM_changeW{:});
RM_baseC = cat(2, RM_baseC{:});
RM_baseW = cat(2, RM_baseW{:});

RM_delta_changeC = RM_changeC - RM_baseC;
RM_delta_changeW = RM_changeW - RM_baseW;

% statistics
statFcn = @(x, y) signrank(x, y, "tail", "both");
p_change_C_vs_base = rowFcn(@(x, y) statFcn(x, y), RM_baseC, RM_changeC, "ErrorHandler", @mErrorFcn);
p_change_W_vs_base = rowFcn(@(x, y) statFcn(x, y), RM_baseW, RM_changeW, "ErrorHandler", @mErrorFcn);
p_change_C_vs_W = rowFcn(@(x, y) statFcn(x, y), RM_delta_changeW, RM_delta_changeC, "ErrorHandler", @mErrorFcn);
p_base_C_vs_W = rowFcn(@(x, y) statFcn(x, y), RM_baseW, RM_baseC, "ErrorHandler", @mErrorFcn);

%% Scatter plot of all channels
Fig = plotScatterEEG(RM_delta_changeC, RM_delta_changeW, EEGPos, statFcn, false);
params = topoplotConfig(EEGPos, find(p_change_C_vs_W < alphaVal), 4, 16);
ax = mSubplot(Fig, 3, 4, 4, "shape", "square-min");
topoplot(mean(RM_delta_changeW - RM_delta_changeC, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";

mPrint(Fig, fullfile(FIGUREPATH, 'scatter (C vs W).jpg'), "-djpeg", "-r900");

%% Topoplot
figure;
mSubplot(2, 5, 1, "shape", "square-min");
params = topoplotConfig(EEGPos, find(p_change_W_vs_base < alphaVal), 6, 24);
topoplot(mean(RM_delta_changeW, 2), EEGPos.locs, params{:});
title("Change");

mSubplot(2, 5, 2, "shape", "square-min");
params = topoplotConfig(EEGPos, find(p_change_C_vs_base < alphaVal), 6, 24);
topoplot(mean(RM_delta_changeC, 2), EEGPos.locs, params{:});
title("No change");

mSubplot(2, 5, 3, "shape", "square-min");
params = topoplotConfig(EEGPos, find(p_change_C_vs_W < alphaVal), 6, 24);
topoplot(mean(RM_delta_changeW - RM_delta_changeC, 2), EEGPos.locs, params{:});

pos = tightPosition(gca, "IncludeLabels", true);
cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
cb.FontSize = 14;
cb.FontWeight = "bold";

scaleAxes("c", "on", "symOpt", "max", "ignoreInvisible", false);
mPrint(gcf, fullfile(FIGUREPATH, 'topo (C vs W).jpg'), "-djpeg", "-r900");

%% Example channel
run(fullfile(pwd, "config\config_plot.m"));

exampleChannel = "PO5";
idx = find(upper(EEGPos.channelNames) == exampleChannel);

% CBPT
p12 = wavePermTest(cellfun(@(x) x(idx, :), dataC1(subjectIdx0 & subjectIdx1), "UniformOutput", false), ...
                   cellfun(@(x) x(idx, :), dataW1(subjectIdx0 & subjectIdx1), "UniformOutput", false), ...
                   nperm, "Type", "ERP", "Tail", "both");

tempData = chData;
tempData = addfield(tempData, "chMean", arrayfun(@(x) x.chMean(idx, :), chData, "UniformOutput", false)');
tempData = addfield(tempData, "chErr", arrayfun(@(x) x.chErr(idx, :), chData, "UniformOutput", false)');
plotRawWaveMulti(tempData, window - 1000 - 4);
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - 4; 0;  1000 - 4}));
scaleAxes("x", [-100, 600]);
yRange = scaleAxes("y", "on", "symOpt", "max");

t = linspace(window(1), window(2), length(chData(1).chMean))';
t = t - 1000 - 4;

idx = p12 < alphaVal;
c = mixColors(tempData(1).color, tempData(2).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

%% Results of figures
% Sfigure 3
% a
[t(:), cat(1, tempData.chMean)']; % wave
