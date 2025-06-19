ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive3\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 2), DATAPATHs, "UniformOutput", false);

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio No-Gapped Passive (Independent)");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

nperm = 1e3;
alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

%% Load
load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");
DATAPATHs = DATAPATHs(subjectIdxA1);

window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%% Wave and GFP
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

% IRREG
ICIsIRREG = unique([data{1}([data{1}.type] == "IRREG").ICI])';
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

%% Determine window for change response by GFP
p_gfp_REG4o06_vs_REG4 = wavePermTest(gfpREG{1}, gfpREG{end}, "Tail", "left");
t = linspace(window(1), window(2), length(p_gfp_REG4o06_vs_REG4))';
plotRawWaveMulti(gfpDataREG([1, end]), window);
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
xlabel("Time from onset (ms)");
ylabel("GFP (\muV)");
xlim([1000, 1600]);
yRange = scaleAxes("y", "on");
addBars2Axes(t(p_gfp_REG4o06_vs_REG4 < alphaVal), "y");

p_gfp_IRREG4o06_vs_IRREG4 = wavePermTest(gfpIRREG{1}, gfpIRREG{end}, "Tail", "left");
plotRawWaveMulti(gfpDataIRREG, window);
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
xlabel("Time from onset (ms)");
ylabel("GFP (\muV)");
scaleAxes("x", [1000, 1600]);
scaleAxes("y", yRange);
addBars2Axes(t(p_gfp_IRREG4o06_vs_IRREG4 < alphaVal), "y");

p_gfp_REG4o06_vs_IRREG4o06 = wavePermTest(gfpIRREG{end}, gfpREG{end}, "Tail", "left");
plotRawWaveMulti([gfpDataREG(end); gfpDataIRREG(end)], window);
xlabel("Time from onset (ms)");
ylabel("GFP (\muV)");
scaleAxes("x", [1000, 1600]);
scaleAxes("y", yRange);
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
addBars2Axes(t(p_gfp_REG4o06_vs_IRREG4o06 < alphaVal), "y");

%% RM computation
clc;
try
    load("windowChange.mat", "windowChange");
catch ME
    windowChange = [min(t(p_gfp_REG4o06_vs_REG4 < alphaVal & t(:)' > 1000)), ...
                    max(t(p_gfp_REG4o06_vs_REG4 < alphaVal & t(:)' > 1000 & t(:)' < 1500))];
    save("windowChange.mat", "windowChange");
end
disp(['Time window for change response determined by GFP: from ', num2str(windowChange(1)), ...
      ' to ', num2str(windowChange(2)), ' ms']);

% REG
[RM_channels_baseREG, ...
 RM_channels_changeREG] = deal(cell(length(ICIsREG), 1));
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    RM_channels_baseREG  {dIndex} = calRM(temp, window, windowBase, @(x) rmfcn(x, 2));
    RM_channels_changeREG{dIndex} = calRM(temp, window, windowChange, @(x) rmfcn(x, 2));
    
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
    RM_channels_changeIRREG{dIndex} = calRM(temp, window, windowChange, @(x) rmfcn(x, 2));
    
    % convert to channel-by-subject matrix
    RM_channels_baseIRREG  {dIndex} = cat(2, RM_channels_baseIRREG  {dIndex}{:});
    RM_channels_changeIRREG{dIndex} = cat(2, RM_channels_changeIRREG{dIndex}{:});
end

RM_channels_delta_changeREG   = cellfun(@(x, y) x - y, RM_channels_changeREG,   RM_channels_baseREG, "UniformOutput", false);
RM_channels_delta_changeIRREG = cellfun(@(x, y) x - y, RM_channels_changeIRREG, RM_channels_baseIRREG, "UniformOutput", false);

% compute averaged RM across all channels
idx = ~ismember(EEGPos.channels, EEGPos.ignore);
RM_baseREG     = cellfun(@(x) mean(x(idx, :), 1), RM_channels_baseREG,     "UniformOutput", false);
RM_changeREG   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changeREG,   "UniformOutput", false);
RM_baseIRREG   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_baseIRREG,   "UniformOutput", false);
RM_changeIRREG = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changeIRREG, "UniformOutput", false);

