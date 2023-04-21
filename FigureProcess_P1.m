%% 长度
clear; clc; close all force;

chMeanData = load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_P1_Population.mat").data;
briData = load("D:\Education\Lab\Projects\EEG\MAT Population\BRI_P1_Population.mat").data;

window = briData(1).window;
colors = flip(cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false));

%% chMean plot
temp = vertcat(chMeanData.chMeanData);
ICIs = unique([temp.ICI])';

nREG = 0;
nIRREG = 0;

for index = 1:length(ICIs)
    idx = [temp.ICI] == ICIs(index) & [temp.type] == "REG";
    if any(idx)
        nREG = nREG + 1;
        chMeanREG(nREG, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
        chMeanREG(nREG, 1).ICI = ICIs(index);
        chMeanREG(nREG, 1).type = "REG";
        chMeanREG(nREG, 1).color = colors{nREG};
    end

    idx = [temp.ICI] == ICIs(index) & [temp.type] == "IRREG";
    if any(idx)
        nIRREG = nIRREG + 1;
        chMeanIRREG(nIRREG, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
        chMeanIRREG(nIRREG, 1).ICI = ICIs(index);
        chMeanIRREG(nIRREG, 1).type = "IRREG";
        chMeanIRREG(nIRREG, 1).color = colors{nIRREG};
    end
end

FigREG = plotRawWaveMultiEEG(chMeanREG, window, 1000, "REG");
scaleAxes(FigREG, "x", [0, 1500]);
scaleAxes(FigREG, "y", "on", "symOpt", "max", "uiOpt", "show");

FigIRREG = plotRawWaveMultiEEG(chMeanIRREG, window, 1000, "IRREG");
scaleAxes(FigIRREG, "x", [0, 1500]);
scaleAxes(FigIRREG, "y", "on", "symOpt", "max", "uiOpt", "show");

%% BRI - REG
ICIs = [4.06, 8.12, 16.24, 32.48];
meanBRI_REG = zeros(length(briData), 4);
seBRI_REG = zeros(length(briData), 4);

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;

    for index = 1:length(ICIs)
        temp = BRI([trialAll.ICI] == ICIs(index) & [trialAll.type] == "REG");
        meanBRI_REG(bIndex, index) = mean(temp);
        seBRI_REG(bIndex, index) = SE(temp);
    end

end

trialAllPopu = [briData.trialAll]';
BRIPopu = vertcat(briData.BRI);
BRIbasePopu = vertcat(briData.BRIbase);
BRIbase2Popu = vertcat(briData.BRIbase2);
pREG = zeros(1, 4);
pREG2 = zeros(1, 4);
[~, pBaseREG] = ttest(BRIbasePopu([trialAllPopu.type] == "REG"), BRIbase2Popu([trialAllPopu.type] == "REG"));
for index = 1:length(ICIs)
    idx = [trialAllPopu.ICI] == ICIs(index) & [trialAllPopu.type] == "REG";
    [~, pREG(index)] = ttest(BRIPopu(idx), BRIbasePopu(idx));
    [~, pREG2(index)] = ttest(BRIPopu(idx), BRIbase2Popu(idx));
end

FigBRI = figure;
maximizeFig(FigBRI);
mAxe1 = mSubplot(FigBRI, 1, 2, 1, "shape", "square-min");
for bIndex = 1:length(briData)
    errorbar(1:4, meanBRI_REG(bIndex, :), seBRI_REG(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:4, mean(meanBRI_REG, 1), SE(meanBRI_REG, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
xticks(1:4);
xticklabels(num2str(ICIs'));
xlim([0.8, 4.2]);
xlabel('S2 ICI(ms)');
ylabel('BRI(\muV)');
title(['REG | p_{Baseline [-300,0] vs Before change [900,1000]}=', num2str(pBaseREG)]);

%% BRI - IRREG
ICIs = [4.06, 8.12, 16.24, 32.48];
meanBRI_IRREG = zeros(length(briData), 4);
seBRI_IRREG = zeros(length(briData), 4);

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;

    for index = 1:length(ICIs)
        temp = BRI([trialAll.ICI] == ICIs(index) & [trialAll.type] == "IRREG");
        meanBRI_IRREG(bIndex, index) = mean(temp);
        seBRI_IRREG(bIndex, index) = SE(temp);
    end

end

trialAllPopu = [briData.trialAll]';
BRIPopu = vertcat(briData.BRI);
BRIbasePopu = vertcat(briData.BRIbase);
BRIbase2Popu = vertcat(briData.BRIbase2);
pIRREG = zeros(1, 4);
pIRREG2 = zeros(1, 4);
[~, pBaseIRREG] = ttest(BRIbasePopu([trialAll.type] == "IRREG"), BRIbase2Popu([trialAll.type] == "IRREG"));
for index = 1:length(ICIs)
    idx = [trialAllPopu.ICI] == ICIs(index) & [trialAllPopu.type] == "IRREG";
    [~, pIRREG(index)] = ttest(BRIPopu(idx), BRIbasePopu(idx));
    [~, pIRREG2(index)] = ttest(BRIPopu(idx), BRIbase2Popu(idx));
end

mAxe2 = mSubplot(1, 2, 2, "shape", "square-min");
for bIndex = 1:length(briData)
    errorbar(1:4, meanBRI_IRREG(bIndex, :), seBRI_IRREG(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:4, mean(meanBRI_IRREG, 1), SE(meanBRI_IRREG, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
xticks(1:4);
xticklabels(num2str(ICIs'));
xlim([0.8, 4.2]);
xlabel('S2 ICI(ms)');
ylabel('BRI(\muV)');
title(['IRREG | p_{Baseline [-300,0] vs Before change [900,1000]}=', num2str(pBaseIRREG)]);

scaleAxes(FigBRI, "y");

text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 0.5, 'vs \bf{[-300,0]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:4, repmat(max(get(mAxe1, "YLim")) - 0.5, [1, 4]), num2str(pREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 1, 'vs \bf{[900,1000]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:4, repmat(max(get(mAxe1, "YLim")) - 1, [1, 4]), num2str(pREG2'), "HorizontalAlignment", "center", "FontSize", 12);

text(mAxe2, 0.8, max(get(mAxe2, "YLim")) - 0.5, 'vs \bf{[-300,0]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe2, 1:4, repmat(max(get(mAxe2, "YLim")) - 0.5, [1, 4]), num2str(pIRREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 0.8, max(get(mAxe2, "YLim")) - 1, 'vs \bf{[900,1000]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe2, 1:4, repmat(max(get(mAxe2, "YLim")) - 1, [1, 4]), num2str(pIRREG2'), "HorizontalAlignment", "center", "FontSize", 12);