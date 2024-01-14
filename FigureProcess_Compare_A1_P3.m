ccc;

% area = "Parietal";
area = "Temporal-Parietal-Occipital";
dataA1 = load(strcat("..\DATA\MAT DATA\figure\Res_RM_A1-", area, ".mat"));
dataP3 = load(strcat("..\DATA\MAT DATA\figure\Res_RM_P3-", area, ".mat"));

ICIsREG = dataA1.ICIsREG;

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

t = dataP3.window(1):1000/dataP3.fs:dataP3.window(2);
t = t - (1000 + 4);

%%
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
errorbar((1:length(ICIsREG)) + 0.01, cellfun(@mean, dataA1.RM_deltaREG), cellfun(@SE, dataA1.RM_deltaREG), "Color", "r", "LineWidth", 2, "DisplayName", "Behavior");
hold on;
errorbar((1:length(ICIsREG)) - 0.01, cellfun(@mean, dataP3.RM_deltaREG), cellfun(@SE, dataP3.RM_deltaREG), "Color", "b", "LineWidth", 2, "DisplayName", "Non-behavior");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("S2 ICI (ms)");
ylabel("\DeltaRM_{change - before change} (\muV)");
title("Tuning of RM");

print(Fig, ['..\Docs\Figures\Figure 10\tuning-', char(area), '.png'], "-dpng", "-r300");

[~, p] = cellfun(@(x, y) ttest2(x, y), dataA1.RM_deltaREG, dataP3.RM_deltaREG);

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

params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 10\data-', char(area), '.mat'], params{:});
