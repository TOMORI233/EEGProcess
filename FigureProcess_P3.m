%% 精度
clear; clc; close all force;

chMeanData = load("..\DATA\MAT DATA\population\chMean_P3_Population.mat").data;
briData = load("..\DATA\MAT DATA\population\BRI_P3_Population.mat").data;

fs = briData(1).fs;
window = briData(1).window;
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

ICIsREG = [4, 4.01, 4.02, 4.03, 4.06];
ICIsIRREG = [4, 4.06];

%% chMean plot
temp = vertcat(chMeanData.chMeanData);

nREG = 0;
nIRREG = 0;

for index = 1:length(ICIsREG)
    idx = [temp.ICI] == ICIsREG(index) & [temp.type] == "REG";
    if any(idx)
        nREG = nREG + 1;
        chMeanREG(nREG, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
        chMeanREG(nREG, 1).ICI = ICIsREG(index);
        chMeanREG(nREG, 1).type = "REG";
        chMeanREG(nREG, 1).color = colors{nREG};
    end
end

for index = 1:length(ICIsIRREG)
    idx = [temp.ICI] == ICIsIRREG(index) & [temp.type] == "IRREG";
    if any(idx)
        nIRREG = nIRREG + 1;
        chMeanIRREG(nIRREG, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
        chMeanIRREG(nIRREG, 1).ICI = ICIsIRREG(index);
        chMeanIRREG(nIRREG, 1).type = "IRREG";
        chMeanIRREG(nIRREG, 1).color = colors{nIRREG + 2};
    end
end

FigREG = plotRawWaveMultiEEG(chMeanREG, window, "REG", EEGPos_Neuroscan64);
scaleAxes(FigREG, "x", [1000, 1500]);
scaleAxes(FigREG, "y", "on", "symOpt", "max", "uiOpt", "show");

FigIRREG = plotRawWaveMultiEEG(chMeanIRREG, window, "IRREG", EEGPos_Neuroscan64);
scaleAxes(FigIRREG, "x", [0, 2000]);
scaleAxes(FigIRREG, "y", "on", "symOpt", "max", "uiOpt", "show");

save("..\DATA\MAT DATA\figure\Res_chMean_P3.mat", ...
     "chMeanREG", "chMeanIRREG", "window");

%% BRI - REG
ICIsREG = [4, 4.01, 4.02, 4.03, 4.06];
meanBRI_REG = zeros(length(briData), length(ICIsREG));
meanBRIbase_REG = zeros(length(briData), length(ICIsREG));
meanBRIbase2_REG = zeros(length(briData), length(ICIsREG));
seBRI_REG = zeros(length(briData), length(ICIsREG));
seBRIbase_REG = zeros(length(briData), length(ICIsREG));
seBRIbase2_REG = zeros(length(briData), length(ICIsREG));

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;
    BRIbase = briData(bIndex).BRIbase;
    BRIbase2 = briData(bIndex).BRIbase2;

    for index = 1:length(ICIsREG)
        idx = [trialAll.ICI] == ICIsREG(index) & [trialAll.type] == "REG";
        meanBRI_REG(bIndex, index) = mean(BRI(idx));
        seBRI_REG(bIndex, index) = SE(BRI(idx));

        meanBRIbase_REG(bIndex, index) = mean(BRIbase(idx));
        seBRIbase_REG(bIndex, index) = SE(BRIbase(idx));

        meanBRIbase2_REG(bIndex, index) = mean(BRIbase2(idx));
        seBRIbase2_REG(bIndex, index) = SE(BRIbase2(idx));
    end

end

pREG = zeros(1, length(ICIsREG)); % vs baseline
pREG2 = zeros(1, length(ICIsREG)); % vs before change
pREG3 = zeros(1, length(ICIsREG) - 1); % vs control
pBaseREG = zeros(1, length(ICIsREG)); % baseline vs before change
for index = 1:length(ICIsREG)
    [~, pREG(index)] = ttest(meanBRI_REG(:, index), meanBRIbase_REG(:, index));
    [~, pREG2(index)] = ttest(meanBRI_REG(:, index), meanBRIbase2_REG(:, index));
    [~, pBaseREG(index)] = ttest(meanBRIbase_REG(:, index), meanBRIbase2_REG(:, index));

    if index > 1
        [~, pREG3(index - 1)] = ttest(meanBRI_REG(:, index), meanBRI_REG(:, 1));
    end
end

FigBRI = figure;
maximizeFig(FigBRI);
mAxe1 = mSubplot(FigBRI, 1, 2, 1, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(briData)
    errorbar(1:length(ICIsREG), meanBRI_REG(bIndex, :), seBRI_REG(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:length(ICIsREG), mean(meanBRI_REG, 1), SE(meanBRI_REG, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
xticks(1:length(ICIsREG));
xticklabels(num2str(ICIsREG'));
xlim([0.8, length(ICIsREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('BRI (\muV)');
title(['Non-behavior REG | N=', num2str(length(chMeanData))]);

%% BRI - IRREG
ICIsIRREG = [4, 4.06];
meanBRI_IRREG = zeros(length(briData), length(ICIsIRREG));
meanBRIbase_IRREG = zeros(length(briData), length(ICIsIRREG));
meanBRIbase2_IRREG = zeros(length(briData), length(ICIsIRREG));
seBRI_IRREG = zeros(length(briData), length(ICIsIRREG));
seBRIbase_IRREG = zeros(length(briData), length(ICIsIRREG));
seBRIbase2_IRREG = zeros(length(briData), length(ICIsIRREG));

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;
    BRIbase = briData(bIndex).BRIbase;
    BRIbase2 = briData(bIndex).BRIbase2;

    for index = 1:length(ICIsIRREG)
        idx = [trialAll.ICI] == ICIsIRREG(index) & [trialAll.type] == "IRREG";
        meanBRI_IRREG(bIndex, index) = mean(BRI(idx));
        seBRI_IRREG(bIndex, index) = SE(BRI(idx));

        meanBRIbase_IRREG(bIndex, index) = mean(BRIbase(idx));
        seBRIbase_IRREG(bIndex, index) = SE(BRIbase(idx));

        meanBRIbase2_IRREG(bIndex, index) = mean(BRIbase2(idx));
        seBRIbase2_IRREG(bIndex, index) = SE(BRIbase2(idx));
    end

end

pIRREG = zeros(1, length(ICIsIRREG)); % vs baseline
pIRREG2 = zeros(1, length(ICIsIRREG)); % vs before change
pIRREG3 = zeros(1, length(ICIsIRREG) - 1); % vs control
pBaseIRREG = zeros(1, length(ICIsIRREG)); % baseline vs before change
for index = 1:length(ICIsIRREG)
    [~, pIRREG(index)] = ttest(meanBRI_IRREG(:, index), meanBRIbase_IRREG(:, index));
    [~, pIRREG2(index)] = ttest(meanBRI_IRREG(:, index), meanBRIbase2_IRREG(:, index));
    [~, pBaseIRREG(index)] = ttest(meanBRIbase_IRREG(:, index), meanBRIbase2_IRREG(:, index));

    if index > 1
        [~, pIRREG3(index - 1)] = ttest(meanBRI_IRREG(:, index), meanBRI_IRREG(:, 1));
    end
end

mAxe2 = mSubplot(FigBRI, 1, 2, 2, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(briData)
    errorbar(1:length(ICIsIRREG), meanBRI_IRREG(bIndex, :), seBRI_IRREG(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:length(ICIsIRREG), mean(meanBRI_IRREG, 1), SE(meanBRI_IRREG, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG'));
xlim([0.8, length(ICIsIRREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('BRI (\muV)');
title('Non-behavior IRREG');

scaleAxes(FigBRI, "y");

text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 0.5, '\bf{vs [-300,0]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:length(ICIsREG), repmat(max(get(mAxe1, "YLim")) - 0.5, [1, length(ICIsREG)]), num2str(pREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 1, '\bf{vs [900,1000]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:length(ICIsREG), repmat(max(get(mAxe1, "YLim")) - 1, [1, length(ICIsREG)]), num2str(pREG2'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 1.5, '\bf{vs control}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 2:length(ICIsREG), repmat(max(get(mAxe1, "YLim")) - 1.5, [1, length(ICIsREG) - 1]), num2str(pREG3'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe1, 0.8, min(get(mAxe1, "YLim")) + 0.5, '\bf{base1 vs base2}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:length(ICIsREG), repmat(min(get(mAxe1, "YLim")) + 0.5, [1, length(ICIsREG)]), num2str(pBaseREG'), "HorizontalAlignment", "center", "FontSize", 12);

text(mAxe2, 1:length(ICIsIRREG), repmat(max(get(mAxe2, "YLim")) - 0.5, [1, length(ICIsIRREG)]), num2str(pIRREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 1:length(ICIsIRREG), repmat(max(get(mAxe2, "YLim")) - 1, [1, length(ICIsIRREG)]), num2str(pIRREG2'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 2, max(get(mAxe2, "YLim")) - 1.5, num2str(pIRREG3), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 1:length(ICIsIRREG), repmat(min(get(mAxe2, "YLim")) + 0.5, [1, length(ICIsIRREG)]), num2str(pBaseIRREG'), "HorizontalAlignment", "center", "FontSize", 12);

%% save
save("..\DATA\MAT DATA\figure\Res_BRI_P3.mat", ...
     "fs", ...
     "meanBRI_REG", ...
     "meanBRI_IRREG", ...
     "meanBRIbase_REG", ...
     "meanBRIbase_IRREG", ...
     "meanBRIbase2_REG", ...
     "meanBRIbase2_IRREG", ...
     "seBRI_REG", ...
     "seBRI_IRREG", ...
     "seBRIbase_REG", ...
     "seBRIbase_IRREG", ...
     "seBRIbase2_REG", ...
     "seBRIbase2_IRREG", ...
     "pREG", ...
     "pREG2", ...
     "pREG3", ...
     "pIRREG", ...
     "pIRREG2", ...
     "pIRREG3", ...
     "pBaseREG", ...
     "pBaseIRREG", ...
     "ICIsREG", ...
     "ICIsIRREG");
