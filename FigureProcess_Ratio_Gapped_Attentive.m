ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\active2\chMeanAll.mat')); % all trials
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'active2\chMeanAll.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio Gapped Attentive (Comparison with Gapped)");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

nperm = 1e3;
alphaVal = 0.05;

interval = 600;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

% P1-N2
% windowChange = windowOnset + 1000 + interval; % overall

% P1
% windowChange = 95 + [-25, 25] + 1000 + interval; % peak
% rmfcn = @mean;

% N2
windowChange = 158 + [-25, 25] + 1000 + interval; % trough
rmfcn = @mean;

% N2a(P3?) component for MMN
% windowChange = 360 + 1000 + interval + [-25, 25];
% rmfcn = @mean;

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

% For A1&A2 comparison
load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");
load("..\DATA\MAT DATA\figure\subjectIdx_A2.mat", "subjectIdxA2");
data = data(subjectIdxA1 & subjectIdxA2);

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
scaleAxes("x", [1000, 1600] + interval);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 1000 + interval; 2000 + interval}));

plotRawWaveMulti(gfpDataREG, window);
scaleAxes("x", [1000, 1600] + interval);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000; 1000 + interval; 2000 + interval}));

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

plotRawWaveMultiEEG(chDataIRREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [1000, 1600] + interval);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 1000 + interval; 2000 + interval}));

%% Determine window for change response by GFP
% p_gfp_REG4o06_vs_REG4 = wavePermTest(gfpREG{1}, gfpREG{end}, "Tail", "both");
% t = linspace(window(1), window(2), length(p_gfp_REG4o06_vs_REG4))';
% plotRawWaveMulti(gfpDataREG([1, end]), window);
% xlabel("Time from onset (ms)");
% ylabel("GFP (\muV)");
% scaleAxes("x", [1000, 1600] + interval);
% scaleAxes("y", "on");
% addLines2Axes(struct("X", {0; 1000; 1000 + interval; 2000 + interval}));
% yRange = get(gca, "YLim");
% h = bar(t(p_gfp_REG4o06_vs_REG4 < alphaVal), ones(sum(p_gfp_REG4o06_vs_REG4 < alphaVal), 1) * yRange(2), 1000 / fs, "EdgeColor", "none", "FaceColor", "y", "FaceAlpha", 0.1);
% setLegendOff(h);

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

RM_channels_delta_changeREG   = cellfun(@(x, y) x - y, RM_channels_changeREG,   RM_channels_baseREG,   "UniformOutput", false);
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
% Tail = "left"; % alternative hypothesis: x < y
% Tail = "both";

p_RM_channels_changeREG_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseREG, RM_channels_changeREG, "UniformOutput", false);
p_RM_channels_changeREG_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeREG{1}, x), RM_channels_delta_changeREG, "UniformOutput", false);

p_RM_channels_changeIRREG_vs_base    = cellfun(@(x, y) statFcn(x, y), RM_channels_baseIRREG, RM_channels_changeIRREG, "UniformOutput", false);
p_RM_channels_changeIRREG_vs_control = cellfun(@(x) statFcn(RM_channels_delta_changeIRREG{1}, x), RM_channels_delta_changeIRREG, "UniformOutput", false);

p_RM_channels_delta_change_REG_vs_IRREG = statFcn(RM_channels_delta_changeIRREG{end}, RM_channels_delta_changeREG{end});

[~, ~, ~, p_RM_channels_changeREG_vs_base     ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeREG_vs_base     , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeREG_vs_control  ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeREG_vs_control  , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeIRREG_vs_base   ] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeIRREG_vs_base   , "UniformOutput", false);
[~, ~, ~, p_RM_channels_changeIRREG_vs_control] = cellfun(@(x) fdr_bh(x, alphaVal, 'dep'), p_RM_channels_changeIRREG_vs_control, "UniformOutput", false);

[~, ~, ~, p_RM_channels_delta_change_REG_vs_IRREG] = fdr_bh(p_RM_channels_delta_change_REG_vs_IRREG, alphaVal, 'dep');

% averaged
[p_RM_baseREG_vs_control  , stats_RM_baseREG_vs_control  ] = cellfun(@(x) statFcn(RM_baseREG{1}, x), RM_baseREG);
[p_RM_changeREG_vs_base   , stats_RM_changeREG_vs_base   ] = cellfun(@(x, y) statFcn(x, y), RM_baseREG, RM_changeREG);
[p_RM_changeREG_vs_control, stats_RM_changeREG_vs_control] = cellfun(@(x) statFcn(RM_delta_changeREG{1}, x), RM_delta_changeREG);

[p_RM_baseIRREG_vs_control  , stats_RM_baseIRREG_vs_control  ] = cellfun(@(x) statFcn(RM_baseIRREG{1}, x), RM_baseIRREG);
[p_RM_changeIRREG_vs_base   , stats_RM_changeIRREG_vs_base   ] = cellfun(@(x, y) statFcn(x, y), RM_baseIRREG, RM_changeIRREG);
[p_RM_changeIRREG_vs_control, stats_RM_changeIRREG_vs_control] = cellfun(@(x) statFcn(RM_delta_changeIRREG{1}, x), RM_delta_changeIRREG);

[p_RM_delta_change_REG_vs_IRREG, stats_RM_delta_change_REG_vs_IRREG] = statFcn(RM_delta_changeIRREG{end}, RM_delta_changeREG{end});

