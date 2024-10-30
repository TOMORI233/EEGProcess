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

nperm = 1e3;
alphaVal = 0.05;

EEGPos = EEGPos_Neuracle64;
chs2Ignore = EEGPos.ignore;

%% Window config for RM
% change response
windowChange = [1000, 1300];

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%% Wave plot
insertN = unique([data{1}.insertN])';
gfp = cell(length(insertN), 1);
for index = 1:length(insertN)
    if isnan(insertN(index))
        temp = cellfun(@(x) x(isnan([x.insertN])).chMean, data, "UniformOutput", false);
        chData(index, 1).legend = 'REG 4-4.06';
    else
        temp = cellfun(@(x) x([x.insertN] == insertN(index)).chMean, data, "UniformOutput", false);
        chData(index, 1).legend = num2str(insertN(index));
    end

    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);

    gfp{index} = cellfun(@(x) calGFP(x, chs2Ignore), temp, "UniformOutput", false);
    chData(index, 1).chMean = calchMean(gfp{index});
    % chData(index, 1).chErr  = calchErr(gfp{index});
    chData(index, 1).color  = colors{index};
end

gfp = cellfun(@cell2mat, gfp, "UniformOutput", false);
[p_vs_control1, p_vs_control2] = deal(cell(length(gfp), 1));
for index = 1:length(gfp) - 1
    p_vs_control1{index + 1}   = wavePermTest(gfp{index + 1}, gfp{1}, nperm, "chs2Ignore", chs2Ignore, "Type", "GFP", "Tail", "left");
    p_vs_control2{end - index} = wavePermTest(gfp{end - index}, gfp{end}, nperm, "chs2Ignore", chs2Ignore, "Type", "GFP", "Tail", "right");
end

plotRawWaveMulti(chData, window);
scaleAxes("x", [900, 1400]);
yRange = scaleAxes("y", "on");
t = linspace(window(1), window(2), size(chData(1).chMean, 2));
for index = 1:length(p_vs_control1) - 1
    h = fdr_bh(p_vs_control1{index + 1}, 0.01, 'pdep');
    h = double(h);
    h(h == 0) = nan;
    h(h == 1) = yRange(1) - index * 0.05;
    h = scatter(t, h, "MarkerFaceColor", chData(index + 1).color, "MarkerEdgeColor", "none", ...
                "Marker", "square");
    setLegendOff(h);

    h = fdr_bh(p_vs_control2{index}, 0.01, 'pdep');
    h = double(h);
    h(h == 0) = nan;
    h(h == 1) = yRange(2) + index * 0.05;
    h = scatter(t, h, "MarkerFaceColor", chData(index).color, "MarkerEdgeColor", "none", ...
                "Marker", "square");
    setLegendOff(h);
end
set(gca, "YLim", [yRange(1) - (index + 1) * 0.05, yRange(2) + (index + 1) * 0.05]);
addLines2Axes(struct("X", {0; 1000; 2000}));
title("Global field power | insert");
ylabel("GFP (\muV)");
xlabel("Time (ms)");

%% RM computation
RM_base = cell(length(insertN), 1);
RM_changeP1 = cell(length(insertN), 1);
RM_changeN2 = cell(length(insertN), 1);
[~, tP1] = maxt(chData(end).chMean(t >= 1080 & t <= 1160), t(t >= 1080 & t <= 1160));
[~, tN2] = maxt(chData(end).chMean(t >= 1160 & t <= 1260), t(t >= 1160 & t <= 1260));
for index = 1:length(insertN)
    temp = cutData(gfp{index}, window, windowBase);
    RM_base{index} = mean(temp, 2);

    temp = cutData(gfp{index}, window, tP1 + windowBand);
    RM_changeP1{index} = mean(temp, 2);

    temp = cutData(gfp{index}, window, tN2 + windowBand);
    RM_changeN2{index} = mean(temp, 2);
end

RM_delta_changeP1 = cellfun(@(x, y) x - y, RM_changeP1, RM_base, "UniformOutput", false);
RM_delta_changeN2 = cellfun(@(x, y) x - y, RM_changeN2, RM_base, "UniformOutput", false);

%% Statistics
% test normality
[~, p1] = cellfun(@swtest, RM_changeP1);
[~, p2] = cellfun(@swtest, RM_changeP1);
if all(p1 < alphaVal & p2 < alphaVal)
    statFcn = @(x, y) obtainArgoutN(@ttest, 2, x, y);
else
    statFcn = @signrank;
end

p_RM_changeP1_vs_base     = cellfun(@(x, y) statFcn(x, y), RM_base, RM_changeP1);
p_RM_changeP1_vs_control1 = cellfun(@(x)    statFcn(RM_changeP1{1}, x), RM_changeP1);
p_RM_changeP1_vs_control2 = cellfun(@(x)    statFcn(RM_changeP1{end}, x), RM_changeP1);

p_RM_changeN2_vs_base     = cellfun(@(x, y) statFcn(x, y), RM_base, RM_changeN2);
p_RM_changeN2_vs_control1 = cellfun(@(x)    statFcn(RM_changeN2{1}, x), RM_changeN2);
p_RM_changeN2_vs_control2 = cellfun(@(x)    statFcn(RM_changeN2{end}, x), RM_changeN2);

%% Tunning plot
insertN(isnan(insertN)) = inf;

FigTuning = figure;
mSubplot(1, 2, 1, "shape", "square-min");
hold on;
X = (1:length(insertN)) - 0.05;
Y = cellfun(@mean, RM_delta_changeP1);
E = cellfun(@SE, RM_delta_changeP1);
errorbar(X, Y, E, "Color", "r", "LineWidth", 2);
scatter(X(p_RM_changeP1_vs_control1 < alphaVal), Y(p_RM_changeP1_vs_control1 < alphaVal) - E(p_RM_changeP1_vs_control1 < alphaVal) - 0.03, 80, "Marker", "*", "MarkerEdgeColor", "k");
scatter(X(p_RM_changeP1_vs_control2 < alphaVal), Y(p_RM_changeP1_vs_control2 < alphaVal) + E(p_RM_changeP1_vs_control2 < alphaVal) + 0.03, 80, "Marker", "o", "MarkerEdgeColor", "k");
xticks(1:length(insertN));
xlim([0, length(insertN)] + 0.5);
xticklabels(num2str(insertN));
xlabel("Insert ICI number");
ylabel("\DeltaGFP (\muV)");
title("Tuning of GFP_{P1}");

mSubplot(1, 2, 2, "shape", "square-min");
hold on;
X = (1:length(insertN)) + 0.05;
Y = cellfun(@mean, RM_delta_changeN2);
E = cellfun(@SE, RM_delta_changeN2);
errorbar(X, Y, E, "Color", "b", "LineWidth", 2);
scatter(X(p_RM_changeN2_vs_control1 < alphaVal), Y(p_RM_changeN2_vs_control1 < alphaVal) - E(p_RM_changeN2_vs_control1 < alphaVal) - 0.03, 80, "Marker", "*", "MarkerEdgeColor", "k");
scatter(X(p_RM_changeN2_vs_control2 < alphaVal), Y(p_RM_changeN2_vs_control2 < alphaVal) + E(p_RM_changeN2_vs_control2 < alphaVal) + 0.03, 80, "Marker", "o", "MarkerEdgeColor", "k");
xticks(1:length(insertN));
xlim([0, length(insertN)] + 0.5);
xticklabels(num2str(insertN));
xlabel("Insert ICI number");
ylabel("\DeltaGFP (\muV)");
title("Tuning of GFP_{N2}");
