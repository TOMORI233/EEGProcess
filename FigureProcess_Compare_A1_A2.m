ccc;

% area = "Parietal";
area = "Temporal-Parietal-Occipital";
dataA1 = load(strcat("..\DATA\MAT DATA\figure\Res_RM_A1-", area, ".mat"));
dataA2 = load(strcat("..\DATA\MAT DATA\figure\Res_RM_A2-", area, ".mat"));

ICIsREG = dataA1.ICIsREG;

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

tA1 = dataA1.window(1):1000/dataA1.fs:dataA1.window(2);
tA2 = dataA2.window(1):1000/dataA2.fs:dataA2.window(2);

%%
Fig = figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) + 0.01, cellfun(@mean, dataA1.RM_deltaREG), cellfun(@SE, dataA1.RM_deltaREG), "Color", "r", "LineWidth", 2, "DisplayName", "No-gapped");
hold on;
errorbar((1:length(ICIsREG)) - 0.01, cellfun(@mean, dataA2.RM_deltaREG), cellfun(@SE, dataA2.RM_deltaREG), "Color", "b", "LineWidth", 2, "DisplayName", "Gapped");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("S2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM");

print(Fig, ['..\Docs\Figures\Figure 12\tuning-', char(area), '.png'], "-dpng", "-r300");

%% Figure result
% wave
res_t_nogapped = tA1' - 1000 - ICIsREG(1);
res_t_gapped = tA2' - 1000 - dataA2.interval;
res_chMean_nogapped = cell2mat({dataA1.chDataREG.chMean}')';
res_chMean_gapped = cell2mat({dataA2.chDataREG.chMean}')';

% tuning
res_tuning_mean_nogapped = cellfun(@mean, dataA1.RM_deltaREG);
res_tuning_se_nogapped = cellfun(@SE, dataA1.RM_deltaREG);
res_tuning_mean_gapped = cellfun(@mean, dataA2.RM_deltaREG);
res_tuning_se_gapped = cellfun(@SE, dataA2.RM_deltaREG);

params = fieldnames(getVarsFromWorkspace('res_\W*'));
save(['..\Docs\Figures\Figure 12\data-', char(area), '.mat'], params{:});
