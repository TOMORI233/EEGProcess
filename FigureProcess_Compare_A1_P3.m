ccc;

% area = "Parietal";
area = "Temporal-Parietal-Occipital";
dataA1 = load(strcat("..\DATA\MAT DATA\figure\Res_RM_A1-", area, ".mat"));
dataP3 = load(strcat("..\DATA\MAT DATA\figure\Res_RM_P3-", area, ".mat"));

load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");

ICIsREG = dataA1.ICIsREG;
ICIsIRREG = dataA1.ICIsIRREG;
freqs = dataA1.freqs(1);

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

t = dataP3.window(1):1000/dataP3.fs:dataP3.window(2);
t = t - (1000 + 4);

%% Reg
Fig = figure;
maximizeFig;
for dIndex = 1:length(ICIsREG)
    mSubplot(3, length(ICIsREG), dIndex, "margin_left", 0.15);
    plot(t, dataA1.chDataREG(dIndex).chMean, "Color", "r", "LineWidth", 2, "DisplayName", "Behavior");
    hold on;
    plot(t, dataP3.chDataREG(dIndex).chMean, "Color", "k", "LineWidth", 2, "DisplayName", "Non-behavior");
    if dIndex == 1
        legend;
    end
    xlabel('Time (ms)');
    ylabel('Response (\muV)');
    xlim([-100, 500]);
    title(dataP3.chDataREG(dIndex).legend);
end
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));

mSubplot(2, 3, 5, "shape", "square-min");
hold(gca, "on");
errorbar((1:length(ICIsREG)) + 0.01, cellfun(@mean, dataA1.RM_deltaREG), cellfun(@SE, dataA1.RM_deltaREG), "Color", "r", "LineWidth", 2, "DisplayName", "Behavior");
errorbar((1:length(ICIsREG)) - 0.01, cellfun(@mean, dataP3.RM_deltaREG), cellfun(@SE, dataP3.RM_deltaREG), "Color", "b", "LineWidth", 2, "DisplayName", "Non-behavior");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("S2 ICI (ms)");
ylabel("\DeltaRM_{change - before change} (\muV)");
title("Tuning of RM");

print(Fig, ['..\Docs\Figures\Figure 10\tuning-', char(area), '.png'], "-dpng", "-r300");

[~, pREG] = rowFcn(@(x, y, z) ttest(x{1}, y{1}(~z)), dataA1.RM_deltaREG, dataP3.RM_deltaREG, dataA1.skipIdxREG');
figure;
maximizeFig;
for index = 1:length(ICIsREG)
    mSubplot(1, length(ICIsREG), index, "shape", "square-min", "margin_left", 0.2);
    scatter(dataP3.RM_deltaREG{index}(~dataA1.skipIdxREG(:, index)), dataA1.RM_deltaREG{index}, 50, "black");
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{non-behavior} (\muV)");
    ylabel("RM_{behavior} (\muV)");
    title(['REG S2 ICI=', num2str(ICIsREG(index)), ' | p=', num2str(roundn(pREG(index), -4))]);
    addLines2Axes(gca);
end

%% Irreg
Fig = figure;
maximizeFig;
for dIndex = 1:length(ICIsIRREG)
    mSubplot(3, length(ICIsIRREG), dIndex, "margin_left", 0.15);
    plot(t, dataA1.chDataIRREG(dIndex).chMean, "Color", "r", "LineWidth", 2, "DisplayName", "Behavior");
    hold on;
    plot(t, dataP3.chDataIRREG(dIndex).chMean, "Color", "k", "LineWidth", 2, "DisplayName", "Non-behavior");
    if dIndex == 1
        legend;
    end
    xlabel('Time (ms)');
    ylabel('Response (\muV)');
    xlim([-100, 500]);
    title(dataP3.chDataIRREG(dIndex).legend);
end
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));

mSubplot(2, 3, 5, "shape", "square-min");
hold(gca, "on");
errorbar((1:length(ICIsIRREG)) + 0.01, cellfun(@mean, dataA1.RM_deltaIRREG), cellfun(@SE, dataA1.RM_deltaIRREG), "Color", "r", "LineWidth", 2, "DisplayName", "Behavior");
errorbar((1:length(ICIsIRREG)) - 0.01, cellfun(@mean, dataP3.RM_deltaIRREG), cellfun(@SE, dataP3.RM_deltaIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "Non-behavior");
legend("Location", "northwest");
xticks(1:length(ICIsIRREG));
xlim([0, length(ICIsIRREG)] + 0.5);
xticklabels(num2str(ICIsIRREG));
xlabel("S2 ICI (ms)");
ylabel("\DeltaRM_{change - before change} (\muV)");
title("Tuning of RM");

print(Fig, ['..\Docs\Figures\Figure 10\tuning IRREG-', char(area), '.png'], "-dpng", "-r300");

[~, pIRREG] = cellfun(@(x, y) ttest(x, y), dataA1.RM_deltaIRREG, dataP3.RM_deltaIRREG);
figure;
maximizeFig;
for index = 1:length(ICIsIRREG)
    mSubplot(1, length(ICIsIRREG), index, "shape", "square-min", "margin_left", 0.2);
    scatter(dataP3.RM_deltaIRREG{index}, dataA1.RM_deltaIRREG{index}, 50, "black");
    xRange = get(gca, "XLim");
    yRange = get(gca, "YLim");
    xyRange = [min([xRange, yRange]), max([xRange, yRange])];
    xlim(xyRange);
    ylim(xyRange);
    xlabel("RM_{non-behavior} (\muV)");
    ylabel("RM_{behavior} (\muV)");
    title(['IRREG S2 ICI=', num2str(ICIsIRREG(index)), ' | p=', num2str(roundn(pIRREG(index), -4))]);
    addLines2Axes(gca);
end

%% PT
Fig = figure;
maximizeFig;
mSubplot(3, 3, 2, "margin_left", 0.15);
plot(t, dataA1.chDataPT(1).chMean, "Color", "r", "LineWidth", 2, "DisplayName", "Behavior");
hold on;
plot(t, dataP3.chDataPT(1).chMean, "Color", "k", "LineWidth", 2, "DisplayName", "Non-behavior");
legend;
xlabel('Time (ms)');
ylabel('Response (\muV)');
xlim([-100, 500]);
title(dataA1.chDataPT(1).legend);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", 0));

[~, pPT] = ttest(dataA1.RM_deltaPT{1}, dataP3.RM_deltaPT{1});
mSubplot(3, 3, 8, [2, 2], "shape", "square-min", "alignment", "bottom-center");
scatter(dataP3.RM_deltaPT{1}, dataA1.RM_deltaPT{1}, 50, "black");
xRange = get(gca, "XLim");
yRange = get(gca, "YLim");
xyRange = [min([xRange, yRange]), max([xRange, yRange])];
xlim(xyRange);
ylim(xyRange);
xlabel("RM_{non-behavior} (\muV)");
ylabel("RM_{behavior} (\muV)");
title(['Tone S2 freq=', num2str(roundn(freqs(1), 0)), ' | p=', num2str(roundn(pPT, -4))]);
addLines2Axes(gca);

%% Figure result
% wave
res_t = t';
res_chMean_behavior = cell2mat({dataA1.chDataREG.chMean}')';
res_chMean_nonbehavior = cell2mat({dataP3.chDataREG.chMean}')';

% tuning
res_tuning_mean_behavior = cellfun(@mean, dataA1.RM_deltaREG);
res_tuning_se_behavior = cellfun(@SE, dataA1.RM_deltaREG);
res_tuning_mean_nonbehavior = cellfun(@mean, dataP3.RM_deltaREG);
res_tuning_se_nonbehavior = cellfun(@SE, dataP3.RM_deltaREG);

res_tuning_base_mean_behavior = cellfun(@(x) mean(x(~isnan(x))), dataA1.RM_baseREG);
res_tuning_base_se_behavior = cellfun(@(x) SE(x(~isnan(x))), dataA1.RM_baseREG);
res_tuning_base_mean_nonbehavior = cellfun(@(x) mean(x(~isnan(x))), dataP3.RM_baseREG);
res_tuning_base_se_nonbehavior = cellfun(@(x) SE(x(~isnan(x))), dataP3.RM_baseREG);

params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 10\data-', char(area), '.mat'], params{:});
