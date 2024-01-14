ccc;

dataP1 = load("..\DATA\MAT DATA\figure\Res_RM_P1-Parietal.mat");
dataP3 = load("..\DATA\MAT DATA\figure\Res_RM_P3-Parietal.mat");
bData = load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat");

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

%% Plot wave
chData = [dataP1.chDataIRREG_All(1); ...
          dataP3.chDataIRREG_All(end)];
chData(1).color = "r";
chData(2).color = "b";
chData(1).legend = "IRREG 4.06 (Base ICI)";
chData(2).legend = "IRREG 4.06 (Ratio)";

windowP1 = dataP1.window;
windowP3 = dataP3.window;
window = windowP3;
chData(1).chMean = cutData(chData(1).chMean, windowP1, window);

plotRawWaveMultiEEG(chData, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [1000, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(dataP1.chs2Avg, :), 1), chData, "UniformOutput", false);
chDataSingle = addfield(chData, "chMean", chMean);
plotRawWaveMulti(chDataSingle, window, 'Influence of context');
scaleAxes("x", [1000, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 ; 2000}));

%% Scatter plot
RM_deltaIRREG_baseICI = dataP1.RM_deltaIRREG{1};
RM_deltaIRREG_ratio = dataP3.RM_deltaIRREG{end};

figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
scatter(RM_deltaIRREG_ratio, RM_deltaIRREG_baseICI, 50, "black");
[~, p] = ttest(RM_deltaIRREG_ratio, RM_deltaIRREG_baseICI);
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel(['RM_{IRREG 4.06} in Ratio (\muV)']);
ylabel(['RM_{IRREG 4.06} in base ICI (\muV)']);
title(['Pairwise t-test p=', num2str(roundn(p, -4))]);
addLines2Axes(gca);

%% Decision threshold difference
dThs = cellfun(@(x) x(1), bData.resIRREG_A1);
dThsDiff = cellfun(@(x) x(2), bData.resIRREG_A1);
TH = median(dThs);
X = dataP3.RM_deltaIRREG{end};
Y = dataP1.RM_deltaIRREG{1};

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