ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\112\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, '112\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Variance Passive");

%% Params
colors = flip(cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false));

interval = 0;
run(fullfile(pwd, "config\plotConfig.m"));
run(fullfile(pwd, "config\avgConfig_Neuracle64.m"));

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%% Wave plot
variance = unique([data{1}.var])';
variance(variance == 300) = []; % abort sigma=mu/300
variance = flip(variance);
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
mPrint(FigGrandAvg, fullfile(FIGUREPATH, ['Grand average wave (', char(area), ').png']), "-dpng", "-r300");

%% Window config for RM
tIdx = t >= 1000 & t <= 1300;

[~, peakTime] = arrayfun(@(x) maxt(x.chMean(tIdx), t(tIdx)), chData);
windowChangePeak = peakTime + windowBand;
[~, troughTime] = arrayfun(@(x, y) mint(x.chMean(tIdx & t > y), t(tIdx & t > y)), chData, peakTime);
windowChangeTrough = troughTime + windowBand;

%% RM computation
RM_base = cell(length(variance), 1);
RM_changePeak = cell(length(variance), 1);
RM_changeTrough = cell(length(variance), 1);
for index = 1:length(variance)
    if isnan(variance(index))
        temp = cellfun(@(x) x(isnan([x.var])).chMean, data, "UniformOutput", false);
    else
        temp = cellfun(@(x) x([x.var] == variance(index)).chMean, data, "UniformOutput", false);
    end
    
    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_base{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChangePeak(index, :));
    RM_changePeak{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
    temp3 = cutData(temp, window, windowChangeTrough(index, :));
    RM_changeTrough{index} = cellfun(@(x) rmfcn(mean(x, 1)), temp3);
end

RM_delta_changePeak = cellfun(@(x, y) x - y, RM_changePeak, RM_base, "UniformOutput", false);
RM_delta_changeTrough = cellfun(@(x, y) x - y, RM_changeTrough, RM_base, "UniformOutput", false);

%% Statistics
[~, p_RM_changePeak_vs_base] = cellfun(@(x, y) ttest(x, y), RM_base, RM_changePeak);
[~, p_RM_changePeak_vs_control] = cellfun(@(x) ttest(RM_changePeak{1}, x), RM_changePeak);
[~, p_RM_changeTrough_vs_base] = cellfun(@(x, y) ttest(x, y), RM_base, RM_changeTrough);
[~, p_RM_changeTrough_vs_control] = cellfun(@(x) ttest(RM_changeTrough{1}, x), RM_changeTrough);

%% Tunning plot
variance(isnan(variance)) = 0;

FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(variance)) - 0.05, cellfun(@mean, RM_delta_changePeak), cellfun(@SE, RM_delta_changePeak), "Color", "r", "LineWidth", 2, "DisplayName", "Peak");
hold on;
errorbar((1:length(variance)) + 0.05, cellfun(@mean, RM_delta_changeTrough), cellfun(@SE, RM_delta_changeTrough), "Color", "b", "LineWidth", 2, "DisplayName", "Trough");
legend("Location", "northwest");
xticks(1:length(variance));
xlim([0, length(variance)] + 0.5);
temp = arrayfun(@(x) ['\mu/', num2str(x)], variance, "UniformOutput", false);
temp{1} = '0';
xticklabels(temp);
xlabel("Insert ICI number");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

mPrint(FigTuning, fullfile(FIGUREPATH, ['RM tuning (', char(area), ').png']), "-dpng", "-r300");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*')); ...
          fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res variance (', char(area), ').mat'], ...
     "fs", ...
     "variance", ...
     "chs2Avg", ...
     params{:});
