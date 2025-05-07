ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\111\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, '111\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Insert Passive");

%% Params
colors = [{[0.5, 0.5, 0.5]}; ...
          flip(generateGradientColors(3, 'b', 0.2)); ...
          generateGradientColors(3, 'r', 0.2); ...
          {[0, 0, 0]}];

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
insertN = unique([data{1}.insertN])';
for index = 1:length(insertN)
    if isnan(insertN(index))
        temp = cellfun(@(x) x(isnan([x.insertN])).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = 'REG 4-4.06';
        gfpData(index, 1).legend = 'REG 4-4.06';
    else
        temp = cellfun(@(x) x([x.insertN] == insertN(index)).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = num2str(insertN(index));
        gfpData(index, 1).legend = num2str(insertN(index));
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
scaleAxes("x", [1000 + 4.06, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

%% RM computation
[RM_channels_base, ...
 RM_channels_change] = deal(cell(length(insertN), 1));
for index = 1:length(insertN)
    if isnan(insertN(index))
        temp = cellfun(@(x) x(isnan([x.insertN])).chMean, data, "UniformOutput", false);
    else
        temp = cellfun(@(x) x([x.insertN] == insertN(index)).chMean, data, "UniformOutput", false);
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
%     statFcn = @(x, y) obtainArgoutN(@ttest, [2, 4], x', y', "Tail", "both");
% else
%     statFcn = @(x, y) obtainArgoutN(@mSignrank, [1, 3, 4], x', y', "tail", "both");
% end
statFcn = @(x, y) obtainArgoutN(@ttest, [2, 4], x', y', "Tail", "both");

p_RM_channels_change_vs_base     = cellfun(@(x, y) statFcn(x, y), RM_channels_base, RM_channels_change, "UniformOutput", false);
p_RM_channels_change_vs_control1 = cellfun(@(x)    statFcn(RM_channels_change{1}, x), RM_channels_change, "UniformOutput", false);
p_RM_channels_change_vs_control2 = cellfun(@(x)    statFcn(x, RM_channels_change{end}), RM_channels_change, "UniformOutput", false);

[~, ~, ~, p_RM_channels_change_vs_base    ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_change_vs_base    , "UniformOutput", false);
[~, ~, ~, p_RM_channels_change_vs_control1] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_change_vs_control1, "UniformOutput", false);
[~, ~, ~, p_RM_channels_change_vs_control2] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_change_vs_control2, "UniformOutput", false);

% averaged
[p_RM_change_vs_base    , stats_RM_change_vs_base    ] = cellfun(@(x, y) statFcn(x, y), RM_base, RM_change);
[p_RM_change_vs_control1, stats_RM_change_vs_control1] = cellfun(@(x) statFcn(RM_delta_change{1}, x), RM_delta_change);
[p_RM_change_vs_control2, stats_RM_change_vs_control2] = cellfun(@(x) statFcn(x, RM_delta_change{end}), RM_delta_change);

d_RM_change_vs_base = cellfun(@(x, y) cohensD(x, y), RM_base, RM_change);
d_RM_change_vs_control1 = cellfun(@(x) cohensD(RM_delta_change{1}, x), RM_delta_change);
d_RM_change_vs_control2 = cellfun(@(x) cohensD(RM_delta_change{end}, x), RM_delta_change);

%% Bayesian t-test
bf10_RM_change_vs_base = cellfun(@(x, y) bf.ttest(x, y), RM_base, RM_change);

%% Tunning plot
% compute averaged RM across all channels
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
X = 1:length(insertN);
Y = cellfun(@mean, RM_delta_change);
E = cellfun(@SE, RM_delta_change);
errorbar(X, Y, E, "Color", "r", "LineWidth", 2);
hold on;
scatter(X(p_RM_change_vs_base < alphaVal), Y(p_RM_change_vs_base < alphaVal) - E(p_RM_change_vs_base < alphaVal) - 0.02, 80, "Marker", "*", "MarkerEdgeColor", "k");
scatter(X(p_RM_change_vs_control2 < alphaVal), Y(p_RM_change_vs_control2 < alphaVal) + E(p_RM_change_vs_control2 < alphaVal) + 0.02, 60, "Marker", "o", "MarkerEdgeColor", "k");
xticks(1:length(insertN));
xlim([0, length(insertN)] + 0.5);
labels = cellstr(num2str(insertN));
labels{end} = 'REG_{4-4.06}';
labels = char(labels);
xticklabels(labels);
xlabel("Insert click number");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

%% Topoplot of RM for all conditions
FigTopo = figure;
for index = 1:length(insertN)
    mSubplot(2, length(insertN), index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_change_vs_base{index} < alphaVal), 0, 20);
    topoplot(mean(RM_channels_delta_change{index}, 2), EEGPos.locs, params{:});

    mSubplot(2, length(insertN), index + length(insertN), "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_change_vs_control2{index} < alphaVal), 0, 20);
    topoplot(mean(RM_channels_delta_change{index}, 2), EEGPos.locs, params{:});
end
cRange = scaleAxes("c", "symOpt", "max", "ignoreInvisible", false);
set(findobj(gcf, "Type", "Patch"), "FaceColor", "w");
set(FigTopo, "Color", "w");
temp = floor(max(cRange) * 100) / 100;
exportgraphics(gcf, fullfile(FIGUREPATH, 'topo.jpg'), "Resolution", 900);
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
save(['..\DATA\MAT DATA\figure\Res insert (', char(area), ').mat'], ...
     "fs", ...
     "insertN", ...
     params{:});

%% Results of figures
% Figure 2
% b
temp = arrayfun(@(x) [x.chMean(:), x.chErr(:)], chData, "UniformOutput", false);
[t, cat(2, temp{:})];
