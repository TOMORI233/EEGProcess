clear; clc; close all force;

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

load("decision.mat", "dThs");

%% chMean plot
window = [0, 2000];
tIdxP1 = fix((window(1) - windowP1(1)) * fs / 1000) + 1:fix((window(2) - windowP1(1)) * fs / 1000);
tIdxP3 = fix((window(1) - windowP3(1)) * fs / 1000) + 1:fix((window(2) - windowP3(1)) * fs / 1000);
chMeanDataP1 = vertcat(chMeanDataP1.chMeanData);
chMeanDataP3 = vertcat(chMeanDataP3.chMeanData);

chMeanIRREG(1).chMean = cell2mat(cellfun(@(x) mean(x(:, tIdxP1), 1), changeCellRowNum({chMeanDataP1([chMeanDataP1.ICI] == 4.06 & [chMeanDataP1.type] == "IRREG").chMean}'), "UniformOutput", false));
chMeanIRREG(1).color = "r";
chMeanIRREG(2).chMean = cell2mat(cellfun(@(x) mean(x(:, tIdxP3), 1), changeCellRowNum({chMeanDataP3([chMeanDataP3.ICI] == 4.06 & [chMeanDataP3.type] == "IRREG").chMean}'), "UniformOutput", false));
chMeanIRREG(2).color = "b";

FigIRREG = plotRawWaveMultiEEG(chMeanIRREG, window, 1000, "IRREG");
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
figure;
h = histogram(dThs, 'BinWidth', 0.05, 'FaceColor', [0, 0, 1]);
setLegendOff(h);
hold on;
addLines2Axes(struct("X", mean(dThs), ...
                     "legend", "Average", ...
                     "color", "r"));
set(gca, "FontSize", 12);
xlabel('Push ratio for IRREG control group');
ylabel('Count');

figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
% TH = mean(dThs);
TH = 0.6;
X1 = X(dThs <= TH);
Y1 = Y(dThs <= TH);
X2 = X(dThs >  TH);
Y2 = Y(dThs >  TH);
scatter(X1, Y1, 100, 'r', 'DisplayName', '\leq TH');
hold on;
scatter(X2, Y2, 100, 'b', 'DisplayName', '> TH');
set(gca, "FontSize", 15);
legend("Location", "best");
[~, p1] = ttest(X1, Y1);
[~, p2] = ttest(X2, Y2);
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
title(['Pairwise t-test p_{\leq TH}=', num2str(p1), ' | p_{> TH}', num2str(p2)]);