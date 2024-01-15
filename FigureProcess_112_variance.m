ccc;
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\112\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, '112\chMean.mat', '');
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

run("config\avgConfig_Neuracle64.m");

%%
variance = unique([data{1}.var])';
variance(variance == 300) = []; % abort sigma=mu/300
RM_baseVar  = cell(length(variance), 1);
RM_changeVar = cell(length(variance), 1);
for index = 1:length(variance)
    if isnan(variance(index))
        temp = cellfun(@(x) x(isnan([x.var])).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = 'REG 4-4.06';
    else
        temp = cellfun(@(x) x([x.var] == variance(index)).chMean, data, "UniformOutput", false);
        chDataAll(index, 1).legend = ['\sigma=\mu/', num2str(variance(index))];
    end
    chDataAll(index, 1).chMean = calchMean(temp);
    chDataAll(index, 1).color = colors{index};

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseVar{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChange);
    RM_changeVar{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
end

plotRawWaveMultiEEG(chDataAll, window, [], EEGPos_Neuracle64);
scaleAxes("x", [1000 + 4, 1500]);
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
scaleAxes("x", [1000 + 4, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));
print(FigGrandAvg, ['..\Docs\Figures\Figure 6\wave-', char(area), '.png'], "-dpng", "-r300");

%% scatter plot
FigScatter = figure;
maximizeFig;
p_var = zeros(length(variance), 1);
for index = 1:length(variance)
    mSubplot(1, length(variance), index, "shape", "square-min", "margin_left", 0.15);
    scatter(RM_baseVar{index}, RM_changeVar{index}, 50, "black");
    [~, p_var(index)] = ttest(RM_baseVar{index}, RM_changeVar{index});
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{before change} (\muV)");
    ylabel("RM_{change} (\muV)");
    if ~isnan(variance(index))
        title(['\sigma=\mu/', num2str(variance(index)), ' | p=', num2str(roundn(p_var(index), -4))]);
    else
        title(['REG 4-4.06 | p=', num2str(roundn(p_var(index), -4))]);
    end
    addLines2Axes(gca);
end

print(FigScatter, ['..\Docs\Figures\Figure 6\scatter-', char(area), '.png'], "-dpng", "-r300");

%% tunning
RM_delta = cellfun(@(x, y) x - y, RM_changeVar, RM_baseVar, "UniformOutput", false);

FigTuning = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar(1:length(variance), cellfun(@mean, RM_delta), cellfun(@SE, RM_delta), "Color", "r", "LineWidth", 2);
xticks(1:length(variance));
xlim([0, length(variance)] + 0.5);
xticklabels(num2str(variance));
xlabel("\sigma=\mu/N");
ylabel("\DeltaRM_{change - before change} (\muV)");
title("Tuning of RM");

print(FigTuning, ['..\Docs\Figures\Figure 6\tuning-', char(area), '.png'], "-dpng", "-r300");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*'))];
save(strcat("..\DATA\MAT DATA\figure\Res_RM_112-", area, ".mat"), ...
     "fs", ...
     "variance", ...
     "chs2Avg", ...
     "window", ...
     "windowChange", ...
     "windowBase", ...
     params{:});

%% Figure result
% wave
res_t = t  - (1000 + 4);
res_chMean0 = addfield(chData, "chMean", arrayfun(@(x) x.chMean', chData, "UniformOutput", false));
temp = {res_chMean0.chMean};
res_chMean  = cat(2, temp{:});
res_chErr0 = addfield(chData, "chErr", arrayfun(@(x) x.chErr', chData, "UniformOutput", false));
temp = {res_chErr0.chErr};
res_chErr  = cat(2, temp{:});

% tuning
res_tuning_mean = cellfun(@mean, RM_delta);
res_tuning_se = cellfun(@SE, RM_delta);
res_p_change_vs_base = p_var;

params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 6\data-', char(area), '.mat'], params{:});

