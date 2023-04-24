%% 长度
clear; clc; close all force;

chMeanData = load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_P1_Population.mat").data;
briData = load("D:\Education\Lab\Projects\EEG\MAT Population\BRI_P1_Population.mat").data;

load("chsAvg.mat", "chsAvg");
fs = briData(1).fs;
window = briData(1).window;
colors = flip(cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false));

%% chMean plot
temp = vertcat(chMeanData.chMeanData);
ICIs = unique([temp.ICI]);

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
        chMeanAvgREG(nREG, 1).chMean = mean(chMeanREG(nREG, 1).chMean(chsAvg, :), 1);
        chMeanAvgREG(nREG, 1).color = colors{nREG};
        chMeanAvgREG(nREG, 1).ICI = ICIs(index);
    end

    idx = [temp.ICI] == ICIs(index) & [temp.type] == "IRREG";
    if any(idx)
        nIRREG = nIRREG + 1;
        chMeanIRREG(nIRREG, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
        chMeanIRREG(nIRREG, 1).ICI = ICIs(index);
        chMeanIRREG(nIRREG, 1).type = "IRREG";
        chMeanIRREG(nIRREG, 1).color = colors{nIRREG};
        chMeanAvgIRREG(nIRREG, 1).chMean = mean(chMeanIRREG(nIRREG, 1).chMean(chsAvg, :), 1);
        chMeanAvgIRREG(nIRREG, 1).color = colors{nIRREG};
        chMeanAvgIRREG(nIRREG, 1).ICI = ICIs(index);
    end
end

FigREG = plotRawWaveMultiEEG(chMeanREG, window, 1000, "REG");
scaleAxes(FigREG, "x", [0, 1500]);
scaleAxes(FigREG, "y", "on", "symOpt", "max", "uiOpt", "show");

FigIRREG = plotRawWaveMultiEEG(chMeanIRREG, window, 1000, "IRREG");
scaleAxes(FigIRREG, "x", [0, 1500]);
scaleAxes(FigIRREG, "y", "on", "symOpt", "max", "uiOpt", "show");

%% average in channels
t = linspace(window(1), window(2), size(chMeanREG(1).chMean, 2));
figure;
maximizeFig;
mSubplot(1, 2, 1);
hold(gca, "on");
for index = 1:length(chMeanAvgREG)
    plot(t - 1000, chMeanAvgREG(index).chMean, "Color", chMeanAvgREG(index).color, "LineWidth", 2, "DisplayName", num2str(chMeanAvgREG(index).ICI));
end
set(gca, "FontSize", 15);
legend;
xlabel("Time from change point (ms)");
ylabel("ERP (\muV)");
title("REG");

mSubplot(1, 2, 2);
hold(gca, "on");
for index = 1:length(chMeanAvgIRREG)
    plot(t - 1000, chMeanAvgIRREG(index).chMean, "Color", chMeanAvgIRREG(index).color, "LineWidth", 2, "DisplayName", num2str(chMeanAvgIRREG(index).ICI));
end
set(gca, "FontSize", 15);
legend;
xlabel("Time from change point (ms)");
ylabel("ERP (\muV)");
title("IRREG");
scaleAxes("x", [-1300, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", -1000, "width", 2));
addLines2Axes(struct("X", 0, "width", 2));

%% FFT
[fftResREG, f] = arrayfun(@(x) mfft(x.chMean, fs), chMeanAvgREG, "UniformOutput", false);
fftResIRREG = arrayfun(@(x) mfft(x.chMean, fs), chMeanAvgIRREG, "UniformOutput", false);

figure;
maximizeFig;
mSubplot(1, 2, 1);
hold(gca, "on");
for index = 1:length(fftResREG)
    plot(f{1}, fftResREG{index}, "Color", chMeanAvgREG(index).color, "LineWidth", 2, "DisplayName", num2str(chMeanAvgREG(index).ICI));
end
set(gca, "FontSize", 15);
legend;
xlabel("Frequency (Hz)");
ylabel("FFT spect");
title("REG");

mSubplot(1, 2, 2);
hold(gca, "on");
for index = 1:length(fftResIRREG)
    plot(f{1}, fftResIRREG{index}, "Color", chMeanAvgIRREG(index).color, "LineWidth", 2, "DisplayName", num2str(chMeanAvgIRREG(index).ICI));
end
set(gca, "FontSize", 15);
legend;
xlabel("Frequency (Hz)");
ylabel("FFT spect");
title("IRREG");
scaleAxes("x", [0, 50]);
scaleAxes("y");

%% BRI - REG
meanBRI_REG = zeros(length(briData), length(ICIs));
meanBRIbase_REG = zeros(length(briData), length(ICIs));
meanBRIbase2_REG = zeros(length(briData), length(ICIs));
seBRI_REG = zeros(length(briData), length(ICIs));
seBRIbase_REG = zeros(length(briData), length(ICIs));
seBRIbase2_REG = zeros(length(briData), length(ICIs));

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;
    BRIbase = briData(bIndex).BRIbase;
    BRIbase2 = briData(bIndex).BRIbase2;

    for index = 1:length(ICIs)
        idx = [trialAll.ICI] == ICIs(index) & [trialAll.type] == "REG";
        meanBRI_REG(bIndex, index) = mean(BRI(idx));
        seBRI_REG(bIndex, index) = SE(BRI(idx));

        meanBRIbase_REG(bIndex, index) = mean(BRIbase(idx));
        seBRIbase_REG(bIndex, index) = SE(BRIbase(idx));

        meanBRIbase2_REG(bIndex, index) = mean(BRIbase2(idx));
        seBRIbase2_REG(bIndex, index) = SE(BRIbase2(idx));
    end

end

pREG = zeros(1, length(ICIs)); % vs baseline
pREG2 = zeros(1, length(ICIs)); % vs before change
pREG3 = zeros(1, length(ICIs) - 1); % vs control
pBaseREG = zeros(1, length(ICIs)); % baseline vs before change
for index = 1:length(ICIs)
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
    errorbar(1:length(ICIs), meanBRI_REG(bIndex, :), seBRI_REG(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:length(ICIs), mean(meanBRI_REG, 1), SE(meanBRI_REG, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
xticks(1:length(ICIs));
xticklabels(num2str(ICIs'));
xlim([0.8, length(ICIs) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('BRI (\muV)');
title('REG');

%% BRI - IRREG
meanBRI_IRREG = zeros(length(briData), length(ICIs));
meanBRIbase_IRREG = zeros(length(briData), length(ICIs));
meanBRIbase2_IRREG = zeros(length(briData), length(ICIs));
seBRI_IRREG = zeros(length(briData), length(ICIs));
seBRIbase_IRREG = zeros(length(briData), length(ICIs));
seBRIbase2_IRREG = zeros(length(briData), length(ICIs));

for bIndex = 1:length(briData)
    trialAll = briData(bIndex).trialAll;
    BRI = briData(bIndex).BRI;
    BRIbase = briData(bIndex).BRIbase;
    BRIbase2 = briData(bIndex).BRIbase2;

    for index = 1:length(ICIs)
        idx = [trialAll.ICI] == ICIs(index) & [trialAll.type] == "IRREG";
        meanBRI_IRREG(bIndex, index) = mean(BRI(idx));
        seBRI_IRREG(bIndex, index) = SE(BRI(idx));

        meanBRIbase_IRREG(bIndex, index) = mean(BRIbase(idx));
        seBRIbase_IRREG(bIndex, index) = SE(BRIbase(idx));

        meanBRIbase2_IRREG(bIndex, index) = mean(BRIbase2(idx));
        seBRIbase2_IRREG(bIndex, index) = SE(BRIbase2(idx));
    end

end

pIRREG = zeros(1, length(ICIs)); % vs baseline
pIRREG2 = zeros(1, length(ICIs)); % vs before change
pIRREG3 = zeros(1, length(ICIs) - 1); % vs control
pBaseIRREG = zeros(1, length(ICIs)); % baseline vs before change
for index = 1:length(ICIs)
    [~, pIRREG(index)] = ttest(meanBRI_IRREG(:, index), meanBRIbase_IRREG(:, index));
    [~, pIRREG2(index)] = ttest(meanBRI_IRREG(:, index), meanBRIbase2_IRREG(:, index));
    [~, pBaseIRREG(index)] = ttest(meanBRIbase_IRREG(:, index), meanBRIbase2_IRREG(:, index));

    if index > 1
        [~, pIRREG3(index - 1)] = ttest(meanBRI_IRREG(:, index), meanBRI_IRREG(:, 1));
    end
end

mAxe2 = mSubplot(FigBRI, 1, 2, 2, "shape", "square-min", "padding_left", 0.05, "padding_right", 0.05);
for bIndex = 1:length(briData)
    errorbar(1:length(ICIs), meanBRI_IRREG(bIndex, :), seBRI_IRREG(bIndex, :), 'Color', [200 200 200] / 255, 'LineWidth', 1);
    hold on;
end
errorbar(1:length(ICIs), mean(meanBRI_IRREG, 1), SE(meanBRI_IRREG, 1), 'Color', 'r', 'LineWidth', 2);
set(gca, 'FontSize', 12);
xticks(1:length(ICIs));
xticklabels(num2str(ICIs'));
xlim([0.8, length(ICIs) + 0.2]);
xlabel('S2 ICI (ms)');
ylabel('BRI (\muV)');
title('IRREG');

scaleAxes(FigBRI, "y");

text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 0.5, '\bf{vs [-300,0]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:length(ICIs), repmat(max(get(mAxe1, "YLim")) - 0.5, [1, length(ICIs)]), num2str(pREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 1, '\bf{vs [900,1000]}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:length(ICIs), repmat(max(get(mAxe1, "YLim")) - 1, [1, length(ICIs)]), num2str(pREG2'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe1, 0.8, max(get(mAxe1, "YLim")) - 1.5, '\bf{vs control}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 2:length(ICIs), repmat(max(get(mAxe1, "YLim")) - 1.5, [1, length(ICIs) - 1]), num2str(pREG3'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe1, 0.8, min(get(mAxe1, "YLim")) + 0.5, '\bf{base1 vs base2}', "HorizontalAlignment", "right", "FontSize", 12);
text(mAxe1, 1:length(ICIs), repmat(min(get(mAxe1, "YLim")) + 0.5, [1, length(ICIs)]), num2str(pBaseREG'), "HorizontalAlignment", "center", "FontSize", 12);

text(mAxe2, 1:length(ICIs), repmat(max(get(mAxe2, "YLim")) - 0.5, [1, length(ICIs)]), num2str(pIRREG'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 1:length(ICIs), repmat(max(get(mAxe2, "YLim")) - 1, [1, length(ICIs)]), num2str(pIRREG2'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 2:length(ICIs), repmat(max(get(mAxe2, "YLim")) - 1.5, [1, length(ICIs) - 1]), num2str(pIRREG3'), "HorizontalAlignment", "center", "FontSize", 12);
text(mAxe2, 1:length(ICIs), repmat(min(get(mAxe2, "YLim")) + 0.5, [1, length(ICIs)]), num2str(pBaseIRREG'), "HorizontalAlignment", "center", "FontSize", 12);

%% save
ICIsREG = ICIs;
ICIsIRREG = ICIs;
save("D:\Education\Lab\Projects\EEG\Figure DATA\Res_BRI_P1.mat", ...
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