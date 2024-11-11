ccc;

MATPATHsComa = dir("..\DATA\MAT DATA - coma\temp\**\151\chMean.mat");
MATPATHsComa = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHsComa, "UniformOutput", false);

MATPATHsHealthy = dir("..\DATA\MAT DATA - extra\temp\**\113\chMean.mat");
MATPATHsHealthy = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHsHealthy, "UniformOutput", false);

%% Params
colors = {'k', 'r'};

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuracle64.m"));

windowOnset = [0, 250];
windowBase0 = [-500, -300];
windowBase = [800, 1000];

nperm = 1e3;
alphaVal = 0.05;

fs = 1e3;

% rmfcn = path2func(fullfile(matlabroot, "toolbox/signal/signal/rms.m"));

%% 
[~, temp] = cellfun(@(x) getLastDirPath(x, 2), MATPATHsComa, "UniformOutput", false);
subjectIDsComa = cellfun(@(x) x{1}, temp, "UniformOutput", false);

%%
window = load(MATPATHsComa{1}).window;
dataComa = cellfun(@(x) load(x).chData, MATPATHsComa, "UniformOutput", false);
dataHealthy = cellfun(@(x) load(x).chData, MATPATHsHealthy, "UniformOutput", false);

dataComa = cellfun(@(x) x([1, 3]), dataComa, "UniformOutput", false);
dataHealthy = cellfun(@(x) x([1, 2]), dataHealthy, "UniformOutput", false);

%% 
idxOnset = ismember(subjectIDsComa, cellstr(readlines("subjects.txt")));
subjectIDsComa(idxOnset) = strcat(subjectIDsComa(idxOnset), '*');

%% Coma
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataComa, "UniformOutput", false);
% Normalize
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
chDataComaAll(1).chMean = calchMean(temp);
chDataComaAll(1).chErr  = calchErr(temp);
chDataComaAll(1).color  = colors{1};
chDataComaAll(1).legend = "REG 4-4";
gfpComa{1, 1} = calGFP(temp, EEGPos.ignore);
gfpComa{1, 1} = cat(1, gfpComa{1}{:});

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataComa, "UniformOutput", false);
% Normalize
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
chDataComaAll(2).chMean = calchMean(temp);
chDataComaAll(2).chErr  = calchErr(temp);
chDataComaAll(2).color  = colors{2};
chDataComaAll(2).legend = "REG 4-5";
gfpComa{2, 1} = calGFP(temp, EEGPos.ignore);
gfpComa{2, 1} = cat(1, gfpComa{2}{:});

plotRawWaveMultiEEG(chDataComaAll, window, [], EEGPos_Neuracle64);
addLines2Axes(struct("X", {0; 1000; 2000}));

gfpDataComa = chDataComaAll;
gfpDataComa = addfield(gfpDataComa, "chMean", cellfun(@(x) mean(x, 1), gfpComa, "UniformOutput", false));
gfpDataComa = addfield(gfpDataComa, "chErr", cellfun(@(x) SE(x, 1), gfpComa, "UniformOutput", false));
plotRawWaveMulti(gfpDataComa, window);

%% Healthy
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataHealthy, "UniformOutput", false);
% Normalize
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
chDataHealthyAll(1).chMean = calchMean(temp);
chDataHealthyAll(1).chErr  = calchErr(temp);
chDataHealthyAll(1).color  = colors{1};
chDataHealthyAll(1).legend = "REG 4-4";
gfpHealthy{1, 1} = calGFP(temp, EEGPos.ignore);
gfpHealthy{1, 1} = cat(1, gfpHealthy{1}{:});

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataHealthy, "UniformOutput", false);
% Normalize
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
chDataHealthyAll(2).chMean = calchMean(temp);
chDataHealthyAll(2).chErr  = calchErr(temp);
chDataHealthyAll(2).color  = colors{2};
chDataHealthyAll(2).legend = "REG 4-5";
gfpHealthy{2, 1} = calGFP(temp, EEGPos.ignore);
gfpHealthy{2, 1} = cat(1, gfpHealthy{2}{:});

plotRawWaveMultiEEG(chDataHealthyAll, window, [], EEGPos_Neuracle64);
addLines2Axes(struct("X", {0; 1000; 2000}));

