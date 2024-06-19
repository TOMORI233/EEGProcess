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

windowOnset = [50, 250];
windowChange = [1080, 1280];
windowBase0 = [-500, -300];
windowBase = [800, 1000];

nperm = 1e3;
alphaVal = 0.01;

% rmfcn = path2func(fullfile(matlabroot, "toolbox/signal/signal/rms.m"));

%% 
tb = readtable("CRS-R.xlsx");
idx = contains(MATPATHsComa, ["2024032901"]);
MATPATHsComa(idx) = [];
tb(idx, :) = [];

id = cellstr(num2str(tb.id));
scoreTotal = tb.score;
scoreAuditory = tb.a_score;

[~, temp] = cellfun(@(x) getLastDirPath(x, 2), MATPATHsComa, "UniformOutput", false);
subjectIDsComa = cellfun(@(x) x{1}, temp, "UniformOutput", false);

%%
window = load(MATPATHsComa{1}).window;
dataComa = cellfun(@(x) load(x).chData, MATPATHsComa, "UniformOutput", false);
dataHealthy = cellfun(@(x) load(x).chData, MATPATHsHealthy, "UniformOutput", false);

dataComa = cellfun(@(x) x([1, 3]), dataComa, "UniformOutput", false);
dataHealthy = cellfun(@(x) x([1, 2]), dataHealthy, "UniformOutput", false);

idxOnset = ismember(subjectIDsComa, cellstr(readlines("subjects.txt")));
t = linspace(window(1), window(2), size(dataComa{1}(1).chMean, 2));

