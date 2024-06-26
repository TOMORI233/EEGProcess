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
alphaVal = 0.025;

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

    gfp{index} = cellfun(@(x) calGFP(x, chs2Ignore), temp, "UniformOutput", false);
    chData(index, 1).chMean = calchMean(gfp{index});
%     chData(index, 1).chErr  = calchErr(gfp{index});
    chData(index, 1).color = colors{index};
end

gfp = cellfun(@cell2mat, gfp, "UniformOutput", false);
[p_vs_control1, p_vs_control2] = deal(cell(length(gfp), 1));
for index = 1:length(gfp) - 1
    p_vs_control1{index + 1} = wavePermTest(gfp{index + 1}, gfp{1}, nperm, "chs2Ignore", chs2Ignore, "Type", "GFP", "Tail", "left");
    p_vs_control2{end - index} = wavePermTest(gfp{end - index}, gfp{end}, nperm, "chs2Ignore", chs2Ignore, "Type", "GFP", "Tail", "right");
end

plotRawWaveMulti(chData, window);
scaleAxes("x", [1000, 1500]);
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
RM_change = cell(length(insertN), 1);
for index = 1:length(insertN)
    temp1 = cutData(gfp{index}, window, windowBase);
    RM_base{index} = mean(temp1, 2);
    temp2 = cutData(gfp{index}, window, windowChange);
    RM_change{index} = max(temp2, [], 2);
end

RM_delta_change = cellfun(@(x, y) x - y, RM_change, RM_base, "UniformOutput", false);

%% Statistics
[~, p_RM_changePeak_vs_base] = cellfun(@(x, y) ttest(x, y), RM_base, RM_change);
[~, p_RM_changePeak_vs_control1] = cellfun(@(x) ttest(RM_change{1}, x), RM_change);
[~, p_RM_changePeak_vs_control2] = cellfun(@(x) ttest(RM_change{end}, x), RM_change);

%% Tunning plot
insertN(isnan(insertN)) = inf;

FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
X = (1:length(insertN));
Y = cellfun(@mean, RM_delta_change);
E = cellfun(@SE, RM_delta_change);
errorbar(X, Y, E, "Color", "r", "LineWidth", 2);
hold on;
scatter(X(p_RM_changePeak_vs_control1 < alphaVal), Y(p_RM_changePeak_vs_control1 < alphaVal) - E(p_RM_changePeak_vs_control1 < alphaVal) - 0.03, 80, "Marker", "*", "MarkerEdgeColor", "k");
scatter(X(p_RM_changePeak_vs_control2 < alphaVal), Y(p_RM_changePeak_vs_control2 < alphaVal) + E(p_RM_changePeak_vs_control2 < alphaVal) + 0.03, 80, "Marker", "o", "MarkerEdgeColor", "k");
xticks(1:length(insertN));
xlim([0, length(insertN)] + 0.5);
xticklabels(num2str(insertN));
xlabel("Insert ICI number");
ylabel("\DeltaGFP (\muV)");
title("Tuning of GFP_{change}");
