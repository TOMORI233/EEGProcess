ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive1\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'passive1\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Length Passive");

%% Params
colors = flip(cellfun(@(x) x / 255, {[0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false));

interval = 0;
run(fullfile(pwd, "config\plotConfig.m"));
run(fullfile(pwd, "config\avgConfig_Neuroscan64.m"));

windowNew = [-500, 1000]; % ms

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%% Wave plot
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) getOr(x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG"), "chMean"), data, "UniformOutput", false);
    
    % segment and align to change point
    timeShift = 1000 + roundn(ICIsREG(dIndex), 0);
    temp = cutData(temp, window, windowNew + timeShift);

    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(roundn(ICIsREG(dIndex), 0)), '-', num2str(ICIsREG(dIndex))];
end

plotRawWaveMultiEEG(chDataREG_All, windowNew, [], EEGPos_Neuroscan64);
scaleAxes("x", [-100, 500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
chDataREG = addfield(chDataREG_All, "chMean", chMean);
chDataREG = addfield(chDataREG, "chErr", chErr);
t = linspace(windowNew(1), windowNew(2), length(chMean{1}))';
FigGrandAvg = plotRawWaveMulti(chDataREG, windowNew, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [-100, 500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));
mPrint(FigGrandAvg, fullfile(FIGUREPATH, ['Grand average wave (', char(area), ').png']), "-dpng", "-r300");

%% Window config for RM
tIdx = t >= 50 & t <= 300;

[~, peakTime] = arrayfun(@(x) maxt(x.chMean(tIdx), t(tIdx)), chDataREG);
windowChangePeakREG = peakTime + windowBand;
[~, troughTime] = arrayfun(@(x, y) mint(x.chMean(tIdx & t > y), t(tIdx & t > y)), chDataREG, peakTime);
windowChangeTroughREG = troughTime + windowBand;

%% RM computation
RM_baseREG  = cell(length(ICIsREG), 1);
RM_changePeakREG = cell(length(ICIsREG), 1);
RM_changeTroughREG = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) getOr(x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG"), "chMean"), data, "UniformOutput", false);
    
    % segment and align to change point
    timeShift = 1000 + roundn(ICIsREG(dIndex), 0);
    temp = cutData(temp, window, windowNew + timeShift);

    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, windowNew, windowBase - timeShift);
    RM_baseREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, windowNew, windowChangePeakREG(dIndex, :));
    RM_changePeakREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
    temp3 = cutData(temp, windowNew, windowChangeTroughREG(dIndex, :));
    RM_changeTroughREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp3);
end

RM_delta_changePeakREG = cellfun(@(x, y) x - y, RM_changePeakREG, RM_baseREG, "UniformOutput", false);
RM_delta_changeTroughREG = cellfun(@(x, y) x - y, RM_changeTroughREG, RM_baseREG, "UniformOutput", false);

%% Statistics
[~, p_RM_changePeakREG_vs_base] = cellfun(@(x, y) ttest2(x, y), RM_baseREG, RM_changePeakREG);
[~, p_RM_changeTroughREG_vs_base] = cellfun(@(x, y) ttest2(x, y), RM_baseREG, RM_changeTroughREG);

%% Tunning plot
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changePeakREG), cellfun(@SE, RM_delta_changePeakREG), "Color", "r", "LineWidth", 2, "DisplayName", "Peak");
hold on;
errorbar((1:length(ICIsREG)) + 0.05, cellfun(@mean, RM_delta_changeTroughREG), cellfun(@SE, RM_delta_changeTroughREG), "Color", "b", "LineWidth", 2, "DisplayName", "Trough");
legend("Location", "northeast");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

mPrint(FigTuning, fullfile(FIGUREPATH, ['RM tuning (', char(area), ').png']), "-dpng", "-r300");

%% save
params = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*')); ...
          fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res P1 (', char(area), ').mat'], ...
     "fs", ...
     "ICIsREG", ...
     "chs2Avg", ...
     "windowNew", ...
     params{:});
