%% 离散度
clear; clc; close all force;

chMeanData = load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_P2_Population.mat").data;
briData = load("D:\Education\Lab\Projects\EEG\MAT Population\BRI_P2_Population.mat").data;

window = briData(1).window;
colors = flip(cellfun(@(x) x / 255, {[0 0 0], [0 0 255], [255 0 0]}, "UniformOutput", false));

%% chMean plot
temp = vertcat(chMeanData.chMeanData);
vars = unique([temp.variance]);

for index = 1:length(vars)
    idx = [temp.variance] == vars(index);
    chMeanVar(index, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
    chMeanVar(index, 1).variance = vars(index);
    chMeanVar(index, 1).color = colors{index};
end

FigVar = plotRawWaveMultiEEG(chMeanVar, window, 1000, "Variance");
scaleAxes(FigVar, "x", [1000, 1500]);
scaleAxes(FigVar, "y", "on", "symOpt", "max", "uiOpt", "show");

%% BRI
meanBRI = zeros(length(briData), 3);
seBRI = zeros(length(briData), 3);

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;

    for index = 1:length(vars)
        temp = BRI([trialAll.variance] == vars(index));
        meanBRI(bIndex, index) = mean(temp);
        seBRI(bIndex, index) = SE(temp);
    end

end

trialAllPopu = [briData.trialAll]';
BRIPopu = vertcat(briData.BRI);
BRIbasePopu = vertcat(briData.BRIbase);
BRIbase2Popu = vertcat(briData.BRIbase2);
pREG = zeros(1, 3);
pREG2 = zeros(1, 3);
[~, pBaseREG] = ttest(BRIbasePopu, BRIbase2Popu);
for index = 1:length(vars)
    idx = [trialAllPopu.variance] == vars(index);
    [~, pREG(index)] = ttest(BRIPopu(idx), BRIbasePopu(idx));
    [~, pREG2(index)] = ttest(BRIPopu(idx), BRIbase2Popu(idx));
end

figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
for bIndex = 1:length(briData)
    errorbar(1:3, meanBRI(bIndex, :), seBRI(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:3, mean(meanBRI, 1), SE(meanBRI, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
text(0.8, max(get(gca, "YLim")) - 0.5, 'vs \bf{[-300,0]}', "HorizontalAlignment", "right", "FontSize", 12);
text(1:3, repmat(max(get(gca, "YLim")) - 0.5, [1, 3]), num2str(pREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(0.8, max(get(gca, "YLim")) - 1, 'vs \bf{[900,1000]}', "HorizontalAlignment", "right", "FontSize", 12);
text(1:3, repmat(max(get(gca, "YLim")) - 1, [1, 3]), num2str(pREG2'), "HorizontalAlignment", "center", "FontSize", 12);
xticks(1:3);
xticklabels(num2str(vars'));
xlim([0.8, 3.2]);
xlabel('ICI Variance Factor X (\sigma=\mu/X)');
ylabel('BRI(\muV)');
title(['p_{Baseline [-300,0] vs Before change [900,1000]}=', num2str(pBaseREG)]);