ccc;
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive1\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'passive1\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

colors = cellfun(@(x) x / 255, {[0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

interval = 0;
run("config\windowConfig.m");
windowNew = [-500, 1000];

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

% For rms
addpath(genpath(fullfile(matlabroot, 'toolbox\signal\signal')), '-begin');

rmfcn = @rms;
% rmfcn = @mean;

run("config\avgConfig_Neuroscan64.m");

%%
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
RM_baseREG  = cell(length(ICIsREG), 1);
RM_changeREG = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) getOr(x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG"), "chMean"), data, "UniformOutput", false);
    
    % segment and align to change point
    timeShift = 1000 + roundn(ICIsREG(dIndex), 0);
    temp = cutData(temp, window, windowNew + timeShift);

    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(roundn(ICIsREG(dIndex), 0)), '-', num2str(ICIsREG(dIndex))];

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, windowNew, windowBase - timeShift);
    RM_baseREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, windowNew, windowChange - timeShift);
    RM_changeREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataREG_All, windowNew, [], EEGPos_Neuroscan64);
scaleAxes("x", [-100, 500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
chDataREG = addfield(chDataREG_All, "chMean", chMean);
chDataREG = addfield(chDataREG, "chErr", chErr);
FigGrandAvg = plotRawWaveMulti(chDataREG, windowNew, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [-100, 500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));
print(FigGrandAvg, ['..\Docs\Figures\Figure 4\wave-', char(area), '.png'], "-dpng", "-r300");

% IRREG
ICIsIRREG = unique([data{1}([data{1}.type] == "IRREG").ICI])';
RM_baseIRREG  = cell(length(ICIsIRREG), 1);
RM_changeIRREG = cell(length(ICIsIRREG), 1);
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    
    % segment and align to change point
    timeShift = 1000 + roundn(ICIsIRREG(dIndex), 0);
    temp = cutData(temp, window, windowNew + timeShift);

    chDataIRREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataIRREG_All(dIndex, 1).color = colors{dIndex};
    chDataIRREG_All(dIndex, 1).legend = ['IRREG ', num2str(roundn(ICIsIRREG(dIndex), 0)), '-', num2str(ICIsIRREG(dIndex))];

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, windowNew, windowBase - timeShift);
    RM_baseIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, windowNew, windowChange - timeShift);
    RM_changeIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataIRREG_All, windowNew, [], EEGPos_Neuroscan64);
scaleAxes("x", [-100, 500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chDataIRREG = addfield(chDataIRREG_All, "chMean", chMean);
chDataIRREG = addfield(chDataIRREG, "chErr", chErr);
plotRawWaveMulti(chDataIRREG, windowNew, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [-100, 500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));

%% scatter plot
FigScatter = figure;
maximizeFig;
p_REG = zeros(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    mSubplot(2, length(ICIsREG), dIndex, "shape", "square-min", "margin_left", 0.15, "margin_bottom", 0.25);
    scatter(RM_baseREG{dIndex}, RM_changeREG{dIndex}, 50, "black");
    [~, p_REG(dIndex)] = ttest(RM_baseREG{dIndex}, RM_changeREG{dIndex});
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{before change} (\muV)");
    ylabel("RM_{change} (\muV)");
    title(['REG S2 ICI=', num2str(ICIsREG(dIndex)), ' | p=', num2str(roundn(p_REG(dIndex), -4))]);
    addLines2Axes(gca);
end

p_IRREG = zeros(length(ICIsIRREG), 1);
for dIndex = 1:length(ICIsIRREG)
    mSubplot(2, length(ICIsIRREG), length(ICIsIRREG) + dIndex, "shape", "square-min", "margin_left", 0.15, "margin_bottom", 0.25);
    scatter(RM_baseIRREG{dIndex}, RM_changeIRREG{dIndex}, 50, "black");
    [~, p_IRREG(dIndex)] = ttest(RM_baseIRREG{dIndex}, RM_changeIRREG{dIndex});
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{before change} (\muV)");
    ylabel("RM_{change} (\muV)");
    title(['IRREG S2 ICI=', num2str(ICIsIRREG(dIndex)), ' | p=', num2str(roundn(p_IRREG(dIndex), -4))]);
    addLines2Axes(gca);
end

print(FigScatter, ['..\Docs\Figures\Figure 4\scatter-', char(area), '.png'], "-dpng", "-r300");

%% tunning
RM_deltaREG = cellfun(@(x, y) x - y, RM_changeREG, RM_baseREG, "UniformOutput", false);
RM_deltaIRREG = cellfun(@(x, y) x - y, RM_changeIRREG, RM_baseIRREG, "UniformOutput", false);

FigTuning = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar(1:length(ICIsREG), cellfun(@mean, RM_deltaREG), cellfun(@SE, RM_deltaREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar(1:length(ICIsIRREG), cellfun(@mean, RM_deltaIRREG), cellfun(@SE, RM_deltaIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend;
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("S2 ICI (ms)");
ylabel("\DeltaRM_{change - before change} (\muV)");
title("Tuning of RM");

print(FigTuning, ['..\Docs\Figures\Figure 4\tuning-', char(area), '.png'], "-dpng", "-r300");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*'))];
save(strcat("..\DATA\MAT DATA\figure\Res_RM_P1-", area, ".mat"), ...
     "fs", ...
     "ICIsREG", ...
     "ICIsIRREG", ...
     "chDataIRREG", ...
     "chs2Avg", ...
     "windowNew", ...
     params{:});

%% Figure result
% wave
res_t = linspace(windowNew(1), windowNew(2), length(chDataREG(1).chMean))';
res_chMean0 = addfield(chDataREG, "chMean", arrayfun(@(x) x.chMean', chDataREG, "UniformOutput", false));
temp = {res_chMean0.chMean};
res_chMean  = cat(2, temp{:});
res_chErr0 = addfield(chDataREG, "chErr", arrayfun(@(x) x.chErr', chDataREG, "UniformOutput", false));
temp = {res_chErr0.chErr};
res_chErr  = cat(2, temp{:});

% tuning
res_tuningREG_mean = cellfun(@mean, RM_deltaREG);
res_tuningREG_se = cellfun(@SE, RM_deltaREG);
res_p_change_vs_base_REG = p_REG;

params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 4\data-', char(area), '.mat'], params{:});
