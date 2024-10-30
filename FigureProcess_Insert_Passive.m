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
run(fullfile(pwd, "config\plotConfig.m"));
run(fullfile(pwd, "config\avgConfig_Neuracle64.m"));

alphaVal = 0.05;

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%% Wave plot
insertN = unique([data{1}.insertN])';
for index = 1:length(insertN)
    if isnan(insertN(index))
        temp = cellfun(@(x) x(isnan([x.insertN])).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = 'REG 4-4.06';
    else
        temp = cellfun(@(x) x([x.insertN] == insertN(index)).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = num2str(insertN(index));
    end

    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);

    chDataAll(index, 1).chMean = calchMean(temp);
    chDataAll(index, 1).color = colors{index};
end

plotRawWaveMultiEEG(chDataAll, window, [], EEGPos_Neuracle64);
scaleAxes("x", [1000 + 4.06, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataAll, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataAll, "UniformOutput", false);
t = linspace(window(1), window(2), length(chMean{1}))';
chData = addfield(chDataAll, "chMean", chMean);
chData = addfield(chData, "chErr", chErr);
FigGrandAvg = plotRawWaveMulti(chData, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [1000 + 4.06, 1400]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + 4.06; 2000}));
mPrint(FigGrandAvg, fullfile(FIGUREPATH, ['Grand average wave (', char(area), ').png']), "-dpng", "-r300");

%% Window config for RM
tIdxBase = t >= 800 & t <= 1000;
tIdxP1 = t >= 1060 & t <= 1180;
tIdxN2 = t >= 1180 & t <= 1280;

[~, tP1] = arrayfun(@(x) maxt(abs(x.chMean(tIdxP1) - mean(x.chMean(tIdxBase))), t(tIdxP1)), chData);
% windowChangeP1 = tP1 + windowBand;
windowChangeP1 = repmat(tP1(end, :) + windowBand, 8, 1);

[~, tN2] = arrayfun(@(x) maxt(abs(x.chMean(tIdxN2) - mean(x.chMean(tIdxBase))), t(tIdxN2)), chData);
% windowChangeN2 = tN2 + windowBand;
windowChangeN2 = repmat(tN2(end, :) + windowBand, 8, 1);

%% RM computation
RM_base = cell(length(insertN), 1);
RM_changeP1 = cell(length(insertN), 1);
RM_changeN2 = cell(length(insertN), 1);
for index = 1:length(insertN)
    if isnan(insertN(index))
        temp = cellfun(@(x) x(isnan([x.insertN])).chMean, data, "UniformOutput", false);
    else
        temp = cellfun(@(x) x([x.insertN] == insertN(index)).chMean, data, "UniformOutput", false);
    end
    
    temp = cellfun(@(x) mean(x(chs2Avg, :), 1), temp, "UniformOutput", false);
    RM_base{index}         = cellfun(@(x) rmfcn(x), cutData(temp, window, windowBase));
    RM_changeP1{index}   = cellfun(@(x) rmfcn(x), cutData(temp, window, windowChangeP1(index, :)));
    RM_changeN2{index} = cellfun(@(x) rmfcn(x), cutData(temp, window, windowChangeN2(index, :)));
end

RM_delta_changePeak = cellfun(@(x, y) x - y, RM_changeP1, RM_base, "UniformOutput", false);
RM_delta_changeTrough = cellfun(@(x, y) x - y, RM_changeN2, RM_base, "UniformOutput", false);

%% Statistics
% test normality
[~, p1] = cellfun(@swtest, RM_changeP1);
[~, p2] = cellfun(@swtest, RM_changeN2);
if all(p1 < alphaVal & p2 < alphaVal)
    statFcn = @(x, y) obtainArgoutN(@ttest, 2, x, y);
else
    statFcn = @(x, y) signrank(x, y, "tail", "both");
end

p_RM_changePeak_vs_base     = cellfun(@(x, y) statFcn(x, y), RM_base, RM_changeP1);
p_RM_changePeak_vs_control1 = cellfun(@(x)    statFcn(RM_changeP1{1}, x), RM_changeP1);
p_RM_changePeak_vs_control2 = cellfun(@(x)    statFcn(RM_changeP1{end}, x), RM_changeP1);