gfpDataHealthy = chDataHealthyAll;
gfpDataHealthy = addfield(gfpDataHealthy, "chMean", cellfun(@(x) mean(x, 1), gfpHealthy, "UniformOutput", false));
gfpDataHealthy = addfield(gfpDataHealthy, "chErr", cellfun(@(x) SE(x, 1), gfpHealthy, "UniformOutput", false));

p_gfp = wavePermTest(gfpHealthy{1}, gfpHealthy{2}, nperm, "Type", "ERP", "Tail", "left");
plotRawWaveMulti(gfpDataHealthy, window);
xlabel("Time from onset (ms)");
ylabel("GFP (\muV)");
scaleAxes("x", [1000, 1600]);
yRange = scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000 + 4; 2000}));
t = linspace(window(1), window(2), length(p_gfp))';
h = bar(t(p_gfp < alphaVal), ones(sum(p_gfp < alphaVal), 1) * yRange(2), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
setLegendOff(h);

%% RM computation
windowChange = [min(t(p_gfp < alphaVal & t(:)' > 1000)), ...
                max(t(p_gfp < alphaVal & t(:)' > 1000 & t(:)' < 1500))];
disp(['Time window for change response determined by GFP: from ', num2str(windowChange(1)), ...
      ' to ', num2str(windowChange(2)), ' ms']);

% Coma
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataComa, "UniformOutput", false);
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
RM_channels_base0Coma {1, 1} = calRM(temp, window, windowBase0 , @(x) rmfcn(x, 2));
RM_channels_onsetComa {1, 1} = calRM(temp, window, windowOnset , @(x) rmfcn(x, 2));
RM_channels_baseComa  {1, 1} = calRM(temp, window, windowBase  , @(x) rmfcn(x, 2));
RM_channels_changeComa{1, 1} = calRM(temp, window, windowChange, @(x) rmfcn(x, 2));

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataComa, "UniformOutput", false);
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
RM_channels_base0Coma {2, 1} = calRM(temp, window, windowBase0 , @(x) rmfcn(x, 2));
RM_channels_onsetComa {2, 1} = calRM(temp, window, windowOnset , @(x) rmfcn(x, 2));
RM_channels_baseComa  {2, 1} = calRM(temp, window, windowBase  , @(x) rmfcn(x, 2));
RM_channels_changeComa{2, 1} = calRM(temp, window, windowChange, @(x) rmfcn(x, 2));

RM_channels_base0Coma  = cellfun(@(x) cat(2, x{:}), RM_channels_base0Coma , "UniformOutput", false);
RM_channels_onsetComa  = cellfun(@(x) cat(2, x{:}), RM_channels_onsetComa , "UniformOutput", false);
RM_channels_baseComa   = cellfun(@(x) cat(2, x{:}), RM_channels_baseComa  , "UniformOutput", false);
RM_channels_changeComa = cellfun(@(x) cat(2, x{:}), RM_channels_changeComa, "UniformOutput", false);

% Healthy
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataHealthy, "UniformOutput", false);
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
RM_channels_base0Healthy {1, 1} = calRM(temp, window, windowBase0 , @(x) rmfcn(x, 2));
RM_channels_onsetHealthy {1, 1} = calRM(temp, window, windowOnset , @(x) rmfcn(x, 2));
RM_channels_baseHealthy  {1, 1} = calRM(temp, window, windowBase  , @(x) rmfcn(x, 2));
RM_channels_changeHealthy{1, 1} = calRM(temp, window, windowChange, @(x) rmfcn(x, 2));

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataHealthy, "UniformOutput", false);
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
RM_channels_base0Healthy {2, 1} = calRM(temp, window, windowBase0 , @(x) rmfcn(x, 2));
RM_channels_onsetHealthy {2, 1} = calRM(temp, window, windowOnset , @(x) rmfcn(x, 2));
RM_channels_baseHealthy  {2, 1} = calRM(temp, window, windowBase  , @(x) rmfcn(x, 2));
RM_channels_changeHealthy{2, 1} = calRM(temp, window, windowChange, @(x) rmfcn(x, 2));

RM_channels_base0Healthy  = cellfun(@(x) cat(2, x{:}), RM_channels_base0Healthy , "UniformOutput", false);
RM_channels_onsetHealthy  = cellfun(@(x) cat(2, x{:}), RM_channels_onsetHealthy , "UniformOutput", false);
RM_channels_baseHealthy   = cellfun(@(x) cat(2, x{:}), RM_channels_baseHealthy  , "UniformOutput", false);
RM_channels_changeHealthy = cellfun(@(x) cat(2, x{:}), RM_channels_changeHealthy, "UniformOutput", false);

% diff
RM_channels_delta_onsetComa     = cellfun(@(x, y) x - y, RM_channels_onsetComa    , RM_channels_base0Coma   , "UniformOutput", false);
RM_channels_delta_onsetHealthy  = cellfun(@(x, y) x - y, RM_channels_onsetHealthy , RM_channels_base0Healthy, "UniformOutput", false);
RM_channels_delta_changeComa    = cellfun(@(x, y) x - y, RM_channels_changeComa   , RM_channels_baseComa    , "UniformOutput", false);
RM_channels_delta_changeHealthy = cellfun(@(x, y) x - y, RM_channels_changeHealthy, RM_channels_baseHealthy , "UniformOutput", false);

% compute averaged RM across all channels
idx = ~ismember(EEGPos.channels, EEGPos.ignore);
RM_baseComa      = cellfun(@(x) mean(x(idx, :), 1), RM_channels_baseComa     , "UniformOutput", false);
RM_baseHealthy   = cellfun(@(x) mean(x(idx, :), 1), RM_channels_baseHealthy  , "UniformOutput", false);
RM_base0Coma     = cellfun(@(x) mean(x(idx, :), 1), RM_channels_base0Coma    , "UniformOutput", false);
RM_base0Healthy  = cellfun(@(x) mean(x(idx, :), 1), RM_channels_base0Healthy , "UniformOutput", false);
RM_changeComa    = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changeComa   , "UniformOutput", false);
RM_changeHealthy = cellfun(@(x) mean(x(idx, :), 1), RM_channels_changeHealthy, "UniformOutput", false);

RM_delta_onsetComa     = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_onsetComa    , "UniformOutput", false);
RM_delta_onsetHealthy  = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_onsetHealthy , "UniformOutput", false);
RM_delta_changeComa    = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changeComa   , "UniformOutput", false);
RM_delta_changeHealthy = cellfun(@(x) mean(x(idx, :), 1), RM_channels_delta_changeHealthy, "UniformOutput", false);

%% Statistics
Tail = "left"; % alternative hypothesis: x < y
statFcn = @(x, y) rowFcn(@(x1, y1) signrank(x1, y1, "tail", Tail), x, y, "ErrorHandler", @mErrorFcn);

% channels
% onset
p_RM_channels_onsetComa_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_base0Coma   , RM_channels_onsetComa   , "UniformOutput", false);
p_RM_channels_onsetHealthy_vs_base = cellfun(@(x, y) statFcn(x, y), RM_channels_base0Healthy, RM_channels_onsetHealthy, "UniformOutput", false);
% change
p_RM_channels_changeComa_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseComa, RM_channels_changeComa, "UniformOutput", false);
p_RM_channels_changeComa_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeComa{1}, x), RM_channels_delta_changeComa, "UniformOutput", false);
p_RM_channels_changeHealthy_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseHealthy, RM_channels_changeHealthy, "UniformOutput", false);
p_RM_channels_changeHealthy_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeHealthy{1}, x), RM_channels_delta_changeHealthy, "UniformOutput", false);
p_RM_channels_delta_change_Coma_vs_Healthy = rowFcn(@(x, y) ranksum(x, y, "Tail", Tail), RM_channels_delta_changeHealthy{end}, RM_channels_delta_changeComa{end}, "ErrorHandler", @mErrorFcn);
% fdr
[~, ~, p_RM_channels_onsetComa_vs_base           ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_onsetComa_vs_base      , "UniformOutput", false);
[~, ~, p_RM_channels_onsetHealthy_vs_base        ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_onsetHealthy_vs_base   , "UniformOutput", false);
[~, ~, p_RM_channels_changeComa_vs_base          ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeComa_vs_base      , "UniformOutput", false);
[~, ~, p_RM_channels_changeComa_vs_control       ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeComa_vs_control   , "UniformOutput", false);
[~, ~, p_RM_channels_changeHealthy_vs_base       ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeHealthy_vs_base   , "UniformOutput", false);
[~, ~, p_RM_channels_changeHealthy_vs_control    ] = cellfun(@(x) fdr_bh(x, 0.05, 'dep'), p_RM_channels_changeHealthy_vs_control, "UniformOutput", false);
[~, ~, p_RM_channels_delta_change_Coma_vs_Healthy] = fdr_bh(p_RM_channels_delta_change_Coma_vs_Healthy, 0.05, 'dep');

