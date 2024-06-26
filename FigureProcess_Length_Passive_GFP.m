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

windowNew = [-1500, 1000]; % ms
nperm = 1e3;
alphaVal = 0.025;

EEGPos = EEGPos_Neuracle64;
chs2Ignore = EEGPos.ignore;

%% Window config for RM
% change response
windowChange = [50, 350];

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%% Wave plot
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
gfp = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) getOr(x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG"), "chMean"), data, "UniformOutput", false);
    
    % segment and align to change point
    timeShift = 1000 + roundn(ICIsREG(dIndex), 0);
    temp = cutData(temp, window, windowNew + timeShift);

    gfp{dIndex} = cellfun(@(x) calGFP(x, chs2Ignore), temp, "UniformOutput", false);

    chDataREG(dIndex, 1).chMean = calchMean(gfp{dIndex});
    chDataREG(dIndex, 1).color = colors{dIndex};
    chDataREG(dIndex, 1).legend = ['REG ', num2str(roundn(ICIsREG(dIndex), 0)), '-', num2str(ICIsREG(dIndex))];
end

t = linspace(windowNew(1), windowNew(2), size(chDataREG(1).chMean, 2));
gfp = cellfun(@cell2mat, gfp, "UniformOutput", false);
plotRawWaveMulti(chDataREG, windowNew);
scaleAxes("x", [-100, 500]);
scaleAxes("y", "on");
addLines2Axes(struct("X", 0));

%% RM computation
RM_baseREG  = cell(length(ICIsREG), 1);
RM_changePeak = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    timeShift = 1000 + roundn(ICIsREG(dIndex), 0);
    temp1 = cutData(gfp{dIndex}, windowNew, windowBase - timeShift);
    RM_baseREG{dIndex} = mean(temp1, 2);
    temp2 = cutData(gfp{dIndex}, windowNew, windowChange);
    RM_changePeak{dIndex} = max(temp2, [], 2);
end

RM_delta_changePeakREG = cellfun(@(x, y) x - y, RM_changePeak, RM_baseREG, "UniformOutput", false);

%% Statistics
[~, p_RM_changePeakREG_vs_base] = cellfun(@(x, y) ttest(x, y), RM_baseREG, RM_changePeak);

%% Tunning plot
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changePeakREG), cellfun(@SE, RM_delta_changePeakREG), "Color", "r", "LineWidth", 2);
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaGFP (\muV)");
title("Tuning of GFP_{change}");
