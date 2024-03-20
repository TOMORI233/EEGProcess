ccc;
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\113\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, '113\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

colors = [generateGradientColors(2, 'r', 0.4); generateGradientColors(2, 'b', 0.4)];

interval = 0;
run("config\windowConfig.m");

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

% For rms
addpath(genpath(fullfile(matlabroot, 'toolbox\signal\signal')), '-begin');

rmfcn = @rms;
% rmfcn = @mean;

run("config\avgConfig_Neuracle64.m");

%%
RM_base0  = cell(4, 1);
RM_onset  = cell(4, 1);
RM_base   = cell(4, 1);
RM_change = cell(4, 1);
peakTimeOnset  = cell(4, 1);
peakTimeChange = cell(4, 1);
for index = 1:4
    temp = cellfun(@(x) x(index).chMean, data, "UniformOutput", false);

    if data{1}(index).ICI == 0 % PT
        chDataAll(index, 1).legend = ['PT 250-', num2str(data{1}(index).freq)];
        changeTime = 1000;
    else % REG
        chDataAll(index, 1).legend = ['REG 4-', num2str(data{1}(index).ICI)];
        changeTime = 1000 + data{1}(index).ICI;
    end
    chDataAll(index, 1).chMean = calchMean(temp);
    chDataAll(index, 1).color = colors{index};

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);

    windowTemp = [70, 140];
    temp1 = cellfun(@(x) mean(x, 1), cutData(temp, window, windowTemp), "UniformOutput", false);
    tTemp = linspace(windowTemp(1), windowTemp(2), length(temp1{1}))';
    [~, temp1] = cellfun(@max, temp1);
    peakTimeOnset{index} = tTemp(temp1);

    windowTemp = 1000 + [80, 170] + data{1}(index).ICI;
    temp1 = cellfun(@(x) mean(x, 1), cutData(temp, window, windowTemp), "UniformOutput", false);
    tTemp = linspace(windowTemp(1), windowTemp(2), length(temp1{1}))';
    [~, temp1] = cellfun(@max, temp1);
    peakTimeChange{index} = tTemp(temp1) - changeTime;

    temp1 = cutData(temp, window, windowBase0);
    RM_base0{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp1 = cutData(temp, window, windowOnset);
    RM_onset{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp1 = cutData(temp, window, windowBase);
    RM_base{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp1 = cutData(temp, window, windowChange);
    RM_change{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
end

plotRawWaveMultiEEG(chDataAll, window, [], EEGPos_Neuracle64);
scaleAxes("x", [1000, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataAll, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataAll, "UniformOutput", false);
chData = addfield(chDataAll, "chMean", chMean);
chData = addfield(chData, "chErr", chErr);
FigGrandAvg = plotRawWaveMulti(chData, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [0, 2500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));
print(FigGrandAvg, ['..\Docs\Figures\Figure 7\wave-', char(area), '.png'], "-dpng", "-r300");

%% scatter plot
FigScatter = figure;
maximizeFig;
mSubplot(2, 3, 1, "shape", "square-min", "margin_top", 0.15);
scatter(RM_change{4} - RM_base{4}, RM_change{2} - RM_base{2}, 50, "black");
[~, p_delta_change_before_CT_vs_PT] = ttest(RM_change{4} - RM_base{4}, RM_change{2} - RM_base{2});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("\DeltaRM of PT (\muV)");
ylabel("\DeltaRM of REG (\muV)");
title(['change - before change | p=', num2str(roundn(p_delta_change_before_CT_vs_PT, -4))]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

mSubplot(2, 3, 2, "shape", "square-min", "margin_top", 0.15);
scatter(RM_onset{4} - RM_base0{4}, RM_onset{2} - RM_base0{2}, 50, "black");
[~, p_delta_onset_base_CT_vs_PT] = ttest(RM_onset{4} - RM_base0{4}, RM_onset{2} - RM_base0{2});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("\DeltaRM of PT (\muV)");
ylabel("\DeltaRM of REG (\muV)");
title(['onset - base | p=', num2str(roundn(p_delta_onset_base_CT_vs_PT, -4))]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

mSubplot(2, 3, 3, "shape", "square-min", "margin_top", 0.15);
[~, p_peak_onset_vs_change_CT] = ttest(peakTimeOnset{2}, peakTimeChange{2});
[~, p_peak_onset_vs_change_PT] = ttest(peakTimeOnset{4}, peakTimeChange{4});
scatter(peakTimeOnset{2}, peakTimeChange{2}, 50, "red", "DisplayName", ['REG 4-5 (p=', num2str(p_peak_onset_vs_change_CT), ')']);
hold on;
scatter(peakTimeOnset{4}, peakTimeChange{4}, 50, "blue", "DisplayName", ['PT 250-200 (p=', num2str(p_peak_onset_vs_change_PT), ')']);
legend("Location", "best");
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("onset peak time (ms)");
ylabel("change peak time (ms)");
title('peak | onset vs change');
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

mSubplot(2, 3, 4, "shape", "square-min", "margin_top", 0.15);
scatter(RM_onset{4} - RM_base0{4}, RM_change{4} - RM_base{4}, 50, "black");
[~, p_delta_change_vs_onset_PT] = ttest(RM_onset{4} - RM_base0{4}, RM_change{4} - RM_base{4});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("\DeltaRM_{onset-base} (\muV)");
ylabel("\DeltaRM_{change-before change} (\muV)");
title(['PT 250-200 | p=', num2str(roundn(p_delta_change_vs_onset_PT, -4))]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

mSubplot(2, 3, 5, "shape", "square-min", "margin_top", 0.15);
scatter(RM_onset{2} - RM_base0{2}, RM_change{2} - RM_base{2}, 50, "black");
[~, p_delta_change_vs_onset_CT] = ttest(RM_onset{2} - RM_base0{2}, RM_change{2} - RM_base{2});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("\DeltaRM_{onset-base} (\muV)");
ylabel("\DeltaRM_{change-before change} (\muV)");
title(['REG 4-5 | p=', num2str(roundn(p_delta_change_vs_onset_CT, -4))]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

mSubplot(2, 3, 6, "shape", "square-min", "margin_top", 0.15);
[~, p_peak_onset_CT_vs_PT] = ttest(peakTimeOnset{2}, peakTimeOnset{4});
[~, p_peak_change_CT_vs_PT] = ttest(peakTimeChange{2}, peakTimeChange{4});
scatter(peakTimeOnset{2}, peakTimeOnset{4}, 50, "red", "DisplayName", ['onset (p=', num2str(p_peak_onset_CT_vs_PT), ')']);
hold on;
scatter(peakTimeChange{2}, peakTimeChange{4}, 50, "blue", "DisplayName", ['change (p=', num2str(p_peak_change_CT_vs_PT), ')']);
legend("Location", "best");
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("peak time of REG (ms)");
ylabel("peak time of PT (ms)");
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

print(FigScatter, ['..\Docs\Figures\Figure 7\scatter-', char(area), '.png'], "-dpng", "-r300");

%%
figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
scatter(peakTimeChange{2} - peakTimeOnset{2}, peakTimeChange{4} - peakTimeOnset{4}, 50, "black");
[~, p_delta_peakTime_change_onset_CT_vs_PT] = ttest(peakTimeChange{2} - peakTimeOnset{2}, peakTimeChange{4} - peakTimeOnset{4});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("REG (ms)");
ylabel("PT (ms)");
title(['\DeltaLatency_{change - onset} | p=', num2str(p_delta_peakTime_change_onset_CT_vs_PT)]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
    fieldnames(getVarsFromWorkspace('p_\W*'))];
save(strcat("..\DATA\MAT DATA\figure\Res_RM_113-", area, ".mat"), ...
    "fs", ...
    "chs2Avg", ...
    "window", ...
    "windowChange", ...
    "windowBase", ...
    params{:});

%% Figure result
% wave
res_t = linspace(window(1), window(2), length(chData(1).chMean))';
res_chMean0 = addfield(chData([2, 4]), "chMean", arrayfun(@(x) x.chMean', chData([2, 4]), "UniformOutput", false));
temp = {res_chMean0.chMean};
res_chMean  = cat(2, temp{:});
res_chErr0 = addfield(chData([2, 4]), "chErr", arrayfun(@(x) x.chErr', chData([2, 4]), "UniformOutput", false));
temp = {res_chErr0.chErr};
res_chErr  = cat(2, temp{:});

% scatter
res_scatter_delta_change_CT = RM_change{2} - RM_base{2};
res_scatter_delta_change_PT = RM_change{4} - RM_base{4};
res_scatter_delta_onset_CT = RM_onset{2} - RM_base0{2};
res_scatter_delta_onset_PT = RM_onset{4} - RM_base0{4};
res_scatter_peakTime_onset_CT = peakTimeOnset{2};
res_scatter_peakTime_onset_PT = peakTimeOnset{4};
res_scatter_peakTime_change_CT = peakTimeChange{2};
res_scatter_peakTime_change_PT = peakTimeChange{4};
res_p_delta_change_before_CT_vs_PT = p_delta_change_before_CT_vs_PT;
res_p_delta_onset_base_CT_vs_PT = p_delta_onset_base_CT_vs_PT;
res_p_delta_change_vs_onset_PT = p_delta_change_vs_onset_PT;
res_p_delta_change_vs_onset_CT = p_delta_change_vs_onset_CT;
res_p_peak_onset_vs_change_CT = p_peak_onset_vs_change_CT;
res_p_peak_onset_vs_change_PT = p_peak_onset_vs_change_PT;

res_comment = '第一列是REG 4-5，第二列是PT 250-200';
params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 7\data-', char(area), '.mat'], params{:});