p_RM_changeTrough_vs_base     = cellfun(@(x, y) statFcn(x, y), RM_base, RM_changeN2);
p_RM_changeTrough_vs_control1 = cellfun(@(x)    statFcn(RM_changeN2{1}, x), RM_changeN2);
p_RM_changeTrough_vs_control2 = cellfun(@(x)    statFcn(RM_changeN2{end}, x), RM_changeN2);

%% Topo RM computation
EEGPos = EEGPos_Neuracle64;
channelNames = EEGPos.channelNames;
channels = 1:length(channelNames);
chs2Plot = channels(~ismember(channels, 60:64))'; % Neuracle
params0 = [{'plotchans'}, {chs2Plot}                    , ... % indices of channels to plot
           {'plotrad'  }, {0.7}                        , ... % plot radius
           {'headrad'  }, {1.08 * max([EEGPos.locs(chs2Plot).radius])}, ... % head radius
           {'intrad'   }, {0.7}                         , ... % interpolate radius
           {'conv'     }, {'on'}                        , ... % plot radius just covers maximum channel radius
           {'colormap' }, {'jet'}                       , ...
           {'emarker'  }, {{'o', 'k', 4, 1}}          ];    % {MarkerType, Color, Size, LineWidth}

% change response
[RM_topo_delta_changeP1, ...
 RM_topo_delta_changeN2, ...
 p_channels_P1_vs_control1, ...
 p_channels_N2_vs_control1] = deal(cell(length(insertN), 1));

[~, tP1] = maxt(abs(chDataAll(end).chMean(:, tIdxP1) - mean(chDataAll(end).chMean(:, tIdxBase), 2)), t(tIdxP1), 2);
[~, tN2] = maxt(abs(chDataAll(end).chMean(:, tIdxN2) - mean(chDataAll(end).chMean(:, tIdxBase), 2)), t(tIdxN2), 2);

figure;
for index = 1:length(insertN)
    if isnan(insertN(index))
        temp = cellfun(@(x) x(isnan([x.insertN])).chMean, data, "UniformOutput", false);
    else
        temp = cellfun(@(x) x([x.insertN] == insertN(index)).chMean, data, "UniformOutput", false);
    end

    tempBase = cellfun(@(x) rmfcn(x, 2), cutData(temp, window, windowBase), "UniformOutput", false);
    tempP1 = cellfun(@(x) rowFcn(@(y, z) rmfcn(cutData(y, window, z + windowBand), 2), x, tP1), temp, "UniformOutput", false);
    tempN2 = cellfun(@(x) rowFcn(@(y, z) rmfcn(cutData(y, window, z + windowBand), 2), x, tN2), temp, "UniformOutput", false);
    tempP1 = cellfun(@(x, y) x - y, tempP1, tempBase, "UniformOutput", false);
    tempN2 = cellfun(@(x, y) x - y, tempN2, tempBase, "UniformOutput", false);
    RM_topo_delta_changeP1{index} = calchMean(tempP1);
    RM_topo_delta_changeN2{index} = calchMean(tempN2);

    if index > 1
        p_channels_P1_vs_control1{index} = cellfun(@(x, y) statFcn(x, y), changeCellRowNum(tempP1Control1), changeCellRowNum(tempP1));
        p_channels_N2_vs_control1{index} = cellfun(@(x, y) statFcn(x, y), changeCellRowNum(tempN2Control1), changeCellRowNum(tempN2));
    
        % fdr correction
        % [~, ~, p_channels_P1_vs_control1{index}] = fdr_bh(p_channels_P1_vs_control1{index}, alphaVal, 'dep');
        % [~, ~, p_channels_N2_vs_control1{index}] = fdr_bh(p_channels_N2_vs_control1{index}, alphaVal, 'dep');
    else
        tempP1Control1 = tempP1;
        tempN2Control1 = tempN2;

        p_channels_P1_vs_control1{index} = ones(length(channels), 1);
        p_channels_N2_vs_control1{index} = ones(length(channels), 1);
    end

    mAxes(1, index) = mSubplot(2, length(insertN), index, "shape", "fill");
    params = [params0, ...
              {'emarker2'}, {{find(ismember(chs2Plot, channels(p_channels_P1_vs_control1{index} < alphaVal))), '.', 'k', 16, 1}}]; % {Channels, MarkerType, Color, Size, LineWidth}
    topoplot(RM_topo_delta_changeP1{index}, EEGPos.locs, params{:});
    title(chDataAll(index).legend, "FontSize", 14);
    if index == length(insertN)
        pos = tightPosition(gca, "IncludeLabels", true);
        colorbar(gca, "Position", [pos(1) + pos(3), pos(2), 0.01, pos(4)]);
    end

    mAxes(2, index) = mSubplot(2, length(insertN), index + length(insertN), "shape", "fill");
    params = [params0, ...
              {'emarker2'}, {{find(ismember(chs2Plot, channels(p_channels_N2_vs_control1{index} < alphaVal))), '.', 'k', 16, 1}}]; % {Channels, MarkerType, Color, Size, LineWidth}
    topoplot(RM_topo_delta_changeN2{index}, EEGPos.locs, params{:});
    if index == length(insertN)
        pos = tightPosition(gca, "IncludeLabels", true);
        colorbar(gca, "Position", [pos(1) + pos(3), pos(2), 0.01, pos(4)]);
    end