% averaged
p_RM_changeComa_vs_base       = cellfun(@(x, y) statFcn(x, y), RM_baseComa, RM_changeComa);
p_RM_changeComa_vs_control    = cellfun(@(x) statFcn(RM_delta_changeComa{1}, x), RM_delta_changeComa);
p_RM_changeHealthy_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_baseHealthy, RM_changeHealthy);
p_RM_changeHealthy_vs_control = cellfun(@(x) statFcn(RM_delta_changeHealthy{1}, x), RM_delta_changeHealthy);

%% Topoplot of RM for all conditions
% change
figure;
clearvars ax
for index = 1:2
    ax(index) = mSubplot(2, 5, index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeComa_vs_base{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_changeComa{index}, 2), EEGPos.locs, params{:});
    if index == 2
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end

for index = 1:2
    ax(2 + index) = mSubplot(2, 5, 5 + index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeHealthy_vs_base{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_changeHealthy{index}, 2), EEGPos.locs, params{:});
    if index == 2
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end

scaleAxes(ax, "c", "symOpt", "max", "ignoreInvisible", false);

% onset
figure;
clearvars ax
for index = 1:2
    ax(index) = mSubplot(2, 5, index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_onsetComa_vs_base{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_onsetComa{index}, 2), EEGPos.locs, params{:});
    if index == 2
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end

for index = 1:2
    ax(2 + index) = mSubplot(2, 5, 5 + index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_onsetHealthy_vs_base{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_onsetHealthy{index}, 2), EEGPos.locs, params{:});
    if index == 2
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end

scaleAxes(ax, "c", "symOpt", "max", "ignoreInvisible", false);

%% Scatter plot of average RM across all channels
figure;
mSubplot(1, 3, 2, "shape", "square-min");
X_coma = RM_delta_onsetComa{end}(:);
Y_coma = RM_delta_changeComa{end}(:);

X_healthy = RM_delta_onsetHealthy{end}(:);
Y_healthy = RM_delta_changeHealthy{end}(:);

s = scatter(X_coma, Y_coma, 100, "blue", "filled", "DisplayName", "Coma");
s.DataTipTemplate.DataTipRows(end + 1) = dataTipTextRow("S", string(subjectIDsComa));
hold on;
scatter(X_healthy, Y_healthy, 100, "red", "filled", "DisplayName", "Healthy");
xlabel("RM_{onset} (\muV)");
ylabel("RM_{change} (\muV)");
xlim([-1, 1.5]);
ylim([-0.5, 1.5]);

pos = tightPosition(gca, "IncludeLabels", false);
axes("Position", [pos(1), pos(2) + pos(4), pos(3), 0.1]);
mHistogram({X_coma; X_healthy}, "FaceColor", {'b', 'r'});
xlim([-1, 1.5]);
set(gca, "Visible", "off");

axes("Position", [pos(1) + pos(3), pos(2), 0.05, pos(4)]);
mHistogram({Y_coma; Y_healthy}, "FaceColor", {'b', 'r'});
xlim([-0.5, 1.5]);
set(gca, "View", [90, 90]);
set(gca, "XDir", "reverse");
set(gca, "Visible", "off");

p_onset = ranksum(X_coma, X_healthy, "tail", "both");
p_change = ranksum(Y_coma, Y_healthy, "tail", "both");

%% Example channel
run(fullfile(pwd, "config\config_plot.m"));

exampleChannel = "O1";
chIdx = find(upper(EEGPos.channelNames) == exampleChannel);

chData = [chDataComaAll(end); chDataHealthyAll(end)];
chData = addfield(chData, "chMean", arrayfun(@(x) x.chMean(chIdx, :), chData, "UniformOutput", false));
chData = addfield(chData, "chErr", arrayfun(@(x) x.chErr(chIdx, :), chData, "UniformOutput", false));
chData = addfield(chData, "color", {'b'; 'r'});
chData = addfield(chData, "legend", {'Coma'; 'Healthy'});
plotRawWaveMulti(chData, window - 1000 - 5);
addLines2Axes(gca, struct("X", {-1000 - 5; 0; 1000 - 5}));

%% Results of figures
% SFigure 5
% a
[t(:) - 1000 - 5, cat(1, chData(end:-1:1).chMean)']; % wave

% b
[X_healthy(:), Y_healthy(:)];
[X_coma(:), Y_coma(:)];