RM_delta_changeREG   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changeREG,   "UniformOutput", false);
RM_delta_changeIRREG = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changeIRREG, "UniformOutput", false);

%% Statistics
statFcn = @(x, y) obtainArgoutN(@ttest, [2, 4], x', y', "Tail", "both");
% Tail = "both"; % alternative hypothesis: x < y

p_RM_channels_changeREG_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseREG, RM_channels_changeREG, "UniformOutput", false);
p_RM_channels_changeREG_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeREG{1}, x), RM_channels_delta_changeREG, "UniformOutput", false);

p_RM_channels_changeIRREG_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseIRREG, RM_channels_changeIRREG, "UniformOutput", false);
p_RM_channels_changeIRREG_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeIRREG{1}, x), RM_channels_delta_changeIRREG, "UniformOutput", false);

p_RM_channels_delta_change_REG_vs_IRREG = statFcn(RM_channels_delta_changeIRREG{end}, RM_channels_delta_changeREG{end});

[~, ~, ~, p_RM_channels_changeREG_vs_base        ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeREG_vs_base     , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeREG_vs_control     ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeREG_vs_control  , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeIRREG_vs_base      ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeIRREG_vs_base   , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeIRREG_vs_control   ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeIRREG_vs_control, "UniformOutput", false);
[~, ~, ~, p_RM_channels_delta_change_REG_vs_IRREG] = fdr_bh(p_RM_channels_delta_change_REG_vs_IRREG, alphaVal, 'dep');

% averaged
[p_RM_baseREG_vs_control  , stats_RM_baseREG_vs_control  ] = cellfun(@(x) statFcn(RM_baseREG{1}, x), RM_baseREG);
[p_RM_changeREG_vs_base   , stats_RM_changeREG_vs_base   ] = cellfun(@(x, y) statFcn(x, y), RM_baseREG, RM_changeREG);
[p_RM_changeREG_vs_control, stats_RM_changeREG_vs_control] = cellfun(@(x) statFcn(RM_delta_changeREG{1}, x), RM_delta_changeREG);

d_RM_changeREG_vs_base = cellfun(@(x, y) cohensD(x, y), RM_baseREG, RM_changeREG);

[~, p_RM_baseIRREG_vs_control] = cellfun(@(x) ttest(RM_baseIRREG{1}, x, "Tail", "both"), RM_baseIRREG);
[~, p_RM_changeIRREG_vs_base   , ~, stats_RM_changeIRREG_vs_base   ] = cellfun(@(x, y) ttest(x, y, "Tail", "both"), RM_baseIRREG, RM_changeIRREG, "UniformOutput", false);
[~, p_RM_changeIRREG_vs_control, ~, stats_RM_changeIRREG_vs_control] = cellfun(@(x) ttest(RM_delta_changeIRREG{1}, x, "Tail", "both"), RM_delta_changeIRREG, "UniformOutput", false);
[~, p_RM_changeIRREG_vs_control_raw] = cellfun(@(x) ttest(RM_changeIRREG{1}, x, "Tail", "both"), RM_changeIRREG);

[~, p_RM_delta_change_REG_vs_IRREG, ~, stats_RM_delta_change_REG_vs_IRREG] = ttest(RM_delta_changeIRREG{end}, RM_delta_changeREG{end}, "Tail", "both");
d_RM_delta_change_REG_vs_IRREG = cohensD(RM_delta_changeIRREG{end}, RM_delta_changeREG{end});

