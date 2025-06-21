ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\active1\chMeanAll.mat')); % all trials
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'active1\chMeanAll.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio No-Gapped Attentive (Independent)");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

nperm = 1e3;
alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

% Independent
load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");
data = data(subjectIdxA1); % all

%% Wave plot
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
gfpREG = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).chErr = calchErr(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(ICIsREG(1)), '-', num2str(ICIsREG(dIndex))];

    gfpREG{dIndex} = calGFP(temp, EEGPos.ignore);
    gfpREG{dIndex} = cat(1, gfpREG{dIndex}{:});
    gfpDataREG(dIndex, 1).chMean = mean(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).chErr = SE(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).color = colors{dIndex};
    gfpDataREG(dIndex, 1).legend = ['REG ', num2str(ICIsREG(1)), '-', num2str(ICIsREG(dIndex))];
end

plotRawWaveMultiEEG(chDataREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [1000 + ICIsREG(1), 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));

% IRREG
ICIsIRREG = unique([data{1}([data{1}.type] == "IRREG").ICI])';
ICIsIRREG = ICIsIRREG(1:end - 1);
gfpIRREG = cell(length(ICIsIRREG), 1);
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);

    chDataIRREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataIRREG_All(dIndex, 1).chErr = calchErr(temp);
    chDataIRREG_All(dIndex, 1).color = colors{dIndex};
    chDataIRREG_All(dIndex, 1).legend = ['IRREG ', num2str(ICIsIRREG(1)), '-', num2str(ICIsIRREG(dIndex))];

    gfpIRREG{dIndex} = calGFP(temp, EEGPos.ignore);
    gfpIRREG{dIndex} = cat(1, gfpIRREG{dIndex}{:});
    gfpDataIRREG(dIndex, 1).chMean = mean(gfpIRREG{dIndex}, 1);
    gfpDataIRREG(dIndex, 1).chErr = SE(gfpIRREG{dIndex}, 1);
    gfpDataIRREG(dIndex, 1).color = colors{dIndex};
    gfpDataIRREG(dIndex, 1).legend = ['IRREG ', num2str(ICIsIRREG(1)), '-', num2str(ICIsIRREG(dIndex))];
end

