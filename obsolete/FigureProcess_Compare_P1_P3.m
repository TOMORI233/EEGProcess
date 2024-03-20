clear; clc; close all force;
set(0, "DefaultAxesFontSize", 12);

margins = [0.05, 0.05, 0.1, 0.1];
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

load("windows.mat", "windows");
windowP1 = windows([windows.protocol] == "passive1").window;
windowP3 = windows([windows.protocol] == "passive3").window;
chMeanDataP1 = load("..\DATA\MAT DATA\population\chMean_P1_Population.mat").data;
chMeanDataP3 = load("..\DATA\MAT DATA\population\chMean_P3_Population.mat").data;
briDataP1 = load("..\DATA\MAT DATA\figure\Res_BRI_P1.mat");
briDataP3 = load("..\DATA\MAT DATA\figure\Res_BRI_P3.mat");
fs = briDataP1.fs;

load("decision.mat", "dThs", "dThsDiff");
load("chsAvg.mat", "chsAvg");

%% chMean plot
window = [0, 2000];
tIdxP1 = fix((window(1) - windowP1(1)) * fs / 1000) + 1:fix((window(2) - windowP1(1)) * fs / 1000);
tIdxP3 = fix((window(1) - windowP3(1)) * fs / 1000) + 1:fix((window(2) - windowP3(1)) * fs / 1000);
chMeanDataP1 = vertcat(chMeanDataP1.chMeanData);
chMeanDataP3 = vertcat(chMeanDataP3.chMeanData);