end
scaleAxes(mAxes(1, :), "c", "symOpt", "max", "ignoreInvisible", false);
scaleAxes(mAxes(2, :), "c", "symOpt", "max", "ignoreInvisible", false);

%% Tunning plot
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
hold on;
X = (1:length(insertN));
Y = cellfun(@mean, RM_delta_changePeak);
E = cellfun(@SE, RM_delta_changePeak);
errorbar(X - 0.05, Y, E, "Color", "r", "LineWidth", 2, "DisplayName", "Peak");
h(1) = scatter(X(p_RM_changePeak_vs_base < alphaVal) - 0.05, Y(p_RM_changePeak_vs_base < alphaVal) - E(p_RM_changePeak_vs_base < alphaVal) - 0.08, 80, "Marker", "*", "MarkerEdgeColor", "k");
h(2) = scatter(X(p_RM_changePeak_vs_control2 < alphaVal) - 0.05, Y(p_RM_changePeak_vs_control2 < alphaVal) + E(p_RM_changePeak_vs_control2 < alphaVal) + 0.08, 60, "Marker", "o", "MarkerEdgeColor", "k");
setLegendOff(h);

Y = cellfun(@mean, RM_delta_changeTrough);
E = cellfun(@SE, RM_delta_changeTrough);
errorbar(X + 0.05, Y, E, "Color", "b", "LineWidth", 2, "DisplayName", "Trough");
h(1) = scatter(X(p_RM_changeTrough_vs_base < alphaVal) + 0.05, Y(p_RM_changeTrough_vs_base < alphaVal) - E(p_RM_changeTrough_vs_base < alphaVal) - 0.08, 80, "Marker", "*", "MarkerEdgeColor", "k");
h(2) = scatter(X(p_RM_changeTrough_vs_control2 < alphaVal) + 0.05, Y(p_RM_changeTrough_vs_control2 < alphaVal) + E(p_RM_changeTrough_vs_control2 < alphaVal) + 0.08, 60, "Marker", "o", "MarkerEdgeColor", "k");
setLegendOff(h);

legend("Location", "northwest");
xticks(1:length(insertN));
xlim([0, length(insertN)] + 0.5);
labels = cellstr(num2str(insertN));
labels{end} = 'REG{4-4.06}';
labels = char(labels);
xticklabels(labels);
xlabel("Insert ICI number");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

mPrint(FigTuning, fullfile(FIGUREPATH, ['RM tuning (', char(area), ').png']), "-dpng", "-r300");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*')); ...
          fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res insert (', char(area), ').mat'], ...
     "fs", ...
     "insertN", ...
     "chs2Avg", ...
     params{:});
