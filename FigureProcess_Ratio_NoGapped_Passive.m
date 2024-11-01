ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive3\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'passive3\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio No-Gapped Passive");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

nperm = 1e3;
alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

channels = EEGPos.channels;
channelNames = EEGPos.channelNames;

%% Load
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
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(ICIsREG(dIndex))];

    gfpREG{dIndex} = calGFP(temp, EEGPos.ignore);
    gfpREG{dIndex} = cat(1, gfpREG{dIndex}{:});
    gfpDataREG(dIndex, 1).chMean = mean(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).chErr = SE(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).color = colors{dIndex};
    gfpDataREG(dIndex, 1).legend = ['REG ', num2str(ICIsREG(dIndex))];
end

plotRawWaveMultiEEG(chDataREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [1000 + ICIsREG(1), 1600]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));

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
    chDataIRREG_All(dIndex, 1).legend = ['IRREG ', num2str(ICIsIRREG(dIndex))];

    gfpIRREG{dIndex} = calGFP(temp, EEGPos.ignore);
    gfpIRREG{dIndex} = cat(1, gfpIRREG{dIndex}{:});
    gfpDataIRREG(dIndex, 1).chMean = mean(gfpIRREG{dIndex}, 1);
    gfpDataIRREG(dIndex, 1).chErr = SE(gfpIRREG{dIndex}, 1);
    gfpDataIRREG(dIndex, 1).color = colors{dIndex};
    gfpDataIRREG(dIndex, 1).legend = ['IRREG ', num2str(ICIsIRREG(dIndex))];
end

%% Determine window for change response by GFP
p_gfp_REG4o06_vs_REG4 = wavePermTest(gfpREG{1}, gfpREG{end}, "Tail", "left");
t = linspace(window(1), window(2), length(p_gfp_REG4o06_vs_REG4))';

plotRawWaveMulti(gfpDataREG, window);
scaleAxes("x", [1000 + ICIsREG(1), 1600]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
yRange = get(gca, "YLim");
h1 = bar(t(p_gfp_REG4o06_vs_REG4 < alphaVal), ones(sum(p_gfp_REG4o06_vs_REG4 < alphaVal), 1) * yRange(1), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
h2 = bar(t(p_gfp_REG4o06_vs_REG4 < alphaVal), ones(sum(p_gfp_REG4o06_vs_REG4 < alphaVal), 1) * yRange(2), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
setLegendOff([h1, h2]);
clc;
windowChange = [min(t(p_gfp_REG4o06_vs_REG4 < alphaVal & t(:)' > 1000)), ...
                max(t(p_gfp_REG4o06_vs_REG4 < alphaVal & t(:)' > 1000 & t(:)' < 1500))];
disp(['Time window for change response determined by GFP: from ', num2str(windowChange(1)), ...
      ' to ', num2str(windowChange(2)), ' ms']);

p_gfp_IRREG4o06_vs_IRREG4 = wavePermTest(gfpIRREG{1}, gfpIRREG{end}, "Tail", "left");
plotRawWaveMulti(gfpDataIRREG, window);
scaleAxes("x", [-100, 2500]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
yRange = get(gca, "YLim");
h1 = bar(t(p_gfp_IRREG4o06_vs_IRREG4 < alphaVal), ones(sum(p_gfp_IRREG4o06_vs_IRREG4 < alphaVal), 1) * yRange(1), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
h2 = bar(t(p_gfp_IRREG4o06_vs_IRREG4 < alphaVal), ones(sum(p_gfp_IRREG4o06_vs_IRREG4 < alphaVal), 1) * yRange(2), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
setLegendOff([h1, h2]);

%% RM computation
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
Tail = "left"; % alternative hypothesis: x < y
[~, p_RM_channels_changeREG_vs_base]    = cellfun(@(x, y) ttest(x', y', "Tail", Tail), RM_channels_baseREG, RM_channels_changeREG, "UniformOutput", false);
[~, p_RM_channels_changeREG_vs_control] = cellfun(@(x) ttest(RM_channels_delta_changeREG{1}', x', "Tail", "right"), RM_channels_delta_changeREG, "UniformOutput", false);

[~, p_RM_channels_changeIRREG_vs_base]    = cellfun(@(x, y) ttest(x', y', "Tail", Tail), RM_channels_baseIRREG, RM_channels_changeIRREG, "UniformOutput", false);
[~, p_RM_channels_changeIRREG_vs_control] = cellfun(@(x) ttest(RM_channels_delta_changeIRREG{1}', x', "Tail", Tail), RM_channels_delta_changeIRREG, "UniformOutput", false);

[~, p_RM_channels_delta_change_REG_vs_IRREG] = ttest(RM_channels_delta_changeIRREG{end}', RM_channels_delta_changeREG{end}', "Tail", Tail);

[~, ~, p_RM_channels_changeREG_vs_base        ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeREG_vs_base        , "UniformOutput", false);
[~, ~, p_RM_channels_changeREG_vs_control     ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeREG_vs_control     , "UniformOutput", false);
[~, ~, p_RM_channels_changeIRREG_vs_base      ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeIRREG_vs_base      , "UniformOutput", false);
[~, ~, p_RM_channels_changeIRREG_vs_control   ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeIRREG_vs_control   , "UniformOutput", false);
[~, ~, p_RM_channels_delta_change_REG_vs_IRREG] = fdr_bh(p_RM_channels_delta_change_REG_vs_IRREG, 0.05, 'dep');

% averaged
[~, p_RM_changeREG_vs_base]    = cellfun(@(x, y) ttest(x, y, "Tail", Tail), RM_baseREG, RM_changeREG);
[~, p_RM_changeREG_vs_control] = cellfun(@(x) ttest(RM_delta_changeREG{1}, x, "Tail", Tail), RM_delta_changeREG);

[~, p_RM_changeIRREG_vs_base]    = cellfun(@(x, y) ttest(x, y, "Tail", Tail), RM_baseIRREG, RM_changeIRREG);
[~, p_RM_changeIRREG_vs_control] = cellfun(@(x) ttest(RM_delta_changeIRREG{1}, x, "Tail", Tail), RM_delta_changeIRREG);

[~, p_RM_delta_change_REG_vs_IRREG] = ttest(RM_delta_changeIRREG{end}, RM_delta_changeREG{end}, "Tail", Tail);

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
title("Tuning of RM_{change peak}");

mPrint(FigTuning, fullfile(FIGUREPATH, ['RM tuning (', char(area), ').png']), "-dpng", "-r300");

%% Topoplot of RM for all conditions
% REG
figure;
clearvars ax
for index = 1:length(ICIsREG)
    ax(index) = mSubplot(2, length(ICIsREG), index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeREG_vs_base{index} < alphaVal), 5, 20);
    topoplot(mean(RM_channels_delta_changeREG{index}, 2), EEGPos.locs, params{:});
    if index == length(ICIsREG)
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end

for index = 1:length(ICIsIRREG)
    ax(length(ICIsREG) + index) = mSubplot(2, length(ICIsREG), length(ICIsREG) + find(ICIsREG == ICIsIRREG(index)), "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeIRREG_vs_base{index} < alphaVal), 5, 20);
    topoplot(mean(RM_channels_delta_changeIRREG{index}, 2), EEGPos.locs, params{:});
    if index == length(ICIsIRREG)
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end
scaleAxes(ax, "c", "symOpt", "max", "ignoreInvisible", false);

%% Grand average wave plot of all channels REG4-4.06 vs IRREG4-4.06
FigREG = plotRawWaveEEG(chDataREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigREG, "x", [-300, 2500]);
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
allAxes = findobj(FigREG, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).TickLength = [0, 0];
    allAxes(aIndex).Title.FontSize = 12;
    if any(contains(channelNames(p_RM_channels_changeREG_vs_base{end} < alphaVal), allAxes(aIndex).Title.String))
        allAxes(aIndex).Box = "on";
        allAxes(aIndex).XAxis.LineWidth = 2;
        allAxes(aIndex).YAxis.LineWidth = 2;
        allAxes(aIndex).XTickLabel = '';
        allAxes(aIndex).YTickLabel = '';
    else
        allAxes(aIndex).XAxis.Visible = "off";
        allAxes(aIndex).YAxis.Visible = "off";
    end
end
ax = mSubplot(8, 1, 8, "shape", "square-min", "alignment", "bottom-left");
xlim([-300, 2500]);
ylim(yRange);
xticks([0, 1000]);
yticks([0, 2]);
ax.XAxis.Visible = "off";
ax.YAxis.Visible = "off";
addLines2Axes(ax, struct("X", [0, 0], "Y", [0, 2], "width", 2, "style", "-", "marker", "."));
addLines2Axes(ax, struct("X", [0, 1000], "Y", [0, 0], "width", 2, "style", "-", "marker", "."));
ax.Visible = "off";
params = topoplotConfig(EEGPos, find(p_RM_channels_changeREG_vs_base{end} < alphaVal), 4, 16);
ax = mSubplot(FigREG, 3, 4, 4, "shape", "square-min");
topoplot(mean(RM_channels_delta_changeREG{end}, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";
cRange = scaleAxes(ax, "c", "on", "symOpt", "max", "ignoreInvisible", false);
print(FigREG, fullfile(FIGUREPATH, 'REG 4-4.06.jpg'), "-djpeg", "-r900");

FigIRREG = plotRawWaveEEG(chDataIRREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigIRREG, "x", [-300, 2500]);
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
allAxes = findobj(FigIRREG, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).TickLength = [0, 0];
    allAxes(aIndex).Title.FontSize = 12;
    if any(contains(channelNames(p_RM_channels_changeIRREG_vs_base{end} < alphaVal), allAxes(aIndex).Title.String))
        allAxes(aIndex).Box = "on";
        allAxes(aIndex).XAxis.LineWidth = 2;
        allAxes(aIndex).YAxis.LineWidth = 2;
        allAxes(aIndex).XTickLabel = '';
        allAxes(aIndex).YTickLabel = '';
    else
        allAxes(aIndex).XAxis.Visible = "off";
        allAxes(aIndex).YAxis.Visible = "off";
    end
end
params = topoplotConfig(EEGPos, find(p_RM_channels_changeIRREG_vs_base{end} < alphaVal), 4, 16);
ax = mSubplot(FigIRREG, 3, 4, 4, "shape", "square-min");
topoplot(mean(RM_channels_delta_changeIRREG{end}, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";
scaleAxes(ax, "c", cRange, "ignoreInvisible", false);
print(FigIRREG, fullfile(FIGUREPATH, 'IRREG 4-4.06.jpg'), "-djpeg", "-r900");

%% Scatter plot
% All channels
FigScatter = plotScatterEEG(RM_channels_delta_changeIRREG{end}, ...
                            RM_channels_delta_changeREG{end}, ...
                            EEGPos, @(x, y) obtainArgoutN(@ttest, 2, x, y, "Tail", "left"));
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

%% save for comparison
params0 = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
           fieldnames(getVarsFromWorkspace('p_\W*')); ...
           fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res P3 (', char(area), ').mat'], ...
     "fs", ...
     "ICIsREG", ...
     "ICIsIRREG", ...
     "chDataREG_All", ...
     "chDataIRREG_All", ...
     params0{:});

%% Example channel
run(fullfile(pwd, "config\config_plot.m"));

exampleChannel = "POZ";
idx = find(EEGPos.channelNames == exampleChannel);

temp10 = cellfun(@(x) x([x.ICI] == ICIsREG  (1)   & [x.type] == "REG"  ).chMean(idx, :), data, "UniformOutput", false);
temp20 = cellfun(@(x) x([x.ICI] == ICIsIRREG(1)   & [x.type] == "IRREG").chMean(idx, :), data, "UniformOutput", false);
temp1  = cellfun(@(x) x([x.ICI] == ICIsREG  (end) & [x.type] == "REG"  ).chMean(idx, :), data, "UniformOutput", false);
temp2  = cellfun(@(x) x([x.ICI] == ICIsIRREG(end) & [x.type] == "IRREG").chMean(idx, :), data, "UniformOutput", false);

% normalize
temp10 = cellfun(@(x) x ./ std(x, [], 2), temp10, "UniformOutput", false);
temp20 = cellfun(@(x) x ./ std(x, [], 2), temp20, "UniformOutput", false);
temp1  = cellfun(@(x) x ./ std(x, [], 2), temp1,  "UniformOutput", false);
temp2  = cellfun(@(x) x ./ std(x, [], 2), temp2,  "UniformOutput", false);

p00 = wavePermTest(temp10, temp20, nperm, "Type", "ERP", "Tail", "both");
p10 = wavePermTest(temp1,  temp10, nperm, "Type", "ERP", "Tail", "both");
p20 = wavePermTest(temp2,  temp20, nperm, "Type", "ERP", "Tail", "both");
p12 = wavePermTest(temp1,  temp2,  nperm, "Type", "ERP", "Tail", "both");

t = t - 1000 - ICIsREG(1);

chDataREG = chDataREG_All;
chDataREG = addfield(chDataREG, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataREG_All, "UniformOutput", false)');
chDataREG = addfield(chDataREG, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataREG_All, "UniformOutput", false)');
plotRawWaveMulti(chDataREG, window - 1000 - ICIsREG(1));
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - ICIsREG(end); 0;  1000 - ICIsREG(1)}));
scaleAxes("x", [-100, 600]);
scaleAxes("y", "on", "symOpt", "max");

chDataIRREG = chDataIRREG_All;
chDataIRREG = addfield(chDataIRREG, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataIRREG_All, "UniformOutput", false)');
chDataIRREG = addfield(chDataIRREG, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataIRREG_All, "UniformOutput", false)');
plotRawWaveMulti(chDataIRREG, window - 1000 - ICIsREG(1));
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - ICIsREG(end); 0;  1000 - ICIsREG(1)}));
scaleAxes("x", [-100, 600]);
scaleAxes("y", "on", "symOpt", "max");

clearvars chData
chData(1) = chDataREG(1);
chData(2) = chDataREG(end);
chData(3) = chDataIRREG(1);
chData(4) = chDataIRREG(end);
chData = addfield(chData, "color", {[1, 0.5, 0.5]; ...
                                    [1, 0, 0]; ...
                                    [0.5, 0.5, 1]; ...
                                    [0, 0, 1]});
plotRawWaveMulti(chData, window - 1000 - ICIsREG(1));
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {- 1000 - ICIsREG(end); 0;  1000 - ICIsREG(1)}));
scaleAxes("x", [-100, 400]);
scaleAxes("y", [-2, 2]);
yRange = get(gca, "YLim");

idx = p00 < alphaVal;
c = mixColors(chData(1).color, chData(3).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

idx = p10 < alphaVal;
c = mixColors(chData(1).color, chData(2).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

idx = p20 < alphaVal;
c = mixColors(chData(3).color, chData(4).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

idx = p12 < alphaVal;
c = mixColors(chData(2).color, chData(4).color);
h1 = bar(t(idx), ones(sum(idx), 1) * yRange(1), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
h2 = bar(t(idx), ones(sum(idx), 1) * yRange(2), 1000 / fs, "FaceColor", c, "FaceAlpha", 0.1, "EdgeColor", "none");
setLegendOff([h1, h2]);