chDataIRREG(1).chMean = cell2mat(cellfun(@(x) mean(x(:, tIdxP1), 1), changeCellRowNum({chMeanDataP1([chMeanDataP1.ICI] == 4.06 & [chMeanDataP1.type] == "IRREG").chMean}'), "UniformOutput", false));
chDataIRREG(1).color = "r";
chDataIRREG(2).chMean = cell2mat(cellfun(@(x) mean(x(:, tIdxP3), 1), changeCellRowNum({chMeanDataP3([chMeanDataP3.ICI] == 4.06 & [chMeanDataP3.type] == "IRREG").chMean}'), "UniformOutput", false));
chDataIRREG(2).color = "b";

FigIRREG = plotRawWaveMultiEEG(chDataIRREG, window, 1000, "IRREG");
scaleAxes(FigIRREG, "y", "on", "symOpt", "max", "uiOpt", "show");

%% BRI scatter
% diff
figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
X = briDataP3.meanBRI_IRREG(:, 2) - briDataP3.meanBRIbase2_IRREG(:, 2);
Y = briDataP1.meanBRI_IRREG(:, 1) - briDataP1.meanBRIbase2_IRREG(:, 2);
scatter(X, Y, 100, 'k');
set(gca, "FontSize", 15);
[~, p] = ttest(X, Y);
hold on;
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyMin = min([xRange, yRange]);
xyMax = max([xRange, yRange]);
xlim([xyMin, xyMax]);
ylim([xyMin, xyMax]);
addLines2Axes;
xlabel('Ratio \DeltaBRI_{IRREG 4-4.06} (\muV)');
ylabel('Length \DeltaBRI_{IRREG 4-4.06} (\muV)');
title(['Pairwise t-test p=', num2str(p)]);

% Baseline
figure;
maximizeFig;
mSubplot(1, 2, 1, "shape", "square-min");
scatter(briDataP3.meanBRIbase_IRREG(:, 2), briDataP1.meanBRIbase_IRREG(:, 1), 100, 'k');
set(gca, "FontSize", 15);
[~, p] = ttest(briDataP3.meanBRIbase_IRREG(:, 2), briDataP1.meanBRIbase_IRREG(:, 1));
hold on;
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyMin = min([xRange, yRange]);
xyMax = max([xRange, yRange]);
xlim([xyMin, xyMax]);
ylim([xyMin, xyMax]);
addLines2Axes;
xlabel('Ratio baseline BRI_{IRREG 4-4.06} (\muV)');
ylabel('Length baseline BRI_{IRREG 4-4.06} (\muV)');
title(['Pairwise t-test p=', num2str(p)]);

mSubplot(1, 2, 2, "shape", "square-min");
scatter(briDataP3.meanBRIbase2_IRREG(:, 2), briDataP1.meanBRIbase2_IRREG(:, 1), 100, 'k');
set(gca, "FontSize", 15);
[~, p] = ttest(briDataP3.meanBRIbase2_IRREG(:, 2), briDataP1.meanBRIbase2_IRREG(:, 1));
hold on;
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyMin = min([xRange, yRange]);
xyMax = max([xRange, yRange]);
xlim([xyMin, xyMax]);
ylim([xyMin, xyMax]);
addLines2Axes;
xlabel('Ratio before change BRI_{IRREG 4-4.06} (\muV)');
ylabel('Length before change BRI_{IRREG 4-4.06} (\muV)');
title(['Pairwise t-test p=', num2str(p)]);

%% Decision threshold difference
TH = median(dThs);

figure;
maximizeFig;
mSubplot(1, 3, 1, "shape", "square-min", "margin_left", 0.1);
h = histogram(dThs, 'BinWidth', 0.05, 'FaceColor', [0, 0, 1]);
setLegendOff(h);
xlabel('Push ratio for IRREG_{4-4}');
ylabel('Count');

mSubplot(1, 3, 2, "shape", "square-min", "margin_left", 0.1);
X1 = dThs(dThs <= 0.2);
Y1 = dThsDiff(dThs <= 0.2);
X2 = dThs(dThs > 0.6);
Y2 = dThsDiff(dThs > 0.6);
X3 = dThs(dThs > 0.2 & dThs <= 0.6);
Y3 = dThsDiff(dThs > 0.2 & dThs <= 0.6);
scatter(X1, Y1, 100, 'b', 'filled', 'DisplayName', 'TH \leq 0.2', 'LineWidth', 1.5);
hold on;
scatter(X3, Y3, 100, 'k', 'filled', 'DisplayName', '0.2 < TH \leq 0.6', 'LineWidth', 1.5);
scatter(X2, Y2, 100, 'r', 'filled', 'DisplayName', 'TH > 0.6', 'LineWidth', 1.5);
legend("Location", "northwest");
[~, p1] = ttest(X1, Y1);
[~, p2] = ttest(X2, Y2);
[~, p3] = ttest(X3, Y3);
hold on;
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyMin = min([xRange, yRange]);
xyMax = max([xRange, yRange]);
xlim([xyMin, xyMax]);
ylim([xyMin, xyMax]);
addLines2Axes(gca);
xlabel('Push ratio IRREG_{4-4}');
ylabel('Push ratio IRREG_{4-4.06}');
title({'Pairwise t-test'; ...
       ['p_{TH\leq0.2}=', num2str(p1)]; ...
       ['p_{0.2<TH\leq0.6}=', num2str(p3)]; ...
       ['p_{TH>0.6}=', num2str(p2)]});

mSubplot(1, 3, 3, "shape", "square-min", "margin_left", 0.1);
X1 = X(dThs <= 0.2);
Y1 = Y(dThs <= 0.2);
X2 = X(dThs > 0.6);
Y2 = Y(dThs > 0.6);
X3 = X(dThs > 0.2 & dThs <= 0.6);
Y3 = Y(dThs > 0.2 & dThs <= 0.6);
scatter(X1, Y1, 100, 'b', 'filled', 'DisplayName', 'TH \leq 0.2', 'LineWidth', 1.5);
hold on;
scatter(X3, Y3, 100, 'k', 'filled', 'DisplayName', '0.2 < TH \leq 0.6', 'LineWidth', 1.5);
scatter(X2, Y2, 100, 'r', 'filled', 'DisplayName', 'TH > 0.6', 'LineWidth', 1.5);
legend("Location", "northwest");
[~, p1] = ttest(X1, Y1);
[~, p2] = ttest(X2, Y2);
[~, p3] = ttest(X3, Y3);
hold on;
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyMin = min([xRange, yRange]);
xyMax = max([xRange, yRange]);
xlim([xyMin, xyMax]);
ylim([xyMin, xyMax]);
addLines2Axes(gca);
xlabel('Ratio \DeltaBRI_{IRREG 4-4.06} (\muV)');
ylabel('Length \DeltaBRI_{IRREG 4-4.06} (\muV)');
title({'Pairwise t-test'; ...
       ['p_{TH\leq0.2}=', num2str(p1)]; ...
       ['p_{0.2<TH\leq0.6}=', num2str(p3)]; ...
       ['p_{TH>0.6}=', num2str(p2)]});

%% 
temp = {chMeanDataP1([chMeanDataP1.ICI] == 4.06 & [chMeanDataP1.type] == "IRREG").chMean}';
chMeanP1{1} = cell2mat(cellfun(@(x) mean(x(:, tIdxP1), 1), changeCellRowNum(temp(dThs <= 0.2)), "UniformOutput", false));
chMeanP1{1} = mean(chMeanP1{1}(chsAvg, :), 1);
chMeanP1{2} = cell2mat(cellfun(@(x) mean(x(:, tIdxP1), 1), changeCellRowNum(temp(dThs > 0.6)), "UniformOutput", false));
chMeanP1{2} = mean(chMeanP1{2}(chsAvg, :), 1);
chMeanP1{3} = cell2mat(cellfun(@(x) mean(x(:, tIdxP1), 1), changeCellRowNum(temp(dThs > 0.2 & dThs <= 0.6)), "UniformOutput", false));
chMeanP1{3} = mean(chMeanP1{3}(chsAvg, :), 1);

temp = {chMeanDataP3([chMeanDataP3.ICI] == 4.06 & [chMeanDataP3.type] == "IRREG").chMean}';
chMeanP3{1} = cell2mat(cellfun(@(x) mean(x(:, tIdxP3), 1), changeCellRowNum(temp(dThs <= 0.2)), "UniformOutput", false));
chMeanP3{1} = mean(chMeanP3{1}(chsAvg, :), 1);
chMeanP3{2} = cell2mat(cellfun(@(x) mean(x(:, tIdxP3), 1), changeCellRowNum(temp(dThs > 0.6)), "UniformOutput", false));
chMeanP3{2} = mean(chMeanP3{2}(chsAvg, :), 1);
chMeanP3{3} = cell2mat(cellfun(@(x) mean(x(:, tIdxP3), 1), changeCellRowNum(temp(dThs > 0.2 & dThs <= 0.6)), "UniformOutput", false));
chMeanP3{3} = mean(chMeanP3{3}(chsAvg, :), 1);

t = linspace(window(1), window(2), size(chMeanP1{1}, 2));

figure;
maximizeFig;
mSubplot(1, 3, 1, "shape", "square-min", "margin_left", 0.1);
plot(t, chMeanP1{1}, "Color", "r", "LineWidth", 2, "DisplayName", "Length");
hold on;
plot(t, chMeanP3{1}, "Color", "b", "LineWidth", 2, "DisplayName", "Ratio");
title('TH \leq 0.2');
legend;
xlabel("Time (ms)");
ylabel("Amplitude (\muV)");

mSubplot(1, 3, 2, "shape", "square-min", "margin_left", 0.1);
plot(t, chMeanP1{3}, "Color", "r", "LineWidth", 2, "DisplayName", "Length");
hold on;
plot(t, chMeanP3{3}, "Color", "b", "LineWidth", 2, "DisplayName", "Ratio");
title('0.2 < TH \leq 0.6');
legend;
xlabel("Time (ms)");
ylabel("Amplitude (\muV)");

mSubplot(1, 3, 3, "shape", "square-min", "margin_left", 0.1);
plot(t, chMeanP1{2}, "Color", "r", "LineWidth", 2, "DisplayName", "Length");
hold on;
plot(t, chMeanP3{2}, "Color", "b", "LineWidth", 2, "DisplayName", "Ratio");
title('TH > 0.6');
legend;
xlabel("Time (ms)");
ylabel("Amplitude (\muV)");

scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 1000));