% PT
freqs = sort(unique([data{1}([data{1}.type] == "PT").freq]), 'descend')';
gfpPT = cell(length(freqs), 1);
for fIndex = 1:length(freqs)
    temp = cellfun(@(x) x([x.freq] == freqs(fIndex) & [x.type] == "PT").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    chDataPT_All(fIndex, 1).chMean = calchMean(temp);
    chDataPT_All(fIndex, 1).chErr = calchErr(temp);
    chDataPT_All(fIndex, 1).color = colors{fIndex};
    chDataPT_All(fIndex, 1).legend = ['PT ', num2str(freqs(1)), '-', num2str(freqs(fIndex))];

    gfpPT{fIndex} = calGFP(temp, EEGPos.ignore);
    gfpPT{fIndex} = cat(1, gfpPT{fIndex}{:});
    gfpDataPT(fIndex, 1).chMean = mean(gfpPT{fIndex}, 1);
    gfpDataPT(fIndex, 1).chErr = SE(gfpPT{fIndex}, 1);
    gfpDataPT(fIndex, 1).color = colors{fIndex};
    gfpDataPT(fIndex, 1).legend = ['PT ', num2str(freqs(1)), '-', num2str(freqs(fIndex))];
end

plotRawWaveMultiEEG(chDataPT_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [900, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

%% Determine window for change response by GFP
p_gfp_REG4o06_vs_REG4 = wavePermTest(gfpREG{1}, gfpREG{end}, "Tail", "left");
t = linspace(window(1), window(2), length(p_gfp_REG4o06_vs_REG4))';
plotRawWaveMulti(gfpDataREG([1, end]), window);
xlabel("Time from onset (ms)");
ylabel("GFP (\muV)");
scaleAxes("x", [1000, 1600]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
yRange = get(gca, "YLim");
h = bar(t(p_gfp_REG4o06_vs_REG4 < alphaVal), ones(sum(p_gfp_REG4o06_vs_REG4 < alphaVal), 1) * yRange(2), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
setLegendOff(h);

p_gfp_PT250_vs_PT246 = wavePermTest(gfpPT{1}, gfpPT{end}, "Tail", "left");
plotRawWaveMulti(gfpDataPT, window);
xlabel("Time from onset (ms)");
ylabel("GFP (\muV)");
scaleAxes("x", [1000, 1600]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000; 2000}));
yRange = get(gca, "YLim");
h = bar(t(p_gfp_PT250_vs_PT246 < alphaVal), ones(sum(p_gfp_PT250_vs_PT246 < alphaVal), 1) * yRange(2), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
setLegendOff(h);

%% RM computation
clc;
try
    load("windowChangeAttentive.mat", "windowChangeCT");
catch ME
    windowChangeCT = [min(t(p_gfp_REG4o06_vs_REG4 < alphaVal & t(:)' > 1000)), ...
                      max(t(p_gfp_REG4o06_vs_REG4 < alphaVal & t(:)' > 1000 & t(:)' < 1500))];
    save("windowChangeAttentive.mat", "windowChangeCT");
end
disp(['Time window for change response determined by GFP: from ', num2str(windowChangeCT(1)), ...
      ' to ', num2str(windowChangeCT(2)), ' ms']);

% REG
[RM_channels_baseREG, ...
 RM_channels_changeREG] = deal(cell(length(ICIsREG), 1));
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    RM_channels_baseREG  {dIndex} = calRM(temp, window, windowBase, @(x) rmfcn(x, 2));
    RM_channels_changeREG{dIndex} = calRM(temp, window, windowChangeCT, @(x) rmfcn(x, 2));
    
    % convert to channel-by-subject matrix
    RM_channels_baseREG  {dIndex} = cat(2, RM_channels_baseREG  {dIndex}{:});
    RM_channels_changeREG{dIndex} = cat(2, RM_channels_changeREG{dIndex}{:});
end

% IRREG
[RM_channels_baseIRREG, ...
 RM_channels_changeIRREG] = deal(cell(length(ICIsIRREG), 1));
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    RM_channels_baseIRREG  {dIndex} = calRM(temp, window, windowBase, @(x) rmfcn(x, 2));
    RM_channels_changeIRREG{dIndex} = calRM(temp, window, windowChangeCT, @(x) rmfcn(x, 2));
    
    % convert to channel-by-subject matrix
    RM_channels_baseIRREG  {dIndex} = cat(2, RM_channels_baseIRREG  {dIndex}{:});
    RM_channels_changeIRREG{dIndex} = cat(2, RM_channels_changeIRREG{dIndex}{:});
end

% PT
[RM_channels_basePT, ...
 RM_channels_changePT] = deal(cell(length(freqs), 1));
for fIndex = 1:length(freqs)
    temp = cellfun(@(x) x([x.freq] == freqs(fIndex) & [x.type] == "PT").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    RM_channels_basePT  {fIndex} = calRM(temp, window, windowBase, @(x) rmfcn(x, 2));
    RM_channels_changePT{fIndex} = calRM(temp, window, windowChangeCT, @(x) rmfcn(x, 2));
    
    % convert to channel-by-subject matrix
    RM_channels_basePT  {fIndex} = cat(2, RM_channels_basePT  {fIndex}{:});
    RM_channels_changePT{fIndex} = cat(2, RM_channels_changePT{fIndex}{:});
end

RM_channels_delta_changeREG   = cellfun(@(x, y) x - y, RM_channels_changeREG,   RM_channels_baseREG,   "UniformOutput", false);
RM_channels_delta_changeIRREG = cellfun(@(x, y) x - y, RM_channels_changeIRREG, RM_channels_baseIRREG, "UniformOutput", false);
RM_channels_delta_changePT    = cellfun(@(x, y) x - y, RM_channels_changePT,    RM_channels_basePT,    "UniformOutput", false);

% compute averaged RM across all channels
idx = ~ismember(EEGPos.channels, EEGPos.ignore);
RM_baseREG     = cellfun(@(x) mean(x(idx, :), 1), RM_channels_baseREG,     "UniformOutput", false);
RM_changeREG   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changeREG,   "UniformOutput", false);
RM_baseIRREG   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_baseIRREG,   "UniformOutput", false);
RM_changeIRREG = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changeIRREG, "UniformOutput", false);
RM_basePT      = cellfun(@(x) mean(x(idx, :), 1), RM_channels_basePT,      "UniformOutput", false);
RM_changePT    = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changePT,    "UniformOutput", false);

RM_delta_changeREG   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changeREG,   "UniformOutput", false);
RM_delta_changeIRREG = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changeIRREG, "UniformOutput", false);
RM_delta_changePT    = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changePT,    "UniformOutput", false);