%% Tunning plot
% compute averaged RM across all channels
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changeREG), cellfun(@SE, RM_delta_changeREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, RM_delta_changeIRREG), cellfun(@SE, RM_delta_changeIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM");

%% Topoplot of RM for all conditions
% REG
FigTopo = figure;
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
set(FigTopo, "Color", "w");
temp = floor(max(cRange) * 100) / 100;
% exportgraphics(FigTopo, fullfile(FIGUREPATH, 'topo.jpg'), "Resolution", 900);
% exportcolorbar([-temp, temp], fullfile(FIGUREPATH, 'topo colorbar.jpg'));

%% Grand average wave plot of all channels REG4-4.06 vs IRREG4-4.06
windowPlot = [-300, 2500]; % ms

FigREG = plotRawWaveEEG(chDataREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigREG, "x", windowPlot);
yRange = scaleAxes(FigREG, "y", "on", "symOpt", "max");
addLines2Axes(FigREG, struct("X", {0; 1000 + ICIsREG(1); 2000}, ...
                             "color", [255 128 0] / 255, ...
                             "width", 1.5), ...
                             "Layer", "bottom");
addLines2Axes(FigREG, struct("Y", 0, ...
                             "color", "k", ...
                             "style", "-", ...
                             "width", 0.5), ...
                             "Layer", "bottom");
addScaleEEG(FigREG, EEGPos, ' ms', ' \muV');
allAxes = findobj(FigREG, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).TickLength = [0, 0];
    allAxes(aIndex).Title.FontSize = 12;
    % % Mark channels with significant change responses
    % if any(contains(channelNames(p_RM_channels_changeREG_vs_base{end} < alphaVal), allAxes(aIndex).Title.String))
    %     allAxes(aIndex).Box = "on";
    %     allAxes(aIndex).XAxis.LineWidth = 2;
    %     allAxes(aIndex).YAxis.LineWidth = 2;
    %     allAxes(aIndex).XTickLabel = '';
    %     allAxes(aIndex).YTickLabel = '';
    % else
    %     allAxes(aIndex).XAxis.Visible = "off";
    %     allAxes(aIndex).YAxis.Visible = "off";
    % end
    allAxes(aIndex).XAxis.Visible = "off";
    allAxes(aIndex).YAxis.Visible = "off";
end
params = topoplotConfig(EEGPos, find(p_RM_channels_changeREG_vs_base{end} < alphaVal), 0, 16);
ax = mSubplot(FigREG, 3, 4, 4, "shape", "square-min");
topoplot(mean(RM_channels_delta_changeREG{end}, 2), EEGPos.locs, params{:});
cRange = scaleAxes(ax, "c", "symOpt", "max", "ignoreInvisible", false);
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";
cb.Color = [0, 0, 0];
temp = floor(max(cRange) * 100) / 100;
cb.Ticks = [-temp, 0, temp];
set(findobj(ax, "Type", "Patch"), "FaceColor", "w");
set(FigREG, "Color", "w");
% exportgraphics(FigREG, fullfile(FIGUREPATH, 'REG 4-4.06.jpg'), "Resolution", 900, "BackgroundColor", "none");

FigIRREG = plotRawWaveEEG(chDataIRREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigIRREG, "x", windowPlot, "ignoreInvisible", false);
scaleAxes(FigIRREG, "y", yRange);
addLines2Axes(FigIRREG, struct("X", {0; 1000 + ICIsREG(1); 2000}, ...
                             "color", [255 128 0] / 255, ...
                             "width", 1.5), ...
                             "Layer", "bottom");
addLines2Axes(FigIRREG, struct("Y", 0, ...
                             "color", "k", ...
                             "style", "-", ...
                             "width", 0.5), ...
                             "Layer", "bottom");
addScaleEEG(FigIRREG, EEGPos, ' ms', ' \muV');
allAxes = findobj(FigIRREG, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).TickLength = [0, 0];
    allAxes(aIndex).Title.FontSize = 12;
    % % Mark channels with significant change responses
    % if any(contains(channelNames(p_RM_channels_changeIRREG_vs_base{end} < alphaVal), allAxes(aIndex).Title.String))
    %     allAxes(aIndex).Box = "on";
    %     allAxes(aIndex).XAxis.LineWidth = 2;
    %     allAxes(aIndex).YAxis.LineWidth = 2;
    %     allAxes(aIndex).XTickLabel = '';
    %     allAxes(aIndex).YTickLabel = '';
    % else
    %     allAxes(aIndex).XAxis.Visible = "off";
    %     allAxes(aIndex).YAxis.Visible = "off";
    % end
    allAxes(aIndex).XAxis.Visible = "off";
    allAxes(aIndex).YAxis.Visible = "off";
end
params = topoplotConfig(EEGPos, find(p_RM_channels_changeIRREG_vs_base{end} < alphaVal), 0, 16);
ax = mSubplot(FigIRREG, 3, 4, 4, "shape", "square-min");
topoplot(mean(RM_channels_delta_changeIRREG{end}, 2), EEGPos.locs, params{:});
scaleAxes(ax, "c", cRange, "ignoreInvisible", false);
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";
cb.Color = [0, 0, 0];
cb.Ticks = [-temp, 0, temp];
set(findobj(ax, "Type", "Patch"), "FaceColor", "w");
set(FigIRREG, "Color", "w");
% exportgraphics(FigIRREG, fullfile(FIGUREPATH, 'IRREG 4-4.06.jpg'), "Resolution", 900);

%% Scatter plot
% All channels
FigScatter = plotScatterEEG(RM_channels_delta_changeIRREG{end}, ...
                            RM_channels_delta_changeREG{end}, ...
                            EEGPos, statFcn);
params = topoplotConfig(EEGPos, find(p_RM_channels_delta_change_REG_vs_IRREG < alphaVal), 4, 13);
mSubplot(FigScatter, 3, 4, 4, "shape", "square-min");
topoplot(mean(RM_channels_delta_changeREG{end} - RM_channels_delta_changeIRREG{end}, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";

% Averaged
mSubplot(FigScatter, 3, 4, 12, "shape", "square-min");
X = RM_delta_changeIRREG{end};
Y = RM_delta_changeREG{end};
s = scatter(X, Y, 50, "filled", "MarkerEdgeColor", "w", "MarkerFaceColor", "k");
s.DataTipTemplate.DataTipRows(end + 1) = dataTipTextRow("S", string(SUBJECTs));
syncXY;
xlabel("RM of Irreg_{4-4.06} (\muV)");
ylabel("RM of Reg_{4-4.06} (\muV)");
title(['Paired t-test p=', num2str(p_RM_delta_change_REG_vs_IRREG), ' | N=', num2str(length(SUBJECTs))]);
addLines2Axes(gca);

%% All channels
plotRawWaveMultiEEG(chDataREG_All, window - 1000 - ICIsREG(1), [], EEGPos_Neuroscan64);
scaleAxes("x", [-100, 600]);
yRange = scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {- 1000 - ICIsREG(1); 0; 1000 - ICIsREG(1)}));
addScaleEEG(gcf, EEGPos);

plotRawWaveMultiEEG(chDataIRREG_All, window - 1000 - ICIsREG(1), [], EEGPos_Neuroscan64);
scaleAxes("x", [-100, 600]);
scaleAxes("y", yRange);
addLines2Axes(struct("X", {- 1000 - ICIsREG(1); 0; 1000 - ICIsREG(1)}));
addScaleEEG(gcf, EEGPos);

%% save for comparison
params0 = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
           fieldnames(getVarsFromWorkspace('p_\W*')); ...
           fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res P3 (', char(area), ') - Compare with A1.mat'], ...
     "fs", ...
     "ICIsREG", ...
     "ICIsIRREG", ...
     "chDataREG_All", ...
     "chDataIRREG_All", ...
     params0{:});