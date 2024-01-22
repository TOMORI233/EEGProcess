ccc;
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\active2\chMeanAll.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'active2\chMeanAll.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");
load("..\DATA\MAT DATA\figure\subjectIdx_A2.mat", "subjectIdxA2");

window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);
% data = data(subjectIdxA2);
data = data(subjectIdxA1 & subjectIdxA2); % for comparison A1&A2

colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

interval = 600;
run("config\windowConfig.m");
windowOnset = 1000 + interval + windowOnset;

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

% For rms
addpath(genpath(fullfile(matlabroot, 'toolbox\signal\signal')), '-begin');

rmfcn = @rms;
% rmfcn = @mean;

run("config\avgConfig_Neuroscan64.m");

%%
% REG
ICIsREG = [4, 4.01, 4.02, 4.03, 4.06]';
RM_baseREG  = cell(length(ICIsREG), 1);
RM_changeREG = cell(length(ICIsREG), 1);
skipIdxREG = false(length(data), length(ICIsREG));
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) getOr(x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG" & [x.nTrial] >= 10), "chMean"), data, "UniformOutput", false);
    skipIdxREG(:, dIndex) = cellfun(@isempty, temp);
    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(ICIsREG(dIndex))];

    temp(~skipIdxREG(:, dIndex)) = cellfun(@(x) x(chs2Avg, :), temp(~skipIdxREG(:, dIndex)), "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowOnset);
    RM_changeREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [1000, 1500 + interval]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + interval; 2000 + interval}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
t = linspace(window(1), window(2), length(chMean{1}))';
chDataREG = addfield(chDataREG_All, "chMean", chMean);
chDataREG = addfield(chDataREG, "chErr", chErr);
FigGrandAvg = plotRawWaveMulti(chDataREG, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [1000, 1500] + interval);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + interval; 2000 + interval}));
print(FigGrandAvg, ['..\Docs\Figures\Figure 12\wave-', char(area), '.png'], "-dpng", "-r300");

% IRREG
ICIsIRREG = [4, 4.06]';
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
    temp2 = cutData(temp, window, windowOnset);
    RM_changeIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataIRREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [0, 1500 + interval]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + interval; 2000 + interval}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chDataIRREG = addfield(chDataIRREG_All, "chMean", chMean);
chDataIRREG = addfield(chDataIRREG, "chErr", chErr);
plotRawWaveMulti(chDataIRREG, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [0, 1500 + interval]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + interval; 2000 + interval}));

%% scatter plot
FigScatterAndTuning = figure;
maximizeFig;
p_REG = zeros(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG) - 1
    mSubplot(2, length(ICIsREG) - 1, dIndex, "shape", "square-min", "margin_left", 0.15);
    scatter(RM_changeREG{1}(~skipIdxREG(:, dIndex + 1)), RM_changeREG{dIndex + 1}(~skipIdxREG(:, dIndex + 1)), 50, "black");
    [~, p_REG(dIndex)] = ttest(RM_changeREG{1}(~skipIdxREG(:, dIndex + 1)), RM_changeREG{dIndex + 1}(~skipIdxREG(:, dIndex + 1)));
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{control} (\muV)");
    ylabel("RM_{change} (\muV)");
    title(['REG S2 ICI=', num2str(ICIsREG(dIndex + 1)), ' | N=', num2str(sum(~skipIdxREG(:, dIndex + 1))), ' | p=', num2str(roundn(p_REG(dIndex), -4))]);
    addLines2Axes(gca);
end

mSubplot(2, 2, 3, "shape", "square-min", "margin_top", 0.2);
scatter(RM_changeIRREG{1} - RM_baseIRREG{1}, RM_changeIRREG{end} - RM_baseIRREG{end}, 50, "black");
[~, p_IRREG] = ttest(RM_changeIRREG{1} - RM_baseIRREG{1}, RM_changeIRREG{end} - RM_baseIRREG{end});
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel(['\DeltaRM_{IRREG ', num2str(ICIsIRREG(1)), '} (\muV)']);
ylabel(['|deltaRM_{IRREG ', num2str(ICIsIRREG(end)), '} (\muV)']);
title(['Pairwise t-test p=', num2str(roundn(p_IRREG, -4))]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

%% tunning
RM_deltaREG = rowFcn(@(x, y, z) x{1}(~z) - y{1}(~z), RM_changeREG, RM_baseREG, skipIdxREG', "UniformOutput", false);
RM_deltaIRREG = cellfun(@(x, y) x - y, RM_changeIRREG, RM_baseIRREG, "UniformOutput", false);

mSubplot(2, 2, 4, "shape", "square-min", "margin_top", 0.2);
errorbar((1:length(ICIsREG)) + 0.01, cellfun(@mean, RM_deltaREG), cellfun(@SE, RM_deltaREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)] - 0.01, cellfun(@mean, RM_deltaIRREG), cellfun(@SE, RM_deltaIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend("Location", "best");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("S2 ICI (ms)");
ylabel("\DeltaRM_{change - before change} (\muV)");
title(['Tuning of RM | One-way anova for REG p=', num2str(p_REG(end))]);

print(FigScatterAndTuning, ['..\Docs\Figures\Figure 12\tuning-', char(area), '.png'], "-dpng", "-r300");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*'))];
save(strcat("..\DATA\MAT DATA\figure\Res_RM_A2-", area, ".mat"), ...
     "fs", ...
     "interval", ...
     "ICIsREG", ...
     "ICIsIRREG", ...
     "skipIdxREG", ...
     "chs2Avg", ...
     "chDataREG", ...
     "window", ...
     "windowOnset", ...
     "windowBase", ...
     params{:});

%% Figure result
% basic
res_windowOnset = windowOnset;
res_windowBase = windowBase;

% wave
res_t = t - (1000 + ICIsREG(1));
res_chMean0 = addfield(chDataREG, "chMean", arrayfun(@(x) x.chMean', chDataREG, "UniformOutput", false));
temp = {res_chMean0.chMean};
res_chMean  = cat(2, temp{:});
res_chErr0 = addfield(chDataREG, "chErr", arrayfun(@(x) x.chErr', chDataREG, "UniformOutput", false));
temp = {res_chErr0.chErr};
res_chErr  = cat(2, temp{:});

% tuning
res_tuning_delta_REG_mean = cellfun(@mean, RM_deltaREG);
res_tuning_delta_REG_se = cellfun(@SE, RM_deltaREG);
p_ANOVA = anova1(cell2mat(RM_deltaREG), ...
                 cell2mat(rowFcn(@(x, y) ones(numel(x{1}), 1) * y, RM_deltaREG, (1:length(RM_deltaREG))', "UniformOutput", false)), ...
                 "off");
p_REG(end) = p_ANOVA;
res_p_change_vs_base_REG = p_REG;

res_comment = 'p值为与REG4-4比较，最后一个是组间ANOVA的';
params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 12\data-', char(area), '.mat'], params{:});
