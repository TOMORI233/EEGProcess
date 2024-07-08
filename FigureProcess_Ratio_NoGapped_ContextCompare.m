ccc;

dataA1 = load("..\DATA\MAT DATA\figure\Res A1 (Temporal-Parietal-Occipital).mat");
dataP3 = load("..\DATA\MAT DATA\figure\Res P3 (Temporal-Parietal-Occipital).mat");

%%
set(0, "DefaultAxesFontSize", 12);

ICIsREG = dataA1.ICIsREG;
window = dataA1.window;
t = linspace(window(1), window(2), size(dataA1.chDataREG(1).chMean, 2));

%% 
figure;
for index = 1:length(ICIsREG)
    mSubplot(2, length(ICIsREG), index);
    plot(t, dataA1.chDataREG(index).chMean(:), "Color", "r", "LineWidth", 2, "DisplayName", "Active");
    hold on;
    plot(t, dataP3.chDataREG(index).chMean(:), "Color", "k", "LineWidth", 2, "DisplayName", "Passive");
    if index == 1
        legend;
    end
end
scaleAxes("x", [800, 1500]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000; 2000}));
mSubplot(2, length(ICIsREG), 1 + length(ICIsREG));
errorbar(1:length(ICIsREG), cellfun(@mean, dataA1.RM_delta_changePeakREG), cellfun(@SE, dataA1.RM_delta_changePeakREG), "Color", "r", "LineWidth", 2, "DisplayName", "Active");
hold on;
errorbar(1:length(ICIsREG), cellfun(@mean, dataP3.RM_delta_changePeakREG), cellfun(@SE, dataP3.RM_delta_changePeakREG), "Color", "k", "LineWidth", 2, "DisplayName", "Passive");
legend;
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
mSubplot(2, length(ICIsREG), 3 + length(ICIsREG));
errorbar(1:length(ICIsREG), cellfun(@mean, dataA1.RM_delta_changeTroughREG), cellfun(@SE, dataA1.RM_delta_changeTroughREG), "Color", "r", "LineWidth", 2, "DisplayName", "Active");
hold on;
errorbar(1:length(ICIsREG), cellfun(@mean, dataP3.RM_delta_changeTroughREG), cellfun(@SE, dataP3.RM_delta_changeTroughREG), "Color", "k", "LineWidth", 2, "DisplayName", "Passive");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));