ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\112\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, '112\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Variance Passive");

%% Params
colors = flip(cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false));

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuracle64.m"));

alphaVal = 0.05;

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);
load("windowChange.mat", "windowChange");

%% Wave plot
variance = unique([data{1}.var])';
variance(variance == 300) = []; % abort sigma=mu/300
variance = flip(variance);
for index = 1:length(variance)
    if isnan(variance(index))
        temp = cellfun(@(x) x(isnan([x.var])).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = 'REG 4-4.06';
        gfpData(index, 1).legend = 'REG 4-4.06';

    else
        temp = cellfun(@(x) x([x.var] == variance(index)).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = ['\sigma=\mu/', num2str(variance(index))];
        gfpData(index, 1).legend = ['\sigma=\mu/', num2str(variance(index))];
    end

    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);

    chDataAll(index, 1).chMean = calchMean(temp);
    chDataAll(index, 1).chErr = calchErr(temp);
    chDataAll(index, 1).color = colors{index};

    gfp{index} = calGFP(temp, EEGPos.ignore);
    gfp{index} = cat(1, gfp{index}{:});
    gfpData(index, 1).chMean = mean(gfp{index}, 1);
    gfpData(index, 1).chErr = SE(gfp{index}, 1);
    gfpData(index, 1).color = colors{index};
end

plotRawWaveMultiEEG(chDataAll, window, [], EEGPos_Neuracle64);
scaleAxes("x", [1000 + 4, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

%% RM computation
[RM_channels_base, ...
 RM_channels_change] = deal(cell(length(variance), 1));
for index = 1:length(variance)
    if isnan(variance(index))
        temp = cellfun(@(x) x(isnan([x.var])).chMean, data, "UniformOutput", false);
    else
        temp = cellfun(@(x) x([x.var] == variance(index)).chMean, data, "UniformOutput", false);
    end

    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    RM_channels_base{index}   = calRM(temp, window, windowBase, @(x) rmfcn(x, 2));
    RM_channels_change{index} = calRM(temp, window, windowChange, @(x) rmfcn(x, 2));

    % convert to channel-by-subject matrix
    RM_channels_base  {index} = cat(2, RM_channels_base  {index}{:});
    RM_channels_change{index} = cat(2, RM_channels_change{index}{:});
end

RM_channels_delta_change = cellfun(@(x, y) x - y, RM_channels_change, RM_channels_base, "UniformOutput", false);

% compute averaged RM across all channels
idx = ~ismember(EEGPos.channels, EEGPos.ignore);
RM_base   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_base,   "UniformOutput", false);
RM_change = cellfun(@(x) mean(x(idx, :), 1), RM_channels_change, "UniformOutput", false);
RM_delta_change = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_change, "UniformOutput", false);

%% Statistics
% test normality
% [~, p] = cellfun(@swtest, RM_change);
% if all(p < alphaVal)
%     statFcn = @(x, y) obtainArgoutN(@ttest, 2, x', y', "Tail", "left");
% else
%     statFcn = @(x, y) rowFcn(@(x1, y1) signrank(x1, y1, "tail", "left"), x, y);
% end
statFcn = @(x, y) obtainArgoutN(@ttest, [2, 4], x', y', "Tail", "both");

p_RM_channels_change_vs_base     = cellfun(@(x, y) statFcn(x, y), RM_channels_base, RM_channels_change, "UniformOutput", false);
p_RM_channels_change_vs_control1 = cellfun(@(x)    statFcn(x, RM_channels_change{1}), RM_channels_change, "UniformOutput", false);

[~, ~, ~, p_RM_channels_change_vs_base    ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_change_vs_base    , "UniformOutput", false);
[~, ~, ~, p_RM_channels_change_vs_control1] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_change_vs_control1, "UniformOutput", false);

% averaged
[p_RM_change_vs_base    , stats_RM_change_vs_base    ] = cellfun(@(x, y) statFcn(x, y), RM_base, RM_change);
[p_RM_change_vs_control1, stats_RM_change_vs_control1] = cellfun(@(x) statFcn(x, RM_delta_change{1}), RM_delta_change);
[p_RM_change_vs_control2, stats_RM_change_vs_control2] = cellfun(@(x) statFcn(x, RM_delta_change{end}), RM_delta_change);

d_RM_change_vs_base = cellfun(@(x, y) cohensD(x, y), RM_base, RM_change);
d_RM_change_vs_control1 = cellfun(@(x) cohensD(RM_delta_change{1}, x), RM_delta_change);
d_RM_change_vs_control2 = cellfun(@(x) cohensD(RM_delta_change{end}, x), RM_delta_change);

%% Tunning plot
variance(isnan(variance)) = 0;

FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
X = 1:length(variance);
Y = cellfun(@mean, RM_delta_change);
E = cellfun(@SE, RM_delta_change);
errorbar(X, Y, E, "Color", "r", "LineWidth", 2);
hold on;
scatter(X(p_RM_change_vs_base < alphaVal), Y(p_RM_change_vs_base < alphaVal) - E(p_RM_change_vs_base < alphaVal) - 0.02, 80, "Marker", "*", "MarkerEdgeColor", "k");
scatter(X(p_RM_change_vs_control1 < alphaVal), Y(p_RM_change_vs_control1 < alphaVal) + E(p_RM_change_vs_control1 < alphaVal) + 0.02, 60, "Marker", "o", "MarkerEdgeColor", "k");
xticks(1:length(variance));
xlim([0, length(variance)] + 0.5);
temp = arrayfun(@(x) ['\mu/', num2str(x)], variance, "UniformOutput", false);
temp{1} = '0';
xticklabels(temp);
xlabel("Insert ICI number");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

%% Topoplot of RM for all conditions
FigTopo = figure;
for index = 1:length(variance)
    mSubplot(2, 5, index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_change_vs_base{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_change{index}, 2), EEGPos.locs, params{:});
    
    mSubplot(2, 5, index + 5, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_change_vs_control1{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_change{index}, 2), EEGPos.locs, params{:});
end
cRange = scaleAxes("c", "symOpt", "max", "ignoreInvisible", false);
set(findobj(FigTopo, "Type", "Patch"), "FaceColor", "w");
set(FigTopo, "Color", "w");
temp = floor(max(cRange) * 100) / 100;
exportgraphics(FigTopo, fullfile(FIGUREPATH, 'topo.jpg'), "Resolution", 900);
exportcolorbar([-temp, temp], fullfile(FIGUREPATH, 'topo colorbar.jpg'));

%% Example channel
run(fullfile(pwd, "config\config_plot.m"));

exampleChannel = "POZ";
idx = find(upper(EEGPos.channelNames) == exampleChannel);

chData = chDataAll;
chData = addfield(chData, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataAll, "UniformOutput", false)');
chData = addfield(chData, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataAll, "UniformOutput", false)');
plotRawWaveMulti(chData, window - 1000 - 4);
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - 4; 0;  1000 - 4}));
scaleAxes("x", [-100, 600]);
yRange = scaleAxes("y", "on", "symOpt", "max");

t = linspace(window(1), window(2), length(chData(1).chMean))';
t = t - 1000 - 4;

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*')); ...
          fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res variance (', char(area), ').mat'], ...
     "fs", ...
     "variance", ...
     "chs2Avg", ...
     params{:});

%% Results of figures
% Figure 3
% h
t = linspace(window(1), window(2), length(chData(1).chMean))' - 1000;
temp = arrayfun(@(x) [x.chMean(:), x.chErr(:)], chData(end:-1:1), "UniformOutput", false);
[t, cat(2, temp{:})];

% i
[Y(:), E(:)];
