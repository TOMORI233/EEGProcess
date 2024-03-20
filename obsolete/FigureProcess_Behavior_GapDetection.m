ccc;

load("baseICI_onset.mat");

run("config\avgConfig_Neuracle64.m");

colors = [flip(generateGradientColors(3, 'r', 0.2)); ...
          generateGradientColors(3, 'b', 0.2); ...
          {[0, 0, 0]}];

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chMeanData, "UniformOutput", false);
ICIs = [chMeanData.ICI]';
res_chMean = [t; cell2mat(chMean)]';

chDataSingle = addfield(chMeanData, "chMean", chMean);
chDataSingle = addfield(chDataSingle, "color", colors);
chDataSingle = addfield(chDataSingle, "legend", arrayfun(@num2str, ICIs, "UniformOutput", false));
plotRawWaveMulti(chDataSingle, [t(1), t(end)]);
xlim([0, 600]);
addLines2Axes(struct("X", 0));

windowOnset = [0, 250];
windowBase1 = [-200, 0];
windowOffset = [1100, 1300];
windowBase2 = [800, 1000];
tIdxOnset = find(t >= windowOnset(1), 1):find(t >= windowOnset(2), 1);
tIdxBase1 = find(t >= windowBase1(1), 1):find(t >= windowBase1(2), 1);
tIdxOffset = find(t >= windowOffset(1), 1):find(t >= windowOffset(2), 1);
tIdxBase2 = find(t >= windowBase2(1), 1):find(t >= windowBase2(2), 1);

temp1 = cellfun(@(x1) cellfun(@(x2) mean(x2(chs2Avg, :), 1), x1, "UniformOutput", false), data, "UniformOutput", false);
RM_onset = cell2mat(cellfun(@(x1) cellfun(@(x2) rms(x2(tIdxOnset)), x1)', temp1, "UniformOutput", false));
RM_base1 = cell2mat(cellfun(@(x1) cellfun(@(x2) rms(x2(tIdxBase1)), x1)', temp1, "UniformOutput", false));
RM_offset = cell2mat(cellfun(@(x1) cellfun(@(x2) rms(x2(tIdxOffset)), x1)', temp1, "UniformOutput", false));
RM_base2 = cell2mat(cellfun(@(x1) cellfun(@(x2) rms(x2(tIdxBase2)), x1)', temp1, "UniformOutput", false));
res_RM_onset_mean = mean(RM_onset - RM_base1, 1)';
res_RM_onset_SE = SE(RM_onset - RM_base1, 1)';
res_RM_offset_mean = mean(RM_offset - RM_base2, 1)';
res_RM_offset_SE = SE(RM_offset - RM_base2, 1)';

figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIs)) - 0.01, res_RM_onset_mean, res_RM_onset_SE, "LineWidth", 2, "Color", "r", "DisplayName", "onset");
hold on;
errorbar((1:length(ICIs)) + 0.01, res_RM_offset_mean, res_RM_offset_SE, "LineWidth", 2, "Color", "b", "DisplayName", "offset");
legend;
xlim([0.5, length(ICIs) + 0.5]);
xticks(1:length(ICIs));
xticklabels(num2str(ICIs));

[~, p] = ttest(RM_onset(:, 3), RM_onset(:, 4));
pANOVA = anova1(RM_onset(:, 4:end), [], "off");
