clear; clc; close all force;

%% Compare BRI
dataA1 = load("D:\Education\Lab\Projects\EEG\Figure DATA\Res_BRI_A1.mat");
dataP3 = load("D:\Education\Lab\Projects\EEG\Figure DATA\Res_BRI_P3.mat");

subjectIdx = find(dataA1.subjectIdx);
ICIsREG = dataA1.ICIsREG;
ICIsIRREG = dataA1.ICIsIRREG;

% BRI - REG
FigBRI = figure;
maximizeFig(FigBRI);
mAxe1 = mSubplot(FigBRI, 1, 2, 1, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(subjectIdx)
    eb = errorbar(1:length(ICIsREG), dataA1.meanBRI_REG(bIndex, :), dataA1.seBRI_REG(bIndex, :), ...
                  'Color', [255 192 203] / 255, 'LineWidth', 1);
    setLegendOff(eb);
    hold on;
    eb = errorbar(1:length(ICIsREG), dataP3.meanBRI_REG(subjectIdx(bIndex), :), dataP3.seBRI_REG(subjectIdx(bIndex), :), ...
                  'Color', [200 200 200] / 255, 'LineWidth', 1);
    setLegendOff(eb);
end
errorbar(1:length(ICIsREG), mean(dataA1.meanBRI_REG, 1), SE(dataA1.meanBRI_REG, 1), 'Color', 'r', 'LineWidth', 2, 'DisplayName', 'Behavior');
errorbar(1:length(ICIsREG), mean(dataP3.meanBRI_REG(subjectIdx, :), 1), SE(dataP3.meanBRI_REG(subjectIdx, :), 1), 'Color', 'k', 'LineWidth', 2, 'DisplayName', 'Non-behavior');
legend;
set(gca, 'FontSize', 12);
xticks(1:length(ICIsREG));
xticklabels(num2str(ICIsREG'));
xlim([0.8, length(ICIsREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('BRI (\muV)');
title('REG');

% BRI - IRREG
mAxe2 = mSubplot(FigBRI, 1, 2, 2, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(subjectIdx)
    eb = errorbar(1:length(ICIsIRREG), dataA1.meanBRI_IRREG(bIndex, :), dataA1.seBRI_IRREG(bIndex, :), ...
                  'Color', [255 192 203] / 255, 'LineWidth', 1);
    setLegendOff(eb);
    hold on;
    eb = errorbar(1:length(ICIsIRREG), dataP3.meanBRI_IRREG(subjectIdx(bIndex), :), dataP3.seBRI_IRREG(subjectIdx(bIndex), :), ...
                  'Color', [200 200 200] / 255, 'LineWidth', 1);
    setLegendOff(eb);
end
errorbar(1:length(ICIsIRREG), mean(dataA1.meanBRI_IRREG, 1), SE(dataA1.meanBRI_IRREG, 1), 'Color', 'r', 'LineWidth', 2, 'DisplayName', 'Behavior');
errorbar(1:length(ICIsIRREG), mean(dataP3.meanBRI_IRREG(subjectIdx, :), 1), SE(dataP3.meanBRI_IRREG(subjectIdx, :), 1), 'Color', 'k', 'LineWidth', 2, 'DisplayName', 'Non-behavior');
legend;
set(gca, 'FontSize', 12);
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG'));
xlim([0.8, length(ICIsIRREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('BRI (\muV)');
title('IRREG');

pREG = zeros(1, length(ICIsREG));
for index = 1:length(ICIsREG)
    [~, pREG(index)] = ttest(dataA1.meanBRI_REG(:, index), dataP3.meanBRI_REG(subjectIdx, index));
end

pIRREG = zeros(1, length(ICIsIRREG));
for index = 1:length(ICIsIRREG)
    [~, pIRREG(index)] = ttest(dataA1.meanBRI_IRREG(:, index), dataP3.meanBRI_IRREG(subjectIdx, index));
end

scaleAxes(FigBRI, "y");

text(mAxe1, 1:length(ICIsREG), repmat(min(get(mAxe1, "YLim")) + 0.5, [1, length(ICIsREG)]), num2str(pREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 1:length(ICIsIRREG), repmat(min(get(mAxe2, "YLim")) + 0.5, [1, length(ICIsIRREG)]), num2str(pIRREG'), "HorizontalAlignment", "center", "FontSize", 12);

% Diff BRI
diffBRI_REG = dataA1.meanBRI_REG - dataP3.meanBRI_REG(subjectIdx, :);
diffBRI_IRREG = dataA1.meanBRI_IRREG - dataP3.meanBRI_IRREG(subjectIdx, :);
FigDiff = figure;
maximizeFig(FigDiff);
mSubplot(FigDiff, 1, 1, 1, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
hold(gca, "on");
errorbar([1, 5], mean(diffBRI_IRREG, 1), SE(diffBRI_IRREG, 1), 'Color', 'b', 'LineWidth', 2, 'DisplayName', 'IRREG Difference');
errorbar(1:length(ICIsREG), mean(diffBRI_REG, 1), SE(diffBRI_REG, 1), 'Color', 'r', 'LineWidth', 2, 'DisplayName', 'REG Difference');
legend("Location", "best");
set(gca, 'FontSize', 12);
xticks(1:length(ICIsREG));
xticklabels(num2str(ICIsREG'));
xlim([0.8, length(ICIsREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('\Delta BRI (\muV)');
title('Behavior - Non-behavior');

%% Compare Wave
