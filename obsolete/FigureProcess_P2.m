%% 离散度
clear; clc; close all force;

chMeanData = load("..\DATA\MAT DATA\population\chMean_P2_Population.mat").data;
briData = load("..\DATA\MAT DATA\population\BRI_P2_Population.mat").data;

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

FigVar = plotRawWaveMultiEEG(chMeanVar, window, "Variance");
scaleAxes(FigVar, "x", [1000, 1500]);
scaleAxes(FigVar, "y", "on", "symOpt", "max", "uiOpt", "show");

save("..\DATA\MAT DATA\figure\Res_chMean_P2.mat", ...
     "chMeanVar", "window");

%% BRI
meanBRI = zeros(length(briData), length(vars));
meanBRIbase = zeros(length(briData), length(vars));
meanBRIbase2 = zeros(length(briData), length(vars));
seBRI = zeros(length(briData), length(vars));
seBRIbase = zeros(length(briData), length(vars));
seBRIbase2 = zeros(length(briData), length(vars));

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;
    BRIbase = briData(bIndex).BRIbase;
    BRIbase2 = briData(bIndex).BRIbase2;

    for index = 1:length(vars)
        idx = [trialAll.variance] == vars(index);
        meanBRI(bIndex, index) = mean(BRI(idx));
        seBRI(bIndex, index) = SE(BRI(idx));

        meanBRIbase(bIndex, index) = mean(BRIbase(idx));
        seBRIbase(bIndex, index) = SE(BRIbase(idx));

        meanBRIbase2(bIndex, index) = mean(BRIbase2(idx));
        seBRIbase2(bIndex, index) = SE(BRIbase2(idx));
    end

end

p = zeros(1, length(vars)); % vs baseline
p2 = zeros(1, length(vars)); % vs before change
p3 = zeros(1, length(vars) - 1); % vs control
pBase = zeros(1, length(vars)); % baseline vs before change
for index = 1:length(vars)
    [~, p(index)] = ttest(meanBRI(:, index), meanBRIbase(:, index));
    [~, p2(index)] = ttest(meanBRI(:, index), meanBRIbase2(:, index));
    [~, pBase(index)] = ttest(meanBRIbase(:, index), meanBRIbase2(:, index));

    if index > 1
        [~, p3(index - 1)] = ttest(meanBRI(:, index), meanBRI(:, 1));
    end
end

FigBRI = figure;
maximizeFig(FigBRI);
mAxe = mSubplot(FigBRI, 1, 1, 1, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(briData)
    errorbar(1:length(vars), meanBRI(bIndex, :), seBRI(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:length(vars), mean(meanBRI, 1), SE(meanBRI, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
xticks(1:length(vars));
xticklabels(num2str(vars'));
xlim([0.8, length(vars) + 0.2]);
xlabel('ICI Variance Factor X (\sigma=\mu/X)');
ylabel('BRI (\muV)');
title('Variance');

scaleAxes(FigBRI, "y");

text(mAxe, 0.8, max(get(mAxe, "YLim")) - 0.5, '\bf{vs [-300,0]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe, 1:length(vars), repmat(max(get(mAxe, "YLim")) - 0.5, [1, length(vars)]), num2str(p'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe, 0.8, max(get(mAxe, "YLim")) - 1, '\bf{vs [900,1000]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe, 1:length(vars), repmat(max(get(mAxe, "YLim")) - 1, [1, length(vars)]), num2str(p2'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe, 0.8, max(get(mAxe, "YLim")) - 1.5, '\bf{vs control}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe, 2:length(vars), repmat(max(get(mAxe, "YLim")) - 1.5, [1, length(vars) - 1]), num2str(p3'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe, 0.8, min(get(mAxe, "YLim")) + 0.5, '\bf{base1 vs base2}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe, 1:length(vars), repmat(min(get(mAxe, "YLim")) + 0.5, [1, length(vars)]), num2str(pBase'), "HorizontalAlignment", "center", "FontSize", 12);
