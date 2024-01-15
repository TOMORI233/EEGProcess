ccc;
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\111\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, '111\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

colors = [{[0.5, 0.5, 0.5]}; ...
          flip(generateGradientColors(3, 'b', 0.2)); ...
          generateGradientColors(3, 'r', 0.2); ...
          {[0, 0, 0]}];

interval = 0;
run("config\windowConfig.m");
windowChange = 1000 + [50, 130]; % consider when N > 32 there might be off response

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

% For rms
addpath(genpath(fullfile(matlabroot, 'toolbox\signal\signal')), '-begin');

rmfcn = @rms;
% rmfcn = @mean;

run("config\avgConfig_Neuracle64.m");

%%
insertN = unique([data{1}.insertN])';
RM_baseInsert  = cell(length(insertN), 1);
RM_changeInsert = cell(length(insertN), 1);
for index = 1:length(insertN)
    if isnan(insertN(index))
        temp = cellfun(@(x) x(isnan([x.insertN])).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = 'REG 4-4.06';
    else
        temp = cellfun(@(x) x([x.insertN] == insertN(index)).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = ['Insert ', num2str(insertN(index))];
    end
    chDataAll(index, 1).chMean = calchMean(temp);
    chDataAll(index, 1).color = colors{index};

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseInsert{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChange);
    RM_changeInsert{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataAll, window, [], EEGPos_Neuracle64);
scaleAxes("x", [1000 + 4.06, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataAll, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataAll, "UniformOutput", false);
chData = addfield(chDataAll, "chMean", chMean);
chData = addfield(chData, "chErr", chErr);
FigGrandAvg = plotRawWaveMulti(chData, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [1000 + 4.06, 1400]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + 4.06; 2000}));
print(FigGrandAvg, ['..\Docs\Figures\Figure 3\wave-', char(area), '.png'], "-dpng", "-r300");

%% scatter plot
insertN(end) = inf;

FigResult = figure;
maximizeFig;
p_insert = zeros(length(insertN), 1);
for index = 1:length(insertN)
    mSubplot(2, length(insertN), index, "shape", "square-min", "margin_left", 0.2);
    scatter(RM_baseInsert{index}, RM_changeInsert{index}, 50, "black");
    [~, p_insert(index)] = ttest(RM_baseInsert{index}, RM_changeInsert{index});
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{before change} (\muV)");
    ylabel("RM_{change} (\muV)");
    title(['N=', num2str(insertN(index)), ' | p=', num2str(p_insert(index))]);
    addLines2Axes(gca);
end

%% tunning
RM_deltaInsert = cellfun(@(x, y) x - y, RM_changeInsert, RM_baseInsert, "UniformOutput", false);

mSubplot(2, 3, 5);
errorbar(1:length(insertN), cellfun(@mean, RM_deltaInsert), cellfun(@SE, RM_deltaInsert), "Color", "r", "LineWidth", 2);
xticks(1:length(insertN));
xlim([0, length(insertN)] + 0.5);
xticklabels(num2str(insertN));
xlabel("Number of inserted intervals (inserted ICI=4.06)");
ylabel("\DeltaRM_{change - before change} (\muV)");
title("Tuning of RM");

print(FigResult, ['..\Docs\Figures\Figure 3\tuning-', char(area), '.png'], "-dpng", "-r300");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*'))];
save(strcat("..\DATA\MAT DATA\figure\Res_RM_111-", area, ".mat"), ...
     "fs", ...
     "insertN", ...
     "chs2Avg", ...
     "window", ...
     "windowChange", ...
     "windowBase", ...
     params{:});

%% Figure result
% basic
res_windowChange = windowChange;
res_windowBase = windowBase;
res_insertN = insertN;

% wave
% align to change point
res_t = linspace(window(1), window(2), length(chData(1).chMean))' - (1000 + 4);
res_chMean0 = addfield(chData, "chMean", arrayfun(@(x) x.chMean', chData, "UniformOutput", false));
temp = {res_chMean0.chMean};
res_chMean  = cat(2, temp{:});
res_chErr0 = addfield(chData, "chErr", arrayfun(@(x) x.chErr', chData, "UniformOutput", false));
temp = {res_chErr0.chErr};
res_chErr  = cat(2, temp{:});

% tuning
res_tuning_mean = cellfun(@mean, RM_deltaInsert);
res_tuning_se = cellfun(@SE, RM_deltaInsert);
res_p_change_vs_base = p_insert;

params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 3\data-', char(area), '.mat'], params{:});