%% 
chs2Ignore = 60:64;
gfpComa = cellfun(@(x) cell2mat(calGFP({x.chMean}', chs2Ignore)), dataComa, "UniformOutput", false);
gfpHealthy = cellfun(@(x) cell2mat(calGFP({x.chMean}', chs2Ignore)), dataHealthy, "UniformOutput", false);

figure;
for index0 = 1:length(dataComa{1})
    mSubplot(length(dataComa{1}), 2, 2 * (index0 - 1) + 1, "margin_bottom", 0.25);
    hold on;
    for index = 1:length(gfpComa)
        if idxOnset(index)
            plot(t, gfpComa{index}(index0, :), "Color", "b", "LineWidth", 1);
        else
            plot(t, gfpComa{index}(index0, :), "Color", [.5, .5, .5], "LineWidth", 1);
        end
    end
    temp = cellfun(@(x) x(index0, :), gfpComa(idxOnset), "UniformOutput", false);
    temp = mean(cat(1, temp{:}), 1);
    plot(t, temp, "Color", "r", "LineWidth", 2);
    temp = cellfun(@(x) x(index0, :), gfpComa(~idxOnset), "UniformOutput", false);
    temp = mean(cat(1, temp{:}), 1);
    plot(t, temp, "Color", "k", "LineWidth", 2);
    xlabel("Time (ms)");
    ylabel("GFP (\muV)");
    title("Impaired consciousness");
    
    mSubplot(length(dataComa{1}), 2, 2 * index0, "margin_bottom", 0.25);
    hold on;
    for index = 1:length(gfpHealthy)
        plot(t, gfpHealthy{index}(index0, :), "Color", "b", "LineWidth", 1);
    end
    temp = cellfun(@(x) x(index0, :), gfpHealthy, "UniformOutput", false);
    temp = mean(cat(1, temp{:}), 1);
    plot(t, temp, "Color", "r", "LineWidth", 2);
    xlabel("Time (ms)");
    ylabel("GFP (\muV)");
    title("Healthy");
end

addLines2Axes(struct("X", {0; 1000; 2000}));

figure;
plotSize = autoPlotSize(length(gfpComa));
for index = 1:length(gfpComa)
    subplot(plotSize(1), plotSize(2), index);
    if ~idxOnset(index)
        plot(t, gfpComa{index}(2, :), "Color", "k", "LineWidth", 2);
    else
        plot(t, gfpComa{index}(2, :), "Color", "r", "LineWidth", 2);
    end
    set(gca, "XLimitMethod", "tight");
    title(subjectIDsComa{index});
end
addLines2Axes(struct("X", {0; 1000; 2000}));

figure;
plotSize = autoPlotSize(length(gfpHealthy));
for index = 1:length(gfpHealthy)
    subplot(plotSize(1), plotSize(2), index);
    plot(t, gfpHealthy{index}(2, :), "Color", "r", "LineWidth", 2);
    set(gca, "XLimitMethod", "tight");
end
addLines2Axes(struct("X", {0; 1000; 2000}));

%% 
% permute at sample level
temp1 = cell2mat(cellfun(@(x) x(1, :), gfpHealthy, "UniformOutput", false)); % subject_sample
temp2 = cell2mat(cellfun(@(x) x(2, :), gfpHealthy, "UniformOutput", false));
% temp1 = cell2mat(cellfun(@(x) x(1, :), gfpComa(~idxOnset), "UniformOutput", false)); % subject_sample
% temp2 = cell2mat(cellfun(@(x) x(2, :), gfpComa(~idxOnset), "UniformOutput", false));
p = wavePermTest(temp1, temp2, nperm, "Tail", "right", "Type", "GFP", "chs2Ignore", chs2Ignore);
h = fdr_bh(p, alphaVal, 'dep');
h = double(h);
h(h == 0) = nan;
h(h == 1) = 0;

figure;
plot(t, mean(temp1, 1)', "Color", "k", "LineWidth", 2);
hold on;
plot(t, mean(temp2, 1)', "Color", "r", "LineWidth", 2);
scatter(t, h', 50, "yellow", "filled");
addLines2Axes(gca, struct("X", {0; 1000; 2000}));

%% RM computation
tIdxBase0 = t >= windowBase0(1) & t <= windowBase0(2);
tIdxBase = t >= windowBase(1) & t <= windowBase(2);
tIdxOnset = t >= windowOnset(1) & t <= windowOnset(2);
tIdxChange = t >= windowChange(1) & t <= windowChange(2);

RM_base0_coma = cellfun(@(x) mean(x(:, tIdxBase0), 2), gfpComa, "UniformOutput", false);
RM_base0_healthy = cellfun(@(x) mean(x(:, tIdxBase0), 2), gfpHealthy, "UniformOutput", false);

RM_base_coma = cellfun(@(x) mean(x(:, tIdxBase), 2), gfpComa, "UniformOutput", false);
RM_base_healthy = cellfun(@(x) mean(x(:, tIdxBase), 2), gfpHealthy, "UniformOutput", false);

RM_onset_coma = cellfun(@(x) max(x(:, tIdxOnset), [], 2), gfpComa, "UniformOutput", false);
RM_onset_healthy = cellfun(@(x) max(x(:, tIdxOnset), [], 2), gfpHealthy, "UniformOutput", false);

RM_change_coma = cellfun(@(x) max(x(:, tIdxChange), [], 2), gfpComa, "UniformOutput", false);
RM_change_healthy = cellfun(@(x) max(x(:, tIdxChange), [], 2), gfpHealthy, "UniformOutput", false);

RM_delta_onset_coma     = changeCellRowNum(cellfun(@(x, y) x - y, RM_onset_coma, RM_base0_coma, "UniformOutput", false));
RM_delta_change_coma    = changeCellRowNum(cellfun(@(x, y) x - y, RM_change_coma, RM_base_coma, "UniformOutput", false));
RM_delta_onset_healthy  = changeCellRowNum(cellfun(@(x, y) x - y, RM_onset_healthy, RM_base0_healthy, "UniformOutput", false));
RM_delta_change_healthy = changeCellRowNum(cellfun(@(x, y) x - y, RM_change_healthy, RM_base_healthy, "UniformOutput", false)); 

%% plot
figure;
mSubplot(1, 2, 1, "shape", "square-min");
hold on;
temp = mean(cat(2, RM_delta_onset_coma{2}), 2);
X = temp(idxOnset);
Y = RM_delta_change_coma{2}(idxOnset);
scatter(X, Y, 100, "blue", "filled", "DisplayName", "Impaired consciousness (with onset response)");
X = temp(~idxOnset);
Y = RM_delta_change_coma{2}(~idxOnset);
scatter(X, Y, 100, "filled", "MarkerFaceColor", [.5, .5, .5], "DisplayName", "Impaired consciousness (without onset response)");
X = mean(cat(2, RM_delta_onset_healthy{2}), 2);
Y = RM_delta_change_healthy{2};
scatter(X, Y, 100, "red", "filled", "DisplayName", "Healthy");
syncXY;
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));
xlabel("RM_{onset}");
ylabel("RM_{change}");
legend;

mSubplot(2, 2, 2, "margin_top", 0.1, "margin_bottom", 0.1);
temp = mean(cat(2, RM_delta_onset_coma{2}), 2);
mHistogram({temp(idxOnset); ...
            temp(~idxOnset); ...
            mean(cat(2, RM_delta_onset_healthy{2}), 2)}, ...
            "FaceColor", {'b'; [.5, .5, .5]; 'r'}, ...
            "BinWidth", 0.5);
xlabel("RM_{onset}");
ylabel("Count");
[~, p1] = ttest2(temp, mean(cat(2, RM_delta_onset_healthy{2}), 2));

mSubplot(2, 2, 4, "margin_top", 0.1, "margin_bottom", 0.1);
mHistogram({RM_delta_change_coma{2}(idxOnset); ...
            RM_delta_change_coma{2}(~idxOnset); ...
            RM_delta_change_healthy{2}}, ...
            "FaceColor", {'b'; [.5, .5, .5]; 'r'}, ...
            "BinWidth", 0.5);
xlabel("RM_{change}");
ylabel("Count");
[~, p2] = ttest2(RM_delta_change_coma{2}, RM_delta_change_healthy{2});

%% 
figure;
mSubplot(1, 2, 1, "shape", "square-min");
X = scoreAuditory;
Y = mean(cat(2, RM_delta_onset_coma{2}), 2);
scatter(X(~isnan(X) & idxOnset), Y(~isnan(X) & idxOnset), 100, "blue", "filled");
hold on;
scatter(X(~isnan(X) & ~idxOnset), Y(~isnan(X) & ~idxOnset), 100, "black", "filled");
xlabel("CRS-r score (Auditory)");
ylabel("RM_{onset}");

mSubplot(1, 2, 2, "shape", "square-min");
X = scoreTotal;
Y = mean(cat(2, RM_delta_onset_coma{2}), 2);
[r_corr1, p_corr1] = corr(X(~isnan(X)), Y(~isnan(X)), "type", "Pearson");
scatter(X(~isnan(X) & idxOnset), Y(~isnan(X) & idxOnset), 100, "blue", "filled");
hold on;
scatter(X(~isnan(X) & ~idxOnset), Y(~isnan(X) & ~idxOnset), 100, "black", "filled");
xlabel("CRS-r score (Total)");
ylabel("RM_{onset}");

figure;
mSubplot(1, 2, 1, "shape", "square-min");
X = scoreAuditory;
Y = RM_delta_change_coma{2};
scatter(X(~isnan(X) & idxOnset), Y(~isnan(X) & idxOnset), 100, "blue", "filled");
hold on;
scatter(X(~isnan(X) & ~idxOnset), Y(~isnan(X) & ~idxOnset), 100, "black", "filled");
xlabel("CRS-r score (Auditory)");
ylabel("RM_{change}");

mSubplot(1, 2, 2, "shape", "square-min");
X = scoreTotal;
Y = RM_delta_change_coma{2};
[r_corr2, p_corr2] = corr(X(~isnan(X)), Y(~isnan(X)), "type", "Pearson");
scatter(X(~isnan(X) & idxOnset), Y(~isnan(X) & idxOnset), 100, "blue", "filled");
hold on;
scatter(X(~isnan(X) & ~idxOnset), Y(~isnan(X) & ~idxOnset), 100, "black", "filled");
xlabel("CRS-r score (Total)");
ylabel("RM_{change}");

%%
figure("WindowState", "maximized");
mSubplot(1, 1, 1, "shape", "square-min");
X = mean(cat(2, RM_delta_onset_coma{2}), 2);
Y = RM_delta_change_coma{2};
Z = scoreTotal;
scatter(X(~isnan(Z) & idxOnset), ...
        Y(~isnan(Z) & idxOnset), ...
        100, "red", "LineWidth", 1);
hold on;
scatter(X(~isnan(Z)), ...
        Y(~isnan(Z)), ...
        100, ...
        Z(~isnan(Z)), ...
        "filled");
xlabel("RM_{onset}");
ylabel("\DeltaRM_{change}");

colors1 = cell2mat(flip(generateGradientColors(128, 'b', 0)));
colors2 = cell2mat(generateGradientColors(128, 'r', 0));
colormap([colors1; colors2]);
temp = get(gca, "Position");
cb = colorbar("Position", [temp(1) + temp(3) + 0.02, temp(2), 0.01, temp(4)]);
cb.Label.String = "CRS-R score";
cb.Label.Rotation = -90;
cb.Label.VerticalAlignment = "baseline";

%% 
% exampleID = "2024041102";
exampleID = "2024040801";
idx = strcmp(exampleID, subjectIDsComa);

t1 = (t' - 1000) / 1000;

res_example_coma_GFP_REG4_4 = gfpComa{idx}(1, :)';
res_example_coma_GFP_REG4_5 = gfpComa{idx}(2, :)';

figure;
mSubplot(1, 2, 1, "shape", "square-min");
plot(t1, res_example_coma_GFP_REG4_4, "Color", "k", "LineWidth", 2, "DisplayName", "REG 4-4");
hold on;
plot(t1, res_example_coma_GFP_REG4_5, "Color", "r", "LineWidth", 2, "DisplayName", "REG 4-5");
legend;
xlabel("Time (sec)");
ylabel("GFP (\muV)");
title(['Global field power of coma subject ', char(exampleID)]);

mSubplot(1, 2, 2, "shape", "square-min");
temp1 = mean(dataComa{idx}(1).chMean(chs2Avg, :), 1)';
plot(t1, temp1, "Color", "k", "LineWidth", 2);
hold on;
temp2 = mean(dataComa{idx}(2).chMean(chs2Avg, :), 1)';
plot(t1, temp2, "Color", "r", "LineWidth", 2);

temp = dataComa{idx};
temp(1).color = "k";
temp(2).color = "r";
plotRawWaveMultiEEG(temp, window, [], EEGPos_Neuracle64);