%% Statistics
statFcn = @(x, y) obtainArgoutN(@ttest, [2, 4], x', y', "Tail", "both");
% Tail = "left"; % alternative hypothesis: x < y
% Tail = "both";

p_RM_channels_changeREG_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseREG, RM_channels_changeREG, "UniformOutput", false);
p_RM_channels_changeREG_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeREG{1}, x), RM_channels_delta_changeREG, "UniformOutput", false);

p_RM_channels_changeIRREG_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseIRREG, RM_channels_changeIRREG, "UniformOutput", false);
p_RM_channels_changeIRREG_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeIRREG{1}, x), RM_channels_delta_changeIRREG, "UniformOutput", false);

p_RM_channels_changePT_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_basePT, RM_channels_changePT, "UniformOutput", false);
p_RM_channels_changePT_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changePT{1}, x), RM_channels_delta_changePT, "UniformOutput", false);

p_RM_channels_delta_change_REG_vs_IRREG = statFcn(RM_channels_delta_changeIRREG{end}, RM_channels_delta_changeREG{end});
p_RM_channels_delta_change_REG_vs_PT    = statFcn(RM_channels_delta_changePT{end}, RM_channels_delta_changeREG{end});

[~, ~, ~, p_RM_channels_changeREG_vs_base     ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeREG_vs_base     , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeREG_vs_control  ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeREG_vs_control  , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeIRREG_vs_base   ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeIRREG_vs_base   , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeIRREG_vs_control] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeIRREG_vs_control, "UniformOutput", false);
[~, ~, ~, p_RM_channels_changePT_vs_base      ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changePT_vs_base      , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changePT_vs_control   ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changePT_vs_control   , "UniformOutput", false);

[~, ~, ~, p_RM_channels_delta_change_REG_vs_IRREG] = fdr_bh(p_RM_channels_delta_change_REG_vs_IRREG, alphaVal, 'dep');
[~, ~, ~, p_RM_channels_delta_change_REG_vs_PT]    = fdr_bh(p_RM_channels_delta_change_REG_vs_PT   , alphaVal, 'dep');

% averaged
[p_RM_baseREG_vs_control  , stats_RM_baseREG_vs_control  ] = cellfun(@(x) statFcn(RM_baseREG{1}, x), RM_baseREG);
[p_RM_changeREG_vs_base   , stats_RM_changeREG_vs_base   ] = cellfun(@(x, y) statFcn(x, y), RM_baseREG, RM_changeREG);
[p_RM_changeREG_vs_control, stats_RM_changeREG_vs_control] = cellfun(@(x) statFcn(RM_delta_changeREG{1}, x), RM_delta_changeREG);

[p_RM_baseIRREG_vs_control      , stats_RM_baseIRREG_vs_control      ] = cellfun(@(x) statFcn(RM_baseIRREG{1}, x), RM_baseIRREG);
[p_RM_changeIRREG_vs_base       , stats_RM_changeIRREG_vs_base       ] = cellfun(@(x, y) statFcn(x, y), RM_baseIRREG, RM_changeIRREG);
[p_RM_changeIRREG_vs_control    , stats_RM_changeIRREG_vs_control    ] = cellfun(@(x) statFcn(RM_delta_changeIRREG{1}, x), RM_delta_changeIRREG);
[p_RM_changeIRREG_vs_control_raw, stats_RM_changeIRREG_vs_control_raw] = cellfun(@(x) statFcn(RM_changeIRREG{1}, x), RM_changeIRREG);

[p_RM_basePT_vs_control  , stats_RM_basePT_vs_control  ] = cellfun(@(x) statFcn(RM_basePT{1}, x), RM_basePT);
[p_RM_changePT_vs_base   , stats_RM_changePT_vs_base   ] = cellfun(@(x, y) statFcn(x, y), RM_basePT, RM_changePT);
[p_RM_changePT_vs_control, stats_RM_changePT_vs_control] = cellfun(@(x) statFcn(RM_delta_changePT{1}, x), RM_delta_changePT);

[p_RM_delta_change_REG_vs_IRREG, stats_RM_delta_change_REG_vs_IRREG] = statFcn(RM_delta_changeIRREG{end}, RM_delta_changeREG{end});
[p_RM_delta_change_REG_vs_PT   , stats_RM_delta_change_REG_vs_PT   ] = statFcn(RM_delta_changePT{end}, RM_delta_changeREG{end});

d_RM_delta_change_REG_vs_IRREG = cohensD(RM_delta_changeIRREG{end}, RM_delta_changeREG{end});
d_RM_delta_change_REG_vs_PT    = cohensD(RM_delta_changePT{end}, RM_delta_changeREG{end});

p_ANOVA_changeREG = anova1(cat(1, RM_changeREG{2:end})', [], "off");

%% Topoplot of RM for all conditions
% REG vs IRREG
FigTopo_REG_vs_IRREG = figure;
clearvars ax
for index = 1:length(ICIsREG)
    ax(index) = mSubplot(2, 5, index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeREG_vs_base{index} < alphaVal), 0, 24);
    topoplot(mean(RM_channels_delta_changeREG{index}, 2), EEGPos.locs, params{:});
end

for index = 1:length(ICIsIRREG)
    ax(length(ICIsREG) + index) = mSubplot(2, 5, 5 + find(ICIsREG == ICIsIRREG(index)), "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeIRREG_vs_base{index} < alphaVal), 0, 24);
    topoplot(mean(RM_channels_delta_changeIRREG{index}, 2), EEGPos.locs, params{:});
end
cRange = scaleAxes(ax, "c", "symOpt", "max", "ignoreInvisible", false);
set(findobj(ax, "Type", "Patch"), "FaceColor", "w");
set(FigTopo_REG_vs_IRREG, "Color", "w");
temp = floor(max(cRange) * 100) / 100;
exportgraphics(FigTopo_REG_vs_IRREG, fullfile(FIGUREPATH, 'topo (REG & IRREG).jpg'), "Resolution", 900);
exportcolorbar([-temp, temp], fullfile(FIGUREPATH, 'topo colorbar.jpg'));

% REG vs PT
FigTopo_REG_vs_PT = figure;
for index = 1:length(freqs)
    mSubplot(2, 5, 5 + index * 4 - 3, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changePT_vs_base{index} < alphaVal), 0, 24);
    topoplot(mean(RM_channels_delta_changePT{index}, 2), EEGPos.locs, params{:});
end
copyobj(ax(1:length(ICIsREG)), FigTopo_REG_vs_PT);
set(findobj(FigTopo_REG_vs_PT, "Type", "Patch"), "FaceColor", "w");
set(FigTopo_REG_vs_PT, "Color", "w");
scaleAxes(FigTopo_REG_vs_PT, "c", cRange, "ignoreInvisible", false);
exportgraphics(FigTopo_REG_vs_PT, fullfile(FIGUREPATH, 'topo (PT).jpg'), "Resolution", 900);

%% Tunning plot
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changeREG), cellfun(@SE, RM_delta_changeREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, RM_delta_changeIRREG), cellfun(@SE, RM_delta_changeIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
errorbar([1, length(ICIsREG)], cellfun(@mean, RM_delta_changePT), cellfun(@SE, RM_delta_changePT), "Color", [0.5, 0, 1], "LineWidth", 2, "DisplayName", "PT");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str((ICIsREG - ICIsREG(1)) ./ ICIsREG(1) * 1000));
xlabel("Difference ratio (‰)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

%% Scatter plot REG vs IRREG/PT
figure;
mSubplot(1, 2, 1, "shape", "square-min", "margin_left", 0.15);
X = RM_delta_changeIRREG{end};
Y = RM_delta_changeREG{end};
scatter(X, Y, 50, "black");
syncXY;
xlabel("\DeltaRM_{IRREG} (\muV)");
ylabel("\DeltaRM_{REG} (\muV)");
title(['REG vs IRREG | Pairwise t-test p=', num2str(p_RM_delta_change_REG_vs_IRREG), ' | N=', num2str(length(X))]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

mSubplot(1, 2, 2, "shape", "square-min", "margin_left", 0.15);
X = RM_delta_changePT{end};
Y = RM_delta_changeREG{end};
scatter(X, Y, 50, "black");
syncXY;
xlabel("\DeltaRM_{PT} (\muV)");
ylabel("\DeltaRM_{REG} (\muV)");
title(['REG vs PT | Pairwise t-test p=', num2str(p_RM_delta_change_REG_vs_PT), ' | N=', num2str(length(X))]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

%% Example channel
run(fullfile(pwd, "config\config_plot.m"));

exampleChannel = "POZ";
idx = find(upper(EEGPos.channelNames) == exampleChannel);

temp10 = cellfun(@(x) x([x.ICI] == ICIsREG  (1)   & [x.type] == "REG"  ).chMean(idx, :), data, "UniformOutput", false);
temp20 = cellfun(@(x) x([x.ICI] == ICIsIRREG(1)   & [x.type] == "IRREG").chMean(idx, :), data, "UniformOutput", false);
temp30 = cellfun(@(x) x([x.freq] == freqs(1)      & [x.type] == "PT")   .chMean(idx, :), data, "UniformOutput", false);
temp1  = cellfun(@(x) x([x.ICI] == ICIsREG  (end) & [x.type] == "REG"  ).chMean(idx, :), data, "UniformOutput", false);
temp2  = cellfun(@(x) x([x.ICI] == ICIsIRREG(end) & [x.type] == "IRREG").chMean(idx, :), data, "UniformOutput", false);
temp3  = cellfun(@(x) x([x.freq] == freqs(end)    & [x.type] == "PT")   .chMean(idx, :), data, "UniformOutput", false);

% normalize
temp10 = cellfun(@(x) x ./ std(x, [], 2), temp10, "UniformOutput", false);
temp20 = cellfun(@(x) x ./ std(x, [], 2), temp20, "UniformOutput", false);
temp30 = cellfun(@(x) x ./ std(x, [], 2), temp30, "UniformOutput", false);
temp1  = cellfun(@(x) x ./ std(x, [], 2), temp1,  "UniformOutput", false);
temp2  = cellfun(@(x) x ./ std(x, [], 2), temp2,  "UniformOutput", false);
temp3  = cellfun(@(x) x ./ std(x, [], 2), temp3,  "UniformOutput", false);

p1020 = wavePermTest(temp10, temp20, nperm, "Type", "ERP", "Tail", "both");
p1030 = wavePermTest(temp10, temp30, nperm, "Type", "ERP", "Tail", "both");
p110 = wavePermTest(temp1,  temp10, nperm, "Type", "ERP", "Tail", "both");
p220 = wavePermTest(temp2,  temp20, nperm, "Type", "ERP", "Tail", "both");
p330 = wavePermTest(temp3,  temp30, nperm, "Type", "ERP", "Tail", "both");
p12 = wavePermTest(temp1,  temp2,  nperm, "Type", "ERP", "Tail", "both");
p13 = wavePermTest(temp1,  temp3,  nperm, "Type", "ERP", "Tail", "both");

chDataREG = chDataREG_All;
chDataREG = addfield(chDataREG, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataREG_All, "UniformOutput", false)');
chDataREG = addfield(chDataREG, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataREG_All, "UniformOutput", false)');
plotRawWaveMulti(chDataREG, window - 1000 - ICIsREG(1));
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - ICIsREG(1); 0;  1000 - ICIsREG(1)}));
scaleAxes("x", [-100, 600]);
yRange = scaleAxes("y", "on", "symOpt", "max");

chDataIRREG = chDataIRREG_All;
chDataIRREG = addfield(chDataIRREG, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataIRREG_All, "UniformOutput", false)');
chDataIRREG = addfield(chDataIRREG, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataIRREG_All, "UniformOutput", false)');
plotRawWaveMulti(chDataIRREG, window - 1000 - ICIsREG(1));
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - ICIsREG(1); 0;  1000 - ICIsREG(1)}));
scaleAxes("x", [-100, 600]);
scaleAxes("y", yRange);

chDataPT = chDataPT_All;
chDataPT = addfield(chDataPT, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataPT_All, "UniformOutput", false)');
chDataPT = addfield(chDataPT, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataPT_All, "UniformOutput", false)');
plotRawWaveMulti(chDataPT, window - 1000 - ICIsREG(1));
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {-1000; 0; 1000}));
scaleAxes("x", [-100, 600]);
scaleAxes("y", yRange);

clearvars chData
chData(1) = chDataREG(1);
chData(2) = chDataREG(end);
chData(3) = chDataIRREG(1);
chData(4) = chDataIRREG(end);
chData(5) = chDataPT(1);
chData(6) = chDataPT(end);
chData = addfield(chData, "color", {[1, 0.5, 0.5]; ...
                                    [1, 0, 0]; ...
                                    [0.5, 0.5, 1]; ...
                                    [0, 0, 1]; ...
                                    [0.75, 0.5, 1]; ...
                                    [0.5, 0, 1]});
t = linspace(window(1), window(2), length(chData(1).chMean))' - 1000 - ICIsREG(1);

plotRawWaveMulti(chData, window - 1000 - ICIsREG(1));
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - ICIsREG(1); 0; 1000 - ICIsREG(1)}));
scaleAxes("x", [-100, 600]);
scaleAxes("y", [-2, 2]);
yRange = get(gca, "YLim");

idx = p110 < alphaVal;
c = mixColors(chData(1).color, chData(2).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

idx = p220 < alphaVal;
c = mixColors(chData(3).color, chData(4).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

idx = p330 < alphaVal;
c = mixColors(chData(5).color, chData(6).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*')); ...
          fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res A1 (', char(area), ').mat'], ...
     "fs", ...
     "ICIsREG", ...
     "ICIsIRREG", ...
     "chDataREG_All", ...
     "chDataIRREG_All", ...
     params{:});

%% Results of figures
% Figure 4
% f
[t(:), chData(2).chMean(:), chData(2).chErr(:), chData(4).chMean(:), chData(4).chErr(:)]; % wave
[t(p12 < alphaVal), 2 * ones(sum(p12 < alphaVal), 1)]; % bar

% g
[t(:), chData(2).chMean(:), chData(2).chErr(:), chData(6).chMean(:), chData(6).chErr(:)]; % wave
[t(p13 < alphaVal), 2 * ones(sum(p13 < alphaVal), 1)]; % bar

% h
[RM_delta_changeIRREG{end}(:), RM_delta_changeREG{end}(:)];

% i
[RM_delta_changePT{end}(:), RM_delta_changeREG{end}(:)];
