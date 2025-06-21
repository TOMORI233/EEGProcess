ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs1 = dir(fullfile(ROOTPATH, '**\passive3\chMean.mat'));
DATAPATHs2 = dir(fullfile(ROOTPATH, '**\passive1\chMean.mat'));
DATAPATHs1 = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs1, "UniformOutput", false);
DATAPATHs2 = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs2, "UniformOutput", false);

[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 2), DATAPATHs1, "UniformOutput", false);

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Irreg ratio vs length");

%% Params
nperm = 1e3;
alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

chIdx = ~ismember(EEGPos.channels, EEGPos.ignore);

load("windowChange.mat", "windowChange");

%% Load
window = load(DATAPATHs1{1}).window;
fs = load(DATAPATHs1{1}).fs;
data1 = cellfun(@(x) load(x).chData, DATAPATHs1, "UniformOutput", false);
data2 = cellfun(@(x) load(x).chData, DATAPATHs2, "UniformOutput", false);

%% Wave, GFP, RM computation
% IRREG 4-4.06
% Protocol - ratio
temp = cellfun(@(x) x([x.ICI] == 4.06 & [x.type] == "IRREG").chMean, data1, "UniformOutput", false);
data1 = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
data1 = cellfun(@(x) insertRows(x(chIdx, :), EEGPos.ignore, 0), data1, "UniformOutput", false);
RM_channels_base1 = calRM(data1, window, windowBase, @(x) rmfcn(x, 2));
RM_channels_change1 = calRM(data1, window, windowChange, @(x) rmfcn(x, 2));
RM_channels_delta_change1 = cellfun(@(x, y) x - y, RM_channels_change1, RM_channels_base1, "UniformOutput", false);

chData(1).chMean = calchMean(data1);
chData(1).chErr = calchErr(data1);
chData(1).color = 'b';
chData(1).legend = 'Ratio';

gfpIRREG1 = calGFP(data1, EEGPos.ignore);
gfpData(1).chMean = calchMean(gfpIRREG1);
gfpData(1).chErr = calchErr(gfpIRREG1);
gfpData(1).color = 'b';
gfpData(1).legend = 'Ratio';

% Protocol - length
temp = cellfun(@(x) x([x.ICI] == 4.06 & [x.type] == "IRREG").chMean, data2, "UniformOutput", false);
data2 = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
data2 = cellfun(@(x) insertRows(x(chIdx, :), EEGPos.ignore, 0), data2, "UniformOutput", false);
RM_channels_base2 = calRM(data2, window, windowBase, @(x) rmfcn(x, 2));
RM_channels_change2 = calRM(data2, window, windowChange, @(x) rmfcn(x, 2));
RM_channels_delta_change2 = cellfun(@(x, y) x - y, RM_channels_change2, RM_channels_base2, "UniformOutput", false);

chData(2).chMean = calchMean(data2);
chData(2).chErr = calchErr(data2);
chData(2).color = 'r';
chData(2).legend = 'Length';

gfpIRREG2 = calGFP(data2, EEGPos.ignore);
gfpData(2).chMean = calchMean(gfpIRREG2);
gfpData(2).chErr = calchErr(gfpIRREG2);
gfpData(2).color = 'r';
gfpData(2).legend = 'Length';

% RM - average
RM_delta_change1 = cellfun(@(x) mean(x(chIdx, :), 1), RM_channels_delta_change1);
RM_delta_change2 = cellfun(@(x) mean(x(chIdx, :), 1), RM_channels_delta_change2);

%% Statistics
[p, stats, efsz, bf10] = mstat.ttest(RM_delta_change1, RM_delta_change2);

p_channels = cellfun(@mstat.ttest, changeCellRowNum(RM_channels_delta_change1), changeCellRowNum(RM_channels_delta_change2));

try
    load("stat_IRREG_ratio_vs_length.mat", "statPerm");
catch ME
    cfg = [];
    cfg.minnbchan = 1;
    cfg.neighbours = EEGPos.neighbours;
    statPerm = CBPT(cfg, data1, data2);

    save("stat_IRREG_ratio_vs_length.mat", "statPerm");
end

statPermGFP = CBPT([], gfpIRREG1, gfpIRREG2);

%% Wave plot
t = linspace(window(1), window(2), size(gfpIRREG1{1}, 2));

plotRawWaveMulti(gfpData, window);
addLines2Axes(struct("X", {0; 1000; 2000}));

plotRawWaveMulti(chData, window);
scaleAxes("x", [800, 1600]);
scaleAxes("y", "on", "autoTh", [0, 1]);
addLines2Axes(struct("X", {0; 1000; 2000}));

plotRawWaveMultiEEG(chData, window, [], EEGPos);
mSubplot(4, 4, 4, "shape", "square-min");
imagesc("XData", t, "YData", EEGPos.channels, "CData", abs(statPerm.stat));
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
colormap(slanCM('YlOrRd'));
mColorbar("Interval", -0.05);
scaleAxes(gca, "c", [0, inf]);
addLines2Axes(struct("X", {0; 1000; 2000}));

chSig = EEGPos.channels(p_channels < alphaVal);
plotRawWaveMulti(chData, window, [], autoPlotSize(numel(chSig)), chSig);
addLines2Axes(struct("X", {0; 1000; 2000}));

%% Topo
figure;
mSubplot(1, 3, 1);
params = topoplotConfig(EEGPos, [], 0, 30);
topoplot(calchMean(RM_channels_delta_change1), EEGPos.locs, params{:});
title("Ratio");

mSubplot(1, 3, 2);
params = topoplotConfig(EEGPos, [], 0, 30);
topoplot(calchMean(RM_channels_delta_change2), EEGPos.locs, params{:});
title("Length");

mSubplot(1, 3, 3);
params = topoplotConfig(EEGPos, find(p_channels < alphaVal), 0, 30);
topoplot(calchMean(RM_channels_delta_change2) - calchMean(RM_channels_delta_change1), EEGPos.locs, params{:});
title("Diff");
mColorbar("Width", 0.03);

scaleAxes("c", "ignoreInvisible", false);