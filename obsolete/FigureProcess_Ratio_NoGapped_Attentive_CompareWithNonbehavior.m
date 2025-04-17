ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\active1\chMeanAll.mat')); % all trials
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'active1\chMeanAll.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio No-Gapped Attentive (Independent)");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

nperm = 1e3;
alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

rms = path2func(fullfile(matlabroot, "toolbox/matlab/datafun/rms.m"));
rmfcn = @mean;

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

% For context comparison
load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");
data = data(subjectIdxA1);

%% Wave and GFP
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
gfpREG = cell(length(ICIsREG), 1);
dataAvg = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    
    % Normalize
    temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
    
    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).chErr = calchErr(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(ICIsREG(1)), '-', num2str(ICIsREG(dIndex))];

    gfpREG{dIndex} = calGFP(temp, EEGPos.ignore);
    gfpREG{dIndex} = cat(1, gfpREG{dIndex}{:});
    gfpDataREG(dIndex, 1).chMean = mean(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).chErr = SE(gfpREG{dIndex}, 1);
    gfpDataREG(dIndex, 1).color = colors{dIndex};
    gfpDataREG(dIndex, 1).legend = ['REG ', num2str(ICIsREG(1)), '-', num2str(ICIsREG(dIndex))];

    dataAvg{dIndex} = cell2mat(cellfun(@(x) mean(x(chs2Avg, :), 1), temp, "UniformOutput", false));
end

%% Determine window for cP1-cN2 change response by channel-averaging
chData = chDataREG_All;
chData = addfield(chData, "chMean", cellfun(@(x) mean(x, 1), dataAvg, "UniformOutput", false));
chData = addfield(chData, "chErr", cellfun(@(x) SE(x, 1), dataAvg, "UniformOutput", false));
plotRawWaveMulti(chData, window);
title(['Grand-average wave in ', char(area)]);
xlabel("Time (ms)");
ylabel("Response (\muV)");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
scaleAxes("x", [900, 1600]);
scaleAxes("y", "on");

%% Determine time window for cP1 and cN2
tcP1 = [1180; 1180; 1144; 1134; 1117];
tcN2 = [1323; 1313; 1287; 1269; 1247];

%% RM computation
% REG
RM_baseREG = calRM(dataAvg, window, windowBase, @(x) rmfcn(x, 2));

RM_changeP_REG = rowFcn(@(x, y) calRM(y{1}, window, x + windowBand, @(x) rmfcn(x, 2)), tcP1, dataAvg, "UniformOutput", false);
RM_changeN_REG = rowFcn(@(x, y) calRM(y{1}, window, x + windowBand, @(x) rmfcn(x, 2)), tcN2, dataAvg, "UniformOutput", false);
RM_delta_changeP_REG = cellfun(@(x, y) x - y, RM_changeP_REG, RM_baseREG, "UniformOutput", false);
RM_delta_changeN_REG = cellfun(@(x, y) x - y, RM_changeN_REG, RM_baseREG, "UniformOutput", false);

%% Statistics
Tail = "both";
[~, p_RM_changeP_REG_vs_base]    = cellfun(@(x, y) ttest(x, y, "Tail", Tail), RM_baseREG, RM_changeP_REG);
[~, p_RM_changeP_REG_vs_control] = cellfun(@(x) ttest(RM_delta_changeP_REG{1}, x, "Tail", Tail), RM_delta_changeP_REG);

[~, p_RM_changeN_REG_vs_base]    = cellfun(@(x, y) ttest(x, y, "Tail", Tail), RM_baseREG, RM_changeN_REG);
[~, p_RM_changeN_REG_vs_control] = cellfun(@(x) ttest(RM_delta_changeN_REG{1}, x, "Tail", Tail), RM_delta_changeN_REG);

%% Tuning
X = 1:length(ICIsREG);
Y_cP1 = cellfun(@mean, RM_delta_changeP_REG);
E_cP1 = cellfun(@SE, RM_delta_changeP_REG);
Y_cN2 = cellfun(@mean, RM_delta_changeN_REG);
E_cN2 = cellfun(@SE, RM_delta_changeN_REG);

FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar(X - 0.05, Y_cP1, E_cP1, "Color", "r", "LineWidth", 2, "DisplayName", "cP1");
hold on;
errorbar(X + 0.05, Y_cN2, E_cN2, "Color", "b", "LineWidth", 2, "DisplayName", "cN2");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

%% save for comparison
params0 = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
           fieldnames(getVarsFromWorkspace('p_\W*')); ...
           fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res A1 compare (', char(area), ').mat'], ...
     "fs", ...
     "ICIsREG", ...
     "chData", ...
     params0{:});

%% Results of figures
% Figure 1
