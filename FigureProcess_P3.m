ccc;
cd(fileparts(mfilename("fullpath")));

ROOTPATH = '..\DATA\MAT DATA\temp';
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive3\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'passive3\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

interval = 0;
run("config\windowConfig.m");

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

% For rms
addpath(genpath(fullfile(matlabroot, 'toolbox\signal\signal')), '-begin');

rmfcn = @rms;
% rmfcn = @mean;

run("config\avgConfig_Neuroscan64.m");

%% Wave plot
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
RM_baseREG  = cell(length(ICIsREG), 1);
RM_changeREG = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(ICIsREG(dIndex))];

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChange);
    RM_changeREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [1000 + ICIsREG(1), 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
t = linspace(window(1), window(2), length(chMean{1}))';
chDataREG = addfield(chDataREG_All, "chMean", chMean);
chDataREG = addfield(chDataREG, "chErr", chErr);
FigGrandAvg = plotRawWaveMulti(chDataREG, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [1000 + ICIsREG(1), 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
print(FigGrandAvg, ['..\Docs\Figures\Figure 5\wave-', char(area), '.png'], "-dpng", "-r300");

% IRREG
ICIsIRREG = unique([data{1}([data{1}.type] == "IRREG").ICI])';
RM_baseIRREG  = cell(length(ICIsIRREG), 1);
RM_changeIRREG = cell(length(ICIsIRREG), 1);
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    chDataIRREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataIRREG_All(dIndex, 1).color = colors{dIndex};
    chDataIRREG_All(dIndex, 1).legend = ['IRREG ', num2str(ICIsIRREG(dIndex))];

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChange);
    RM_changeIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataIRREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [0, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chDataIRREG = addfield(chDataIRREG_All, "chMean", chMean);
chDataIRREG = addfield(chDataIRREG, "chErr", chErr);
plotRawWaveMulti(chDataIRREG, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [0, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

%% scatter plot
FigScatter = figure;
maximizeFig;
p_change_vs_base_REG = zeros(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    mSubplot(2, length(ICIsREG), dIndex, "shape", "square-min", "margin_left", 0.15, "margin_bottom", 0.25);
    scatter(RM_baseREG{dIndex}, RM_changeREG{dIndex}, 50, "black");
    [~, p_change_vs_base_REG(dIndex)] = ttest(RM_baseREG{dIndex}, RM_changeREG{dIndex});
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{before change} (\muV)");
    ylabel("RM_{change} (\muV)");
    title(['REG S2 ICI=', num2str(ICIsREG(dIndex)), ' | p=', num2str(p_change_vs_base_REG(dIndex))]);
    addLines2Axes(gca);
end

p_change_vs_base_IRREG = zeros(length(ICIsIRREG) + 1, 1);
for dIndex = 1:length(ICIsIRREG)
    mSubplot(2, length(ICIsIRREG) + 1, length(ICIsIRREG) + 1 + dIndex, "shape", "square-min", "margin_left", 0.15, "margin_bottom", 0.25);
    scatter(RM_baseIRREG{dIndex}, RM_changeIRREG{dIndex}, 50, "black");
    [~, p_change_vs_base_IRREG(dIndex)] = ttest(RM_baseIRREG{dIndex}, RM_changeIRREG{dIndex});
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{before change} (\muV)");
    ylabel("RM_{change} (\muV)");
    title(['IRREG S2 ICI=', num2str(ICIsIRREG(dIndex)), ' | p=', num2str(p_change_vs_base_IRREG(dIndex))]);
    addLines2Axes(gca);
end

mSubplot(2, length(ICIsIRREG) + 1, 2 * (length(ICIsIRREG) + 1), "shape", "square-min", "margin_left", 0.15, "margin_bottom", 0.25);
scatter(RM_baseIRREG{1}, RM_changeIRREG{end}, 50, "black");
[~, p_change_vs_base_IRREG(end)] = ttest(RM_baseIRREG{1}, RM_changeIRREG{end});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel(['RM_{IRREG ', num2str(ICIsIRREG(1)), '} (\muV)']);
ylabel(['RM_{IRREG ', num2str(ICIsIRREG(end)), '} (\muV)']);
title(['Pairwise t-test p=', num2str(p_change_vs_base_IRREG(end))]);
addLines2Axes(gca);

print(FigScatter, ['..\Docs\Figures\Figure 5\scatter-', char(area), '.png'], "-dpng", "-r300");

%% tunning
RM_deltaREG = cellfun(@(x, y) x - y, RM_changeREG, RM_baseREG, "UniformOutput", false);
RM_deltaIRREG = cellfun(@(x, y) x - y, RM_changeIRREG, RM_baseIRREG, "UniformOutput", false);

FigTuning = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar(1:length(ICIsREG), cellfun(@mean, RM_deltaREG), cellfun(@SE, RM_deltaREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)], cellfun(@mean, RM_deltaIRREG), cellfun(@SE, RM_deltaIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("S2 ICI (ms)");
ylabel("\DeltaRM_{change - before change} (\muV)");
title("Tuning of RM");

print(FigTuning, ['..\Docs\Figures\Figure 5\tuning-', char(area), '.png'], "-dpng", "-r300");

%% REG 4-4.06 vs IRREG 4-4.06
FigREG_vs_IRREG = figure;
maximizeFig;
mSubplot(1, 2, 1, "shape", "square-min", "margin_left", 0.15);
plot(t, chDataREG(end).chMean, "Color", "r", "LineWidth", 2, "DisplayName", "REG 4-4.06");
hold on;
plot(t, chDataIRREG(end).chMean, "Color", "k", "LineWidth", 2, "DisplayName", "IRREG 4-4.06");
legend;
xlabel('Time (ms)');
xlim([0, 2000]);
scaleAxes("y", "symOpt", "max");
ylabel('Response (\muV)');
title(['Grand-averaged wave in ', char(area), ' | N=', num2str(length(SUBJECTs))]);
addLines2Axes(gca, struct("X", 1000 + ICIsREG(1), "color", [255 128 0] / 255, "width", 2));

mSubplot(1, 2, 2, "shape", "square-min", "margin_left", 0.15);
scatter(RM_deltaIRREG{end}, RM_deltaREG{end}, 50, "black");
[~, p_delta_REG_vs_IRREG] = ttest(RM_deltaIRREG{end}, RM_deltaREG{end});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("\DeltaRM_{IRREG 4-4.06} (\muV)");
ylabel("\DeltaRM_{REG 4-4.06} (\muV)");
title(['REG vs IRREG | p=', num2str(p_delta_REG_vs_IRREG)]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

print(FigREG_vs_IRREG, ['..\Docs\Figures\Figure 2\REG vs IRREG-', char(area), '.png'], "-dpng", "-r300");

%% REG 4-4.06 vs PT 250-246
% % PT
% freqs = unique([data{1}([data{1}.type] == "PT").freq])';
% RM_basePT  = cell(length(freqs), 1);
% RM_changePT = cell(length(freqs), 1);
% for fIndex = 1:length(freqs)
%     temp = cellfun(@(x) x([x.freq] == freqs(fIndex) & [x.type] == "PT").chMean, data, "UniformOutput", false);
%     chDataPT(fIndex, 1).chMean = calchMean(temp);
%     chDataPT(fIndex, 1).color = colors{end - fIndex + 1};
%     chDataPT(fIndex, 1).legend = ['PT ', num2str(freqs(fIndex))];
% 
%     temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
%     temp1 = cutData(temp, window, windowBase);
%     RM_basePT{fIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
%     temp2 = cutData(temp, window, windowChange);
%     RM_changePT{fIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
% end
% 
% plotRawWaveMultiEEG(chDataPT, window, [], EEGPos_Neuroscan64);
% scaleAxes("y", "on", "symOpt", "max");
% addLines2Axes(struct("X", {0; 1000; 2000}));
% 
% chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataPT, "UniformOutput", false);
% chDataPT = addfield(chDataPT, "chMean", chMean);
% plotRawWaveMulti(chDataPT, window, ['Grand-averaged wave in ', char(area)]);
% scaleAxes("y", "on", "symOpt", "max");
% addLines2Axes(struct("X", {0; 1000; 2000}));
% 
% figure;
% maximizeFig;
% mSubplot(1, 1, 1, "shape", "square-min", "margin_left", 0.15);
% scatter(RM_changePT{1} - RM_basePT{1}, RM_changeREG{end} - RM_baseREG{end}, 50, "black");
% [~, p_delta_CT_vs_PT] = ttest(RM_changePT{1} - RM_basePT{1}, RM_changeREG{end} - RM_baseREG{end});
% xRange = get(gca, "XLim");
% yRange = get(gca, "YLim");
% xyRange = [min([xRange, yRange]), max([xRange, yRange])];
% xlim(xyRange);
% ylim(xyRange);
% xlabel("\DeltaRM_{PT} (\muV)");
% ylabel("\DeltaRM_{REG} (\muV)");
% title(['PT vs REG | p=', num2str(roundn(p_delta_CT_vs_PT, -4))]);
% addLines2Axes(gca);
% addLines2Axes(gca, struct("X", 0));
% addLines2Axes(gca, struct("Y", 0));
% 
% chDataTemp = [chDataREG(end); chDataPT(1)];
% chDataTemp(2).color = [0, 0, 1];
% plotRawWaveMulti(chDataTemp, window, ['Grand-averaged wave in ', char(area)]);
% scaleAxes("y", "on", "symOpt", "max");
% addLines2Axes(struct("X", {0; 1000; 2000}));

%% save for comparison
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*'))];
save(strcat("..\DATA\MAT DATA\figure\Res_RM_P3-", area, ".mat"), ...
     "fs", ...
     "ICIsREG", ...
     "ICIsIRREG", ...
     "chs2Avg", ...
     "chDataREG", ...
     "window", ...
     "windowChange", ...
     "windowBase", ...
     params{:});

%% Figure result
FigREG = plotRawWaveEEG(chDataREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigREG, "x", [0, 2000]);
yRange = scaleAxes(FigREG, "y", "on", "symOpt", "max");
addLines2Axes(FigREG, struct("X", 1000 + ICIsREG(1), "color", [255 128 0] / 255, "width", 2));
setAxes(FigREG, "Visible", "off");
setAxes(FigREG, "LineWidth", 2);
mPrint(FigREG, '..\Docs\Figures\Figure 2\REG 4-4.06.png', "-dpng", "-r300");

FigIRREG = plotRawWaveEEG(chDataIRREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigIRREG, "x", [0, 2000]);
scaleAxes(FigIRREG, "y", yRange);
addLines2Axes(FigIRREG, struct("X", 1000 + ICIsREG(1), "color", [255 128 0] / 255, "width", 2));
setAxes(FigIRREG, "Visible", "off");
setAxes(FigIRREG, "LineWidth", 2);
mPrint(FigIRREG, '..\Docs\Figures\Figure 2\IRREG 4-4.06.png', "-dpng", "-r300");

% wave
res_t = t - (1000 + ICIsREG(1));
res_chMean0 = addfield(chDataREG, "chMean", arrayfun(@(x) x.chMean', chDataREG, "UniformOutput", false));
temp = {res_chMean0.chMean};
res_chMean  = cat(2, temp{:});
res_chErr0 = addfield(chDataREG, "chErr", arrayfun(@(x) x.chErr', chDataREG, "UniformOutput", false));
temp = {res_chErr0.chErr};
res_chErr  = cat(2, temp{:});
res_chMeanREG_4_4o06 = chDataREG(end).chMean';
res_chErrREG_4_4o06 = chDataREG(end).chErr';
res_chMeanIRREG_4_4o06 = chDataIRREG(end).chMean';
res_chErrIRREG_4_4o06 = chDataIRREG(end).chErr';

% scatter
res_scatterY_deltaRM_REG = RM_deltaREG{end};
res_scatterX_deltaRM_IRREG = RM_deltaIRREG{end};
res_p_delta_REG_vs_IRREG = p_delta_REG_vs_IRREG;

% tuning
res_tuning_delta_REG_mean = cellfun(@mean, RM_deltaREG);
res_tuning_delta_REG_se = cellfun(@SE, RM_deltaREG);
res_p_change_vs_base_REG = p_change_vs_base_REG;

params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 2\data-', char(area), '.mat'], params{:});
save(['..\Docs\Figures\Figure 5\data-', char(area), '.mat'], params{:});
