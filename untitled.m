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

windowOnset = [0, 300];
windowChange = [1000, 1300];
windowBase0 = [-500, -300];
windowBase = [800, 1000];
windowBand = [-25, 25];

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

idxOnset = ismember(subjectIDsComa, cellstr(readlines("subjects.txt")));
t = linspace(window(1), window(2), size(dataComa{1}(1).chMean, 2));

%% 
gfpComa = cellfun(@(x) calGFP(x(2).chMean), dataComa, "UniformOutput", false);
gfpHealthy = cellfun(@(x) calGFP(x(2).chMean), dataHealthy, "UniformOutput", false);

figure;
mSubplot(3, 2, 3);
hold on;
for index = 1:length(gfpComa)
    if idxOnset(index)
        plot(t, gfpComa{index}, "Color", "b", "LineWidth", 1);
    else
        plot(t, gfpComa{index}, "Color", [.5, .5, .5], "LineWidth", 1);
    end
end
plot(t, mean(cat(1, gfpComa{idxOnset}), 1), "Color", "r", "LineWidth", 2);
xlabel("Time (ms)");
ylabel("GFP (\muV)");
title("Impaired consciousness");

mSubplot(3, 2, 4);
hold on;
for index = 1:length(gfpHealthy)
    plot(t, gfpHealthy{index}, "Color", "b", "LineWidth", 1);
end
plot(t, mean(cat(1, gfpHealthy{:}), 1), "Color", "r", "LineWidth", 2);
xlabel("Time (ms)");
ylabel("GFP (\muV)");
title("Healthy");

addLines2Axes(struct("X", {0; 1000; 2000}));

%% RM computation
tIdxBase0 = t >= windowBase0(1) & t <= windowBase0(2);
tIdxBase = t >= windowBase(1) & t <= windowBase(2);
tIdxOnset = t >= windowOnset(1) & t <= windowOnset(2);
tIdxChange = t >= windowChange(1) & t <= windowChange(2);

[~, temp] = cellfun(@(x) maxt(x(tIdxOnset), t(tIdxOnset)), gfpComa, "UniformOutput", false);
tIdxOnsetComa = cellfun(@(x) t >= x + windowBand(1) & t <= x + windowBand(2), temp, "UniformOutput", false);

[~, temp] = cellfun(@(x) maxt(x(tIdxOnset), t(tIdxOnset)), gfpHealthy, "UniformOutput", false);
tIdxOnsetHealthy = cellfun(@(x) t >= x + windowBand(1) & t <= x + windowBand(2), temp, "UniformOutput", false);

[~, temp] = cellfun(@(x) maxt(x(tIdxChange), t(tIdxChange)), gfpComa, "UniformOutput", false);
tIdxChangeComa = cellfun(@(x) t >= x + windowBand(1) & t <= x + windowBand(2), temp, "UniformOutput", false);

[~, temp] = cellfun(@(x) maxt(x(tIdxChange), t(tIdxChange)), gfpHealthy, "UniformOutput", false);
tIdxChangeHealthy = cellfun(@(x) t >= x + windowBand(1) & t <= x + windowBand(2), temp, "UniformOutput", false);

RM_base0_coma = cellfun(@(x) mean(x(tIdxBase0)), gfpComa);
RM_base0_healthy = cellfun(@(x) mean(x(tIdxBase0)), gfpHealthy);

RM_base_coma = cellfun(@(x) mean(x(tIdxBase)), gfpComa);
RM_base_healthy = cellfun(@(x) mean(x(tIdxBase)), gfpHealthy);

RM_onset_coma = cellfun(@(x, y) mean(x(y)), gfpComa, tIdxOnsetComa);
RM_onset_healthy = cellfun(@(x, y) mean(x(y)), gfpHealthy, tIdxOnsetHealthy);

RM_change_coma = cellfun(@(x, y) mean(x(y)), gfpComa, tIdxChangeComa);
RM_change_healthy = cellfun(@(x, y) mean(x(y)), gfpHealthy, tIdxChangeHealthy);

RM_delta_onset_coma = RM_onset_coma - RM_base0_coma;
RM_delta_change_coma = RM_change_coma - RM_base_coma;
RM_delta_onset_healthy = RM_onset_healthy - RM_base0_healthy;
RM_delta_change_healthy = RM_change_healthy - RM_base_healthy;

%% plot
figure;
mSubplot(1, 1, 1, "shape", "square-min");
hold on;
X = RM_delta_onset_coma(idxOnset);
Y = RM_delta_change_coma(idxOnset);
[~, p_coma_withOnset] = ttest(X, Y);
scatter(X, Y, 100, "blue", "filled", "DisplayName", "Impaired consciousness (with onset response)");
X = RM_delta_onset_coma(~idxOnset);
Y = RM_delta_change_coma(~idxOnset);
[~, p_coma_withoutOnset] = ttest(X, Y);
scatter(X, Y, 100, "blue", "DisplayName", "Impaired consciousness (without onset response)");
X = RM_delta_onset_healthy;
Y = RM_delta_change_healthy;
[~, p_healthy] = ttest(X, Y);
scatter(X, Y, 100, "red", "filled", "DisplayName", "Healthy");
syncXY;
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));
xlabel("\DeltaRM_{onset} of Reg_{4-5}");
ylabel("\DeltaRM_{change} of Reg_{4-5}");
legend;

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
