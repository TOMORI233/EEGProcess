ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive1\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'passive1\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Length Passive");

%% Params
colors = flip(cellfun(@(x) x / 255, {[0 0 0], [0 100 255], [255 128 0], [255 100 100]}, "UniformOutput", false));

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

windowNew = [-500, 1000]; % ms

nperm = 1e3;
alphaVal = 0.05;

% rmfcn = @mean;

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);
load("windowChange.mat", "windowChange");

%% Wave plot
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) getOr(x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG"), "chMean"), data, "UniformOutput", false);
    
    % segment and align to change point
    timeShift = 1000 + roundn(ICIsREG(dIndex), 0);
    temp = cutData(temp, window, windowNew + timeShift);

    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);

    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).chErr = calchErr(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(roundn(ICIsREG(dIndex), 0)), '-', num2str(ICIsREG(dIndex))];

    gfpREG{dIndex, 1} = calGFP(temp, EEGPos.ignore);
    gfpREG{dIndex, 1} = cat(1, gfpREG{dIndex}{:});
    gfpDataREG(dIndex, 1).chMean = mean(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).chErr = SE(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).color = colors{dIndex};
end

plotRawWaveMultiEEG(chDataREG_All, windowNew, [], EEGPos_Neuroscan64);
scaleAxes("x", [0, 500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0, ...
                     "color", [255 128 0] / 255, ...
                     "width", 1.5), ...
                     "Layer", "bottom");
addLines2Axes(struct("Y", 0, ...
                     "color", "k", ...
                     "style", "-", ...
                     "width", 0.5), ...
                     "Layer", "bottom");
allAxes = findobj(gcf, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).TickLength = [0, 0];
    allAxes(aIndex).Title.FontSize = 12;
    allAxes(aIndex).XAxis.Visible = "off";
    allAxes(aIndex).YAxis.Visible = "off";
end
addScaleEEG(gcf, EEGPos, ' ms', ' \muV');
exportgraphics(gcf, fullfile(FIGUREPATH, 'grand-average wave.jpg'), "Resolution", 900);

%% Determine window for RM computation based on GFP
% repeat [-100, 0] for permutation test
% gfpBaseREG = cutData(gfpREG, windowNew, [-100, 0]);
% gfpBaseREG = cellfun(@(x) [x, repmat(x(:, 2:end), [1, 4])], gfpBaseREG, "UniformOutput", false);
% temp = cutData(gfpREG, windowNew, [0, 500]);
% p_gfp_REG_vs_base = cellfun(@(x, y) wavePermTest(x, y, nperm, "Type", "ERP", "Tail", "left"), gfpBaseREG, temp, "UniformOutput", false);
% 
% plotRawWaveMulti(gfpDataREG, windowNew);
% scaleAxes("x", [-100, 500]);
% addLines2Axes(struct("X", 0));
% 
% t = linspace(0, 500, length(p_gfp_REG_vs_base{1}))';
% for dIndex = 1:length(ICIsREG)
%     scatter(t(p_gfp_REG_vs_base{dIndex} < alphaVal), (1.5 + 0.1 * (dIndex - 1)) * ones(sum(p_gfp_REG_vs_base{dIndex} < alphaVal), 1), ...
%             "MarkerFaceColor", chDataREG_All(dIndex).color, "MarkerEdgeColor", "none", "Marker", "square");
% end
% 
% % find cP1 time
% [~, peakTime] = arrayfun(@(x) maxt(cutData(x.chMean, windowNew, [50, 300]), linspace(50, 300, 251)), gfpDataREG);
% windowChange = arrayfun(@(x) x + [-25, 25], peakTime, "UniformOutput", false);

% windowChange = repmat({windowChange - 1000 - roundn(ICIsREG(1), 0)}, [4, 1]);
windowChange = repmat({[85, 285]}, [4, 1]);

%% RM computation
[RM_channels_baseREG, ...
 RM_channels_changeREG] = deal(cell(length(ICIsREG), 1));
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) getOr(x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG"), "chMean"), data, "UniformOutput", false);
    
    % segment and align to change point
    timeShift = 1000 + roundn(ICIsREG(dIndex), 0);
    temp = cutData(temp, window, windowNew + timeShift);

    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);

    RM_channels_baseREG{dIndex}   = calRM(temp, windowNew, windowBase - timeShift, @(x) rmfcn(x, 2));
    RM_channels_changeREG{dIndex} = calRM(temp, windowNew, windowChange{dIndex}, @(x) rmfcn(x, 2));

    % convert to channel-by-subject matrix
    RM_channels_baseREG  {dIndex} = cat(2, RM_channels_baseREG  {dIndex}{:});
    RM_channels_changeREG{dIndex} = cat(2, RM_channels_changeREG{dIndex}{:});
end

RM_channels_delta_changeREG = cellfun(@(x, y) x - y, RM_channels_changeREG, RM_channels_baseREG, "UniformOutput", false);

% compute averaged RM across all channels
idx = ~ismember(EEGPos.channels, EEGPos.ignore);
RM_baseREG   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_baseREG,   "UniformOutput", false);
RM_changeREG = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changeREG, "UniformOutput", false);
RM_delta_changeREG = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changeREG, "UniformOutput", false);

%% Statistics
statFcn = @(x, y) obtainArgoutN(@ttest, [2, 4], x', y', "Tail", "both");
% statFcn = @(x, y) rowFcn(@(a, b) signrank(a, b, "tail", "left"), x, y, "ErrorHandler", @mErrorFcn);

p_RM_channels_changeREG_vs_base = cellfun(@(x, y) statFcn(x, y), RM_channels_baseREG, RM_channels_changeREG, "UniformOutput", false);

[~, ~, ~, p_RM_channels_changeREG_vs_base] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeREG_vs_base, "UniformOutput", false);

% averaged
[p_RM_changeREG_vs_base, stats_RM_changeREG_vs_base] = cellfun(@(x, y) statFcn(x, y), RM_baseREG, RM_changeREG);

d_RM_changeREG_vs_base = cellfun(@(x, y) cohensD(x, y), RM_baseREG, RM_changeREG);

%% Bayesian t-test
bf10_RM_change_vs_base = cellfun(@(x, y) bf.ttest(x, y), RM_baseREG, RM_changeREG);

%% Topoplot of RM for all conditions
% REG
FigTopo = figure;
for index = 1:length(ICIsREG)
    mSubplot(2, 5, index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeREG_vs_base{index} < alphaVal), 0, 24);
    topoplot(mean(RM_channels_delta_changeREG{index}, 2), EEGPos.locs, params{:});
end
cRange = scaleAxes("c", "symOpt", "max", "ignoreInvisible", false);
set(findobj(FigTopo, "Type", "Patch"), "FaceColor", "w");
set(FigTopo, "Color", "w");
temp = floor(max(cRange) * 100) / 100;
exportgraphics(FigTopo, fullfile(FIGUREPATH, 'topo.jpg'), "Resolution", 900);
exportcolorbar([-temp, temp], fullfile(FIGUREPATH, 'topo colorbar.jpg'));

%% Tunning plot
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
X = 1:length(ICIsREG);
Y = cellfun(@mean, RM_delta_changeREG);
E = cellfun(@SE, RM_delta_changeREG);
errorbar(X, Y, E, "Color", "r", "LineWidth", 2);
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*')); ...
          fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res P1 (', char(area), ').mat'], ...
     "fs", ...
     "ICIsREG", ...
     "chs2Avg", ...
     "windowNew", ...
     params{:});

%% Example channels
run(fullfile(pwd, "config\config_plot.m"));

exampleChannel = "POz";
idx = find(EEGPos.channelNames == exampleChannel);

chDataREG = chDataREG_All;
chDataREG = addfield(chDataREG, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataREG_All, "UniformOutput", false)');
chDataREG = addfield(chDataREG, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataREG_All, "UniformOutput", false)');
plotRawWaveMulti(chDataREG, windowNew);
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", 0));
scaleAxes("x", [-100, 600]);
yRange = scaleAxes("y", "on");

%% Results of figures
% Figure 3
% b
t = linspace(windowNew(1), windowNew(2), length(chDataREG(1).chMean))';
temp = arrayfun(@(x) [x.chMean(:), x.chErr(:)], chDataREG, "UniformOutput", false);
[t, cat(2, temp{:})];

% c
cat(1, RM_delta_changeREG{:})';
[cellfun(@mean, RM_delta_changeREG), cellfun(@SE, RM_delta_changeREG)];