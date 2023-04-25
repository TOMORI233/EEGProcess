clear; clc; close all force;

margins = [0.05, 0.05, 0.1, 0.1];
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

load("windowBRI4.mat", "windowBRI");

%% Compare BRI
dataA1 = load("D:\Education\Lab\Projects\EEG\Figure DATA\Res_BRI_A1.mat");
dataP3 = load("D:\Education\Lab\Projects\EEG\Figure DATA\Res_BRI_P3.mat");
fs = dataA1.fs;
tBRI = windowBRI(1):1000 / fs:windowBRI(2);

subjectIdx = dataA1.subjectIdx;
ICIsREG = dataA1.ICIsREG;
ICIsIRREG = dataA1.ICIsIRREG;

% BRI - REG
FigBRI = figure;
maximizeFig(FigBRI);
mAxe1 = mSubplot(FigBRI, 1, 2, 1, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(subjectIdx)
    if subjectIdx(bIndex)
        eb = errorbar(1:length(ICIsREG), dataA1.meanBRI_REG(bIndex, :) - dataA1.meanBRIbase2_REG(bIndex, :), dataA1.seBRI_REG(bIndex, :), ...
                      'Color', [255 192 203] / 255, 'LineWidth', 1);
        setLegendOff(eb);
        hold on;
        eb = errorbar(1:length(ICIsREG), dataP3.meanBRI_REG(bIndex, :) - dataP3.meanBRIbase2_REG(bIndex, :), dataP3.seBRI_REG(bIndex, :), ...
                      'Color', [200 200 200] / 255, 'LineWidth', 1);
        setLegendOff(eb);
    end
end
errorbar(1:length(ICIsREG), mean(dataA1.meanBRI_REG(subjectIdx, :) - dataA1.meanBRIbase2_REG(subjectIdx, :), 1), SE(dataA1.meanBRI_REG(subjectIdx, :) - dataA1.meanBRIbase2_REG(subjectIdx, :), 1), 'Color', 'r', 'LineWidth', 2, 'DisplayName', 'Behavior');
errorbar(1:length(ICIsREG), mean(dataP3.meanBRI_REG(subjectIdx, :) - dataP3.meanBRIbase2_REG(subjectIdx, :), 1), SE(dataP3.meanBRI_REG(subjectIdx, :) - dataP3.meanBRIbase2_REG(subjectIdx, :), 1), 'Color', 'k', 'LineWidth', 2, 'DisplayName', 'Non-behavior');
legend;
set(gca, 'FontSize', 12);
xticks(1:length(ICIsREG));
xticklabels(num2str(ICIsREG'));
xlim([0.8, length(ICIsREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('\Delta BRI_{vs Before change} (\muV)');
title(['REG (N=', num2str(sum(subjectIdx)), ')']);

% BRI - IRREG
mAxe2 = mSubplot(FigBRI, 1, 2, 2, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(subjectIdx)
    if subjectIdx(bIndex)
        eb = errorbar(1:length(ICIsIRREG), dataA1.meanBRI_IRREG(bIndex, :) - dataA1.meanBRIbase2_IRREG(bIndex, :), dataA1.seBRI_IRREG(bIndex, :), ...
                      'Color', [255 192 203] / 255, 'LineWidth', 1);
        setLegendOff(eb);
        hold on;
        eb = errorbar(1:length(ICIsIRREG), dataP3.meanBRI_IRREG(subjectIdx(bIndex), :) - dataP3.meanBRIbase2_IRREG(subjectIdx(bIndex), :), dataP3.seBRI_IRREG(subjectIdx(bIndex), :), ...
                      'Color', [200 200 200] / 255, 'LineWidth', 1);
        setLegendOff(eb);
    end
end
errorbar(1:length(ICIsIRREG), mean(dataA1.meanBRI_IRREG(subjectIdx, :) - dataA1.meanBRIbase2_IRREG(subjectIdx, :), 1), SE(dataA1.meanBRI_IRREG(subjectIdx, :) - dataA1.meanBRIbase2_IRREG(subjectIdx, :), 1), 'Color', 'r', 'LineWidth', 2, 'DisplayName', 'Behavior');
errorbar(1:length(ICIsIRREG), mean(dataP3.meanBRI_IRREG(subjectIdx, :) - dataP3.meanBRIbase2_IRREG(subjectIdx, :), 1), SE(dataP3.meanBRI_IRREG(subjectIdx, :) - dataP3.meanBRIbase2_IRREG(subjectIdx, :), 1), 'Color', 'k', 'LineWidth', 2, 'DisplayName', 'Non-behavior');
legend;
set(gca, 'FontSize', 12);
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG'));
xlim([0.8, length(ICIsIRREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('\Delta BRI_{vs Before change} (\muV)');
title('IRREG');

pREG = zeros(1, length(ICIsREG));
for index = 1:length(ICIsREG)
    [~, pREG(index)] = ttest(dataA1.meanBRI_REG(subjectIdx, index) - dataA1.meanBRIbase2_REG(subjectIdx, index), dataP3.meanBRI_REG(subjectIdx, index) - dataP3.meanBRIbase2_REG(subjectIdx, index));
end

pIRREG = zeros(1, length(ICIsIRREG));
for index = 1:length(ICIsIRREG)
    [~, pIRREG(index)] = ttest(dataA1.meanBRI_IRREG(subjectIdx, index) - dataA1.meanBRIbase2_IRREG(subjectIdx, index), dataP3.meanBRI_IRREG(subjectIdx, index) - dataP3.meanBRIbase2_IRREG(subjectIdx, index));
end

scaleAxes(FigBRI, "y");

text(mAxe1, 1:length(ICIsREG), repmat(min(get(mAxe1, "YLim")) + 0.5, [1, length(ICIsREG)]), num2str(pREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 1:length(ICIsIRREG), repmat(min(get(mAxe2, "YLim")) + 0.5, [1, length(ICIsIRREG)]), num2str(pIRREG'), "HorizontalAlignment", "center", "FontSize", 12);

% Diff BRI
diffBRI_REG = (dataA1.meanBRI_REG(subjectIdx, :) - dataA1.meanBRIbase2_REG(subjectIdx, :)) - (dataP3.meanBRI_REG(subjectIdx, :) - dataP3.meanBRIbase2_REG(subjectIdx, :));
diffBRI_IRREG = (dataA1.meanBRI_IRREG(subjectIdx, :) - dataA1.meanBRIbase2_IRREG(subjectIdx, :)) - (dataP3.meanBRI_IRREG(subjectIdx, :) - dataP3.meanBRIbase2_IRREG(subjectIdx, :));
FigDiff = figure;
maximizeFig(FigDiff);
mSubplot(FigDiff, 1, 1, 1, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
hold(gca, "on");
errorbar([1, 5], mean(diffBRI_IRREG, 1), SE(diffBRI_IRREG, 1), 'Color', 'b', 'LineWidth', 2, 'DisplayName', 'IRREG Difference');
errorbar(1:length(ICIsREG), mean(diffBRI_REG, 1), SE(diffBRI_REG, 1), 'Color', 'r', 'LineWidth', 2, 'DisplayName', 'REG Difference');
legend("Location", "northwest");
set(gca, 'FontSize', 12);
xticks(1:length(ICIsREG));
xticklabels(num2str(ICIsREG'));
xlim([0.8, length(ICIsREG) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('\Delta BRI (\muV)');
title('Behavior - Non-behavior');

%% Compare Wave
waveDataA1 = load("D:\Education\Lab\Projects\EEG\Figure DATA\Res_chMean_A1.mat");
waveDataP3 = load("D:\Education\Lab\Projects\EEG\Figure DATA\Res_chMean_P3.mat");
load("chsAvg.mat", "chsAvg");
window = waveDataA1.window;
t = linspace(window(1), window(2), size(waveDataA1.chMeanREG(index).chMean, 2));

% REG
figure;
maximizeFig;
for index = 1:length(waveDataA1.chMeanREG)
    chMeanA1 = mean(waveDataA1.chMeanREG(index).chMean(chsAvg, :), 1);
    chMeanP3 = mean(waveDataP3.chMeanREG(index).chMean(chsAvg, :), 1);
    mSubplot(2, 3, index, "margins", margins);
    plot(t - 1000, chMeanA1, 'r', 'LineWidth', 2, 'DisplayName', 'Behavior');
    hold on;
    plot(t - 1000, chMeanP3, 'k', 'LineWidth', 2, 'DisplayName', 'Non-behavior');
    legend;
    set(gca, 'FontSize', 12);
    xlabel('Time from change point (ms)');
    ylabel('ERP (\muV)');
    title(['REG S2 ICI = ', num2str(waveDataA1.chMeanREG(index).ICI), ' ms']);
end
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", -1000, "width", 2));
addLines2Axes(struct("X", 0, "width", 2));

figure;
maximizeFig;
mAxe1 = mSubplot(1, 2, 1, "margins", margins);
hold(mAxe1, "on");
set(mAxe1, 'FontSize', 12);
mAxe2 = mSubplot(1, 2, 2, "margins", margins);
hold(mAxe2, "on");
set(mAxe2, 'FontSize', 12);
for index = 1:length(waveDataA1.chMeanREG)
    chMeanA1 = mean(waveDataA1.chMeanREG(index).chMean(chsAvg, :), 1);
    chMeanP3 = mean(waveDataP3.chMeanREG(index).chMean(chsAvg, :), 1);
    plot(mAxe1, t - 1000, chMeanA1, 'Color', colors{index}, 'LineWidth', 2, 'DisplayName', num2str(waveDataA1.chMeanREG(index).ICI));
    plot(mAxe2, t - 1000, chMeanP3, 'Color', colors{index}, 'LineWidth', 2, 'DisplayName', num2str(waveDataP3.chMeanREG(index).ICI));
end
legend(mAxe1);
legend(mAxe2);
xlabel([mAxe1, mAxe2], 'Time from change point (ms)');
ylabel([mAxe1, mAxe2], 'ERP (\muV)');
title(mAxe1, 'Behavior REG');
title(mAxe2, 'Non-behavior REG');
scaleAxes("x", [-100, 500]);
yRange = scaleAxes("y", "on", "symOpt", "max");
b(1) = bar(mAxe1, tBRI - 1000, repmat(yRange(1), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off', 'DisplayName', 'BRI window');
b(2) = bar(mAxe1, tBRI - 1000, repmat(yRange(2), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
b(3) = bar(mAxe2, tBRI - 1000, repmat(yRange(1), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off', 'DisplayName', 'BRI window');
b(4) = bar(mAxe2, tBRI - 1000, repmat(yRange(2), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
arrayfun(@(x) setLegendOff(x), b([2, 4]));
addLines2Axes(struct("X", 0, "width", 2));

% IRREG
figure;
maximizeFig;
for index = 1:length(waveDataA1.chMeanIRREG)
    chMeanA1 = mean(waveDataA1.chMeanIRREG(index).chMean(chsAvg, :), 1);
    chMeanP3 = mean(waveDataP3.chMeanIRREG(index).chMean(chsAvg, :), 1);
    mSubplot(1, 2, index, "margins", margins);
    plot(t - 1000, chMeanA1, 'r', 'LineWidth', 2, 'DisplayName', 'Behavior');
    hold on;
    plot(t - 1000, chMeanP3, 'k', 'LineWidth', 2, 'DisplayName', 'Non-behavior');
    legend;
    set(gca, 'FontSize', 12);
    xlabel('Time from change point (ms)');
    ylabel('ERP (\muV)');
    title(['IRREG S2 ICI = ', num2str(waveDataA1.chMeanIRREG(index).ICI), ' ms']);
end
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", -1000, "width", 2));
addLines2Axes(struct("X", 0, "width", 2));

figure;
maximizeFig;
mAxe1 = mSubplot(1, 2, 1, "margins", margins);
hold(mAxe1, "on");
set(mAxe1, 'FontSize', 12);
mAxe2 = mSubplot(1, 2, 2, "margins", margins);
hold(mAxe2, "on");
set(mAxe2, 'FontSize', 12);
for index = 1:length(waveDataA1.chMeanIRREG)
    chMeanA1 = mean(waveDataA1.chMeanIRREG(index).chMean(chsAvg, :), 1);
    chMeanP3 = mean(waveDataP3.chMeanIRREG(index).chMean(chsAvg, :), 1);
    plot(mAxe1, t - 1000, chMeanA1, 'Color', colors{index}, 'LineWidth', 2, 'DisplayName', num2str(waveDataA1.chMeanIRREG(index).ICI));
    plot(mAxe2, t - 1000, chMeanP3, 'Color', colors{index}, 'LineWidth', 2, 'DisplayName', num2str(waveDataP3.chMeanIRREG(index).ICI));
end
legend(mAxe1);
legend(mAxe2);
xlabel([mAxe1, mAxe2], 'Time from change point (ms)');
ylabel([mAxe1, mAxe2], 'ERP (\muV)');
title(mAxe1, 'Behavior IRREG');
title(mAxe2, 'Non-behavior IRREG');
scaleAxes("x", [-100, 500]);
yRange = scaleAxes("y", "on", "symOpt", "max");
b(1) = bar(mAxe1, tBRI - 1000, repmat(yRange(1), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off', 'DisplayName', 'BRI window');
b(2) = bar(mAxe1, tBRI - 1000, repmat(yRange(2), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
b(3) = bar(mAxe2, tBRI - 1000, repmat(yRange(1), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off', 'DisplayName', 'BRI window');
b(4) = bar(mAxe2, tBRI - 1000, repmat(yRange(2), [length(tBRI), 1]), 1, 'FaceColor', [0 0 0], 'EdgeColor', 'none', 'FaceAlpha', 0.1, 'ShowBaseLine', 'off');
arrayfun(@(x) setLegendOff(x), b([2, 4]));
addLines2Axes(struct("X", 0, "width", 2));