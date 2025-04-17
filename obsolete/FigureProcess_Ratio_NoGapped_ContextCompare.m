ccc;

dataA1 = load("..\DATA\MAT DATA\figure\Res A1 compare (Temporal-Parietal-Occipital).mat");
dataP3 = load("..\DATA\MAT DATA\figure\Res P3 compare (Temporal-Parietal-Occipital).mat");

%%
set(0, "DefaultAxesFontSize", 12);

ICIsREG = dataA1.ICIsREG;
window = dataA1.window;
t = linspace(window(1), window(2), size(dataA1.chData(1).chMean, 2));

alphaVal = 0.05;
EEGPos = EEGPos_Neuroscan64;

%% Tuning
figure;
for index = 1:length(ICIsREG)
    mSubplot(2, length(ICIsREG), index);
    plot(t, dataA1.chData(index).chMean(:), "Color", "r", "LineWidth", 2, "DisplayName", "Active");
    hold on;
    plot(t, dataP3.chData(index).chMean(:), "Color", "k", "LineWidth", 2, "DisplayName", "Passive");
    if index == 1
        legend;
    end
    title(num2str(ICIsREG(index)));
end
scaleAxes("x", [800, 1800]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000; 2000}));

figure;
mSubplot(1, 2, 1, "shape", "square-min");
hold on;
X = 1:length(ICIsREG);
Y_cP1_A = cellfun(@mean, dataA1.RM_delta_changeP_REG);
E_cP1_A = cellfun(@SE,   dataA1.RM_delta_changeP_REG);
Y_cN2_A = cellfun(@mean, dataA1.RM_delta_changeN_REG);
E_cN2_A = cellfun(@SE,   dataA1.RM_delta_changeN_REG);

Y_cP1_P = cellfun(@mean, dataP3.RM_delta_changeP_REG);
E_cP1_P = cellfun(@SE,   dataP3.RM_delta_changeP_REG);
Y_cN2_P = cellfun(@mean, dataP3.RM_delta_changeN_REG);
E_cN2_P = cellfun(@SE,   dataP3.RM_delta_changeN_REG);

errorbar(X - 0.05, Y_cP1_A, E_cP1_A, "Color", "r", "LineWidth", 2, "DisplayName", "cP1 Attentive");
errorbar(X + 0.05, Y_cN2_A, E_cN2_A, "Color", "r", "LineStyle", "--", "LineWidth", 2, "DisplayName", "cN2 Attentive");
errorbar(X - 0.05, Y_cP1_P, E_cP1_P, "Color", "b", "LineWidth", 2, "DisplayName", "cP1 Passive");
errorbar(X + 0.05, Y_cN2_P, E_cN2_P, "Color", "b", "LineStyle", "--", "LineWidth", 2, "DisplayName", "cN2 Passive");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));

[~, p_RM_changeP_REG_A_vs_P] = cellfun(@(x, y) ttest(x, y, "Tail", "both"), dataA1.RM_delta_changeP_REG, dataP3.RM_delta_changeP_REG);
[~, p_RM_changeN_REG_A_vs_P] = cellfun(@(x, y) ttest(x, y, "Tail", "both"), dataA1.RM_delta_changeN_REG, dataP3.RM_delta_changeN_REG);