[p_ANOVA_changeREG, tbl_tuning, stats_tuning] = anova1(cat(1, RM_changeREG{2:end})', [], "on");

% Extract F-value, degrees of freedom, and p-value from the ANOVA table
F_value = tbl_tuning{2,5};  % F-statistic
df_between = tbl_tuning{2,3};  % Between-group degrees of freedom
df_within = tbl_tuning{3,3};  % Within-group degrees of freedom

% Calculate eta squared (η²) as effect size
SS_between = tbl_tuning{2,2};  % Sum of squares between groups
SS_total = tbl_tuning{4,2};    % Total sum of squares
eta_squared = SS_between / SS_total;  % Eta squared (η²)

%% Topoplot of RM for all conditions
% REG vs IRREG
figure;
clearvars ax
for index = 1:length(ICIsREG)
    ax(index) = mSubplot(2, 5, index, "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeREG_vs_control{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_changeREG{index}, 2), EEGPos.locs, params{:});
    if index == length(ICIsREG)
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end

for index = 1:length(ICIsIRREG)
    ax(length(ICIsREG) + index) = mSubplot(2, 5, 5 + find(ICIsREG == ICIsIRREG(index)), "shape", "square-min");
    params = topoplotConfig(EEGPos, find(p_RM_channels_changeIRREG_vs_control{index} < alphaVal), 6, 24);
    topoplot(mean(RM_channels_delta_changeIRREG{index}, 2), EEGPos.locs, params{:});
    if index == length(ICIsIRREG)
        pos = tightPosition(gca, "IncludeLabels", true);
        cb = colorbar("Position", [pos(1) + pos(3) - 0.01, pos(2), 0.01, pos(4)]);
        cb.FontSize = 14;
        cb.FontWeight = "bold";
    end
end
cRange = scaleAxes(ax, "c", "symOpt", "max", "ignoreInvisible", false);
mPrint(gcf, fullfile(FIGUREPATH, 'topo (REG & IRREG).jpg'), "-djpeg", "-r900");

%% Tunning plot
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changeREG), cellfun(@SE, RM_delta_changeREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, RM_delta_changeIRREG), cellfun(@SE, RM_delta_changeIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str((ICIsREG - ICIsREG(1)) ./ ICIsREG(1) * 1000));
xlabel("Difference ratio (‰)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

mPrint(FigTuning, fullfile(FIGUREPATH, ['RM tuning (', char(area), ').png']), "-dpng", "-r300");

%% Example channel
run(fullfile(pwd, "config\config_plot.m"));

exampleChannel = "POz";
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

p1020 = wavePermTest(temp10, temp20, nperm, "Type", "ERP", "Tail", "both");
p110 = wavePermTest(temp1,  temp10, nperm, "Type", "ERP", "Tail", "both");
p220 = wavePermTest(temp2,  temp20, nperm, "Type", "ERP", "Tail", "both");
p12 = wavePermTest(temp1,  temp2,  nperm, "Type", "ERP", "Tail", "both");

chDataREG = chDataREG_All;
chDataREG = addfield(chDataREG, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataREG_All, "UniformOutput", false)');
chDataREG = addfield(chDataREG, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataREG_All, "UniformOutput", false)');
plotRawWaveMulti(chDataREG, window - 1000 - interval);
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {-1000 - interval; -interval; 0; 1000}));
scaleAxes("x", [-100, 800]);
yRange = scaleAxes("y", "on", "symOpt", "max");

chDataIRREG = chDataIRREG_All;
chDataIRREG = addfield(chDataIRREG, "chMean", arrayfun(@(x) x.chMean(idx, :), chDataIRREG_All, "UniformOutput", false)');
chDataIRREG = addfield(chDataIRREG, "chErr", arrayfun(@(x) x.chErr(idx, :), chDataIRREG_All, "UniformOutput", false)');
plotRawWaveMulti(chDataIRREG, window - 1000 - interval);
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {-1000 - interval; -interval; 0; 1000}));
scaleAxes("x", [-100, 800]);
scaleAxes("y", yRange);

clearvars chData
chData(1) = chDataREG(1);
chData(2) = chDataREG(end);
chData(3) = chDataIRREG(1);
chData(4) = chDataIRREG(end);
chData = addfield(chData, "color", {[1, 0.5, 0.5]; ...
                                    [1, 0, 0]; ...
                                    [0.5, 0.5, 1]; ...
                                    [0, 0, 1]});
t = linspace(window(1), window(2), length(chData(1).chMean))' - 1000 - interval;

plotRawWaveMulti(chData, window - 1000 - interval);
xlabel("Time from change (ms)");
ylabel("Normalized response (\muV)");
title(['Grand-averaged wave in ', char(exampleChannel)]);
addLines2Axes(struct("X", {-1000 - interval; -interval; 0; 1000}));
scaleAxes("x", [-100, 800]);
yRange = scaleAxes("y", "on");

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

%% Results of figures
% Figure 5
% e
temp = arrayfun(@(x) [x.chMean(:), x.chErr(:)], chDataREG, "UniformOutput", false);
[t, cat(2, temp{:})];

% f,g
[cellfun(@mean, RM_delta_changeREG), cellfun(@SE, RM_delta_changeREG)];