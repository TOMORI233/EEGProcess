ccc;

MATPATHsComa = dir("..\DATA\MAT DATA - coma\temp\**\151\chMean.mat");
MATPATHsComa = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHsComa, "UniformOutput", false);

MATPATHsHealthy = dir("..\DATA\MAT DATA - extra\temp\**\113\chMean.mat");
MATPATHsHealthy = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHsHealthy, "UniformOutput", false);

%% Params
colors = {'k', 'b', 'r'};

interval = 0;
run(fullfile(pwd, "config\plotConfig.m"));
run(fullfile(pwd, "config\avgConfig_Neuracle64.m"));

chs2Avg = 26;

windowOnset = [0, 300];
windowChange = [1000, 1300];
windowBase0 = [-500, -300];
windowBase = [800, 1000];

% rmfcn = path2func(fullfile(matlabroot, "toolbox/signal/signal/rms.m"));

%% 
MATPATHsComa(contains(MATPATHsComa, "2024032901")) = [];
[~, temp] = cellfun(@(x) getLastDirPath(x, 2), MATPATHsComa, "UniformOutput", false);
subjectIDsComa = cellfun(@(x) x{1}, temp, "UniformOutput", false);

%%
window = load(MATPATHsComa{1}).window;
dataComa = cellfun(@(x) load(x).chData, MATPATHsComa, "UniformOutput", false);
dataHealthy = cellfun(@(x) load(x).chData, MATPATHsHealthy, "UniformOutput", false);

dataComa = cellfun(@(x) x([1, 3, 4]), dataComa, "UniformOutput", false);
dataHealthy = cellfun(@(x) x([1, 2, 4]), dataHealthy, "UniformOutput", false);

%% 
% for index = 1:length(dataComa)
%     close all;
%     chDataTemp.chMean = (dataComa{index}(1).chMean + dataComa{index}(2).chMean + dataComa{index}(3).chMean) / 3;
%     chDataTemp.color = 'r';
%     plotRawWaveMultiEEG(chDataTemp, window, subjectIDsComa{index}, EEGPos_Neuracle64);
%     scaleAxes("x", [-500, 1000]);
%     scaleAxes("y", "on", "symOpt", "max");
%     addLines2Axes(struct("X", 0));
% end
idxOnset = ismember(subjectIDsComa, cellstr(readlines("subjects.txt")));

%% 
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataComa(idxOnset), "UniformOutput", false);
chDataComaWithOnsetAll(1).chMean = calchMean(temp);
chDataComaWithOnsetAll(1).chErr  = calchErr(temp);
chDataComaWithOnsetAll(1).color  = colors{1};
chDataComaWithOnsetAll(1).legend = "REG 4-4";

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataComa(idxOnset), "UniformOutput", false);
chDataComaWithOnsetAll(2).chMean = calchMean(temp);
chDataComaWithOnsetAll(2).chErr  = calchErr(temp);
chDataComaWithOnsetAll(2).color  = colors{2};
chDataComaWithOnsetAll(2).legend = "REG 4-5";

temp = cellfun(@(x) x([x.freq] == 200).chMean, dataComa(idxOnset), "UniformOutput", false);
chDataComaWithOnsetAll(3).chMean = calchMean(temp);
chDataComaWithOnsetAll(3).chErr  = calchErr(temp);
chDataComaWithOnsetAll(3).color  = colors{3};
chDataComaWithOnsetAll(3).legend = "PT 250-200";

plotRawWaveMultiEEG(chDataComaWithOnsetAll, window, [], EEGPos_Neuracle64);
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataComaWithOnsetAll, "UniformOutput", false);
t = linspace(window(1), window(2), length(chMean{1}))';
chDataComaWithOnset = addfield(chDataComaWithOnsetAll, "chMean", chMean);
chDataComaWithOnset = rmfield(chDataComaWithOnset, "chErr");
plotRawWaveMulti(chDataComaWithOnset, window);
title(['Grand-average wave across ', char(area), ' areas | Subjects with impaired consciousness | With onset response (N=', num2str(sum(idxOnset)), ')']);
addLines2Axes(struct("X", {0; 1000; 2000}));

%% 
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataHealthy, "UniformOutput", false);
chDataHealthyAll(1).chMean = calchMean(temp);
chDataHealthyAll(1).chErr  = calchErr(temp);
chDataHealthyAll(1).color  = colors{1};
chDataHealthyAll(1).legend = "REG 4-4";

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataHealthy, "UniformOutput", false);
chDataHealthyAll(2).chMean = calchMean(temp);
chDataHealthyAll(2).chErr  = calchErr(temp);
chDataHealthyAll(2).color  = colors{2};
chDataHealthyAll(2).legend = "REG 4-5";

temp = cellfun(@(x) x([x.freq] == 200).chMean, dataHealthy, "UniformOutput", false);
chDataHealthyAll(3).chMean = calchMean(temp);
chDataHealthyAll(3).chErr  = calchErr(temp);
chDataHealthyAll(3).color  = colors{3};
chDataHealthyAll(3).legend = "PT 250-200";

plotRawWaveMultiEEG(chDataHealthyAll, window, [], EEGPos_Neuracle64);
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataHealthyAll, "UniformOutput", false);
chDataHealthy = addfield(chDataHealthyAll, "chMean", chMean);
chDataHealthy = rmfield(chDataHealthy, "chErr");
plotRawWaveMulti(chDataHealthy, window);
title(['Grand-average wave across ', char(area), ' areas | Healthy subjects | N=', num2str(length(dataHealthy))]);
addLines2Axes(struct("X", {0; 1000; 2000}));

%% RM computation
tIdxBase0 = t >= windowBase0(1) & t <= windowBase0(2);
tIdxBase = t >= windowBase(1) & t <= windowBase(2);
tIdxOnset = t >= windowOnset(1) & t <= windowOnset(2);
tIdxChange = t >= windowChange(1) & t <= windowChange(2);

[~, temp] = maxt(chDataComaWithOnset(2).chMean(tIdxOnset), t(tIdxOnset));
tIdxOnsetComa = t >= temp + windowBand(1) & t <= temp + windowBand(2);

[~, temp] = maxt(chDataHealthy(2).chMean(tIdxOnset), t(tIdxOnset));
tIdxOnsetHealthy = t >= temp + windowBand(1) & t <= temp + windowBand(2);

[~, temp] = maxt(chDataHealthy(2).chMean(tIdxChange), t(tIdxChange));
tIdxChangeHealthy = t >= temp + windowBand(1) & t <= temp + windowBand(2);

RM_base0_coma = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxBase0), 1)), x), dataComa, "UniformOutput", false);
RM_base0_healthy = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxBase0), 1)), x), dataHealthy, "UniformOutput", false);

RM_base_coma = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxBase), 1)), x), dataComa, "UniformOutput", false);
RM_base_healthy = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxBase), 1)), x), dataHealthy, "UniformOutput", false);

RM_onset_coma = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxOnsetComa), 1)), x), dataComa, "UniformOutput", false);
RM_onset_healthy = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxOnsetComa), 1)), x), dataHealthy, "UniformOutput", false);

RM_change_coma = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxChangeHealthy), 1)), x), dataComa, "UniformOutput", false);
RM_change_healthy = cellfun(@(x) arrayfun(@(y) rmfcn(mean(y.chMean(chs2Avg, tIdxChangeHealthy), 1)), x), dataHealthy, "UniformOutput", false);

RM_delta_onset_coma = cellfun(@(x, y) x - y, RM_onset_coma, RM_base0_coma, "UniformOutput", false);
RM_delta_onset_healthy = cellfun(@(x, y) x - y, RM_onset_healthy, RM_base0_healthy, "UniformOutput", false);

RM_delta_change_coma = cellfun(@(x, y) x - y, RM_change_coma, RM_base_coma, "UniformOutput", false);
RM_delta_change_healthy = cellfun(@(x, y) x - y, RM_change_healthy, RM_base_healthy, "UniformOutput", false);

figure;
mSubplot(1, 2, 1, "shape", "square-min");
hold on;
X = cellfun(@(x) x(2), RM_delta_onset_coma(idxOnset));
Y = cellfun(@(x) x(2), RM_delta_change_coma(idxOnset));
[~, p_coma_withOnset] = ttest(X, Y);
scatter(X, Y, 100, "blue", "filled", "DisplayName", "Impaired consciousness (with onset response)");
X = cellfun(@(x) x(2), RM_delta_onset_coma(~idxOnset));
Y = cellfun(@(x) x(2), RM_delta_change_coma(~idxOnset));
[~, p_coma_withoutOnset] = ttest(X, Y);
scatter(X, Y, 100, "blue", "DisplayName", "Impaired consciousness (without onset response)");
X = cellfun(@(x) x(2), RM_delta_onset_healthy);
Y = cellfun(@(x) x(2), RM_delta_change_healthy);
[~, p_healthy] = ttest(X, Y);
scatter(X, Y, 100, "red", "filled", "DisplayName", "Healthy");
syncXY;
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));
xlabel("\DeltaRM_{onset} of REG 4-5");
ylabel("\DeltaRM_{change} of REG 4-5");
legend;

mSubplot(2, 2, 2);
temp = {cellfun(@(x) x(2) - x(1), RM_delta_change_coma(idxOnset));
        cellfun(@(x) x(2) - x(1), RM_delta_change_coma(~idxOnset));
        cellfun(@(x) x(2) - x(1), RM_delta_change_healthy)};
mHistogram(temp, "DisplayName", {'Impaired consciousness (with onset response)', ...
                                 'Impaired consciousness (without onset response)', ...
                                 'Healthy'}, ...
                 "FaceColor", {'b', 'none', 'r'}, ...
                 "EdgeColor", {'b', 'b', 'r'}, ...
                 "LineWidth", 1);
[~, p_comaWithOnset_vs_healthy] = ttest2(temp{1}, temp{3});
xlabel("\DeltaRM");
ylabel("Counts");
title(['Two-sample T-test p=', num2str(p_comaWithOnset_vs_healthy)]);

%% Example
grandAverageWave = cellfun(@(x) arrayfun(@(y) mean(y.chMean(chs2Avg, :), 1), x, "UniformOutput", false), dataComa, "UniformOutput", false);
exampleSubject = "2024040801";
idx = strcmp(subjectIDsComa, exampleSubject);
t1 = t - 1000;
temp = cat(1, grandAverageWave{idx}{1:2})';
figure;
mSubplot(1, 1, 1);
plot(t1, temp(:, 1), "Color", "k", "LineWidth", 2, "DisplayName", "REG 4-4");
hold on;
plot(t1, temp(:, 2), "Color", "r", "LineWidth", 2, "DisplayName", "REG 4-5");
xlim([-1000, 1000]);
addLines2Axes(gca, struct("X", {0; 1000; 2000}));
xlabel("Time (ms)");
ylabel("Response (\muV)");
title(strcat("Grand-average wave of subject", exampleSubject));

%% 
temp = cat(1, chDataHealthy(1:2).chMean)';
temp = cat(1, chDataComaWithOnset(1:2).chMean)';