ccc;

ROOTPATH = '..\DATA\MAT DATA\temp';

margins = [0.05, 0.05, 0.1, 0.1];

ICIsREG = [4, 4.01, 4.02, 4.03, 4.06];
ICIsIRREG = [4, 4.06, 8];
freqs = [246.3054, 250];

thL = 0.3;
thH = 0.6;
thBeh = 0.5;

set(0, "DefaultAxesFontSize", 12);
set(0, "DefaultAxesTitleFontWeight", "bold");

%% Load - A1
DATAPATHs = dir(fullfile(ROOTPATH, '**\active1\behavior.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'active1\behavior.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

data = cellfun(@(x) load(x).behaviorRes, DATAPATHs, "UniformOutput", false);

temp = cellfun(@(x) x([x.type] == "REG" & ismember([x.ICI], ICIsREG)), data, "UniformOutput", false);
resREG_A1 = cellfun(@(x) [x.nDiff] ./ [x.nTotal], temp, "UniformOutput", false);

temp = cellfun(@(x) x([x.type] == "IRREG" & ismember([x.ICI], ICIsIRREG)), data, "UniformOutput", false);
resIRREG_A1 = cellfun(@(x) [x.nDiff] ./ [x.nTotal], temp, "UniformOutput", false);

temp = cellfun(@(x) x([x.type] == "PT" & ismember([x.freq], freqs)), data, "UniformOutput", false);
resPT_A1 = cellfun(@(x) [x.nDiff] ./ [x.nTotal], temp, "UniformOutput", false);

%% Load - A2
DATAPATHs = dir(fullfile(ROOTPATH, '**\active2\behavior.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

data = cellfun(@(x) load(x).behaviorRes, DATAPATHs, "UniformOutput", false);

temp = cellfun(@(x) x([x.type] == "REG" & ismember([x.ICI], ICIsREG)), data, "UniformOutput", false);
resREG_A2 = cellfun(@(x) [x.nDiff] ./ [x.nTotal], temp, "UniformOutput", false);

temp = cellfun(@(x) x([x.type] == "IRREG" & ismember([x.ICI], ICIsIRREG)), data, "UniformOutput", false);
resIRREG_A2 = cellfun(@(x) [x.nDiff] ./ [x.nTotal], temp, "UniformOutput", false);

%% Filter
subjectIdxA1 = cellfun(@(x) x(1) < thL && x(end) > thH, resREG_A1);
subjectIdxA2 = cellfun(@(x) x(1) < thL && x(end) > thH, resREG_A2);
save("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1", "resREG_A1", "resIRREG_A1");
save("..\DATA\MAT DATA\figure\subjectIdx_A2.mat", "subjectIdxA2", "resREG_A2", "resIRREG_A2");

%% Plot
fitResMeanREG_A1 = fitBehavior(mean(cell2mat(resREG_A1(subjectIdxA1)), 1), ICIsREG);
fitResMeanREG_A2 = fitBehavior(mean(cell2mat(resREG_A2(subjectIdxA2)), 1), ICIsREG);

FigFit = figure;
maximizeFig;

% A1
mSubplot(2, 3, 1, 'shape', 'square-min', "margins", margins);
temp = resREG_A1(subjectIdxA1);
for index = 1:length(temp)
    plot(ICIsREG, temp{index}, 'Color', [255 192 203] / 255);
    hold on;
end
plot(fitResMeanREG_A1(1, :), fitResMeanREG_A1(2, :), 'Color', 'r', 'LineWidth', 2);
set(gca, "FontSize", 12);
xticks(ICIsREG);
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title(['A1 REG | N=', num2str(sum(subjectIdxA1))]);

mSubplot(2, 3, 2, 'shape', 'square-min', "margins", margins);
temp = resIRREG_A1(subjectIdxA1);
for index = 1:length(temp)
    plot(temp{index}, 'Color', [135 206 235] / 255);
    hold on;
end
errorbar(1:length(ICIsIRREG), mean(cell2mat(temp), 1), SE(cell2mat(temp), 1), 'Color', 'b', 'LineWidth', 2);
set(gca, "FontSize", 12);
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG'));
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title('A1 IRREG');

mSubplot(2, 3, 3, 'shape', 'square-min', "margins", margins);
temp = resPT_A1(subjectIdxA1);
for index = 1:length(temp)
    plot(temp{index}, 'Color', [189 252 201] / 255);
    hold on;
end
errorbar(1:length(freqs), mean(cell2mat(temp), 1), SE(cell2mat(temp), 1), 'Color', 'g', 'LineWidth', 2);
set(gca, "FontSize", 12);
xticks(1:length(freqs));
xticklabels(num2str(freqs'));
xlabel('S2 Frequency (Hz)');
ylabel('Press for difference ratio');
title('A1 Tone');

% A2
mSubplot(2, 3, 4, 'shape', 'square-min', "margins", margins);
temp = resREG_A2(subjectIdxA2);
for index = 1:length(temp)
    plot(ICIsREG, temp{index}, 'Color', [255 192 203] / 255);
    hold on;
end
set(gca, "FontSize", 12);
plot(fitResMeanREG_A2(1, :), fitResMeanREG_A2(2, :), 'Color', 'r', 'LineWidth', 2);
xticks(ICIsREG);
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title(['A2 REG | N=', num2str(sum(subjectIdxA2))]);

mSubplot(2, 3, 5, 'shape', 'square-min', "margins", margins);
temp = resIRREG_A2(subjectIdxA2);
for index = 1:length(temp)
    plot(temp{index}, 'Color', [135 206 235] / 255);
    hold on;
end
set(gca, "FontSize", 12);

% exclude ICI=8 missing
temp1 = cell2mat(cellfun(@(x) x(1:2), temp, "UniformOutput", false));
temp2 = cell2mat(cellfun(@(x) x(3), temp(cellfun(@length, temp) > 2), "UniformOutput", false));
errorbar(1:length(ICIsIRREG), [mean(temp1, 1), mean(temp2, 1)], [SE(temp1, 1), SE(temp2, 1)], 'Color', 'b', 'LineWidth', 2);
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG'));
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title('A2 IRREG');

print(FigFit, '..\Docs\Figures\Figure 8&11\Fit.png', "-dpng", "-r300");

%% Compare
subjectIdx = subjectIdxA1 & subjectIdxA2;

% REG
figure;
maximizeFig;
for index = 1:5
    mSubplot(2, 3, index, 'shape', 'square-min', "margins", margins);
    X = cellfun(@(x) x(index), resREG_A1(subjectIdx));
    Y = cellfun(@(x) x(index), resREG_A2(subjectIdx));
    [~, p] = ttest(X, Y);
    scatter(X, Y, 100, "k");
    set(gca, "FontSize", 12);
    hold on;
    plot([0, 1], [0, 1], 'k--', 'LineWidth', 1.5);
    xlabel('A1');
    ylabel('A2');
    title(['REG | ICI2 = ', num2str(ICIsREG(index)), ' ms | p=', num2str(p)]);
end

% IRREG
figure;
maximizeFig;
for index = 1:2
    mSubplot(1, 2, index, 'shape', 'square-min', "margins", margins);
    X = cellfun(@(x) x(index), resIRREG_A1(subjectIdx));
    Y = cellfun(@(x) x(index), resIRREG_A2(subjectIdx));
    [~, p] = ttest(X, Y);
    scatter(X, Y, 100, "k");
    set(gca, "FontSize", 12);
    hold on;
    plot([0, 1], [0, 1], 'k--', 'LineWidth', 1.5);
    xlabel('A1');
    ylabel('A2');
    title(['IRREG | ICI2 = ', num2str(ICIsIRREG(index)), ' ms | p=', num2str(p)]);
end

%% Find Behavior threshold
try
    load('..\DATA\MAT DATA\figure\behavior fitres.mat', "fitResREG_A1", "fitResREG_A2");
catch
    fitResREG_A1 = cellfun(@(x) fitBehavior(x, ICIsREG), resREG_A1(subjectIdx), "UniformOutput", false);
    fitResREG_A2 = cellfun(@(x) fitBehavior(x, ICIsREG), resREG_A2(subjectIdx), "UniformOutput", false);
    save('..\DATA\MAT DATA\figure\behavior fitres.mat', "fitResREG_A1", "fitResREG_A2");
end

thREG_A1 = cellfun(@(x) findBehaviorThreshold(x, thBeh), fitResREG_A1);
thREG_A2 = cellfun(@(x) findBehaviorThreshold(x, thBeh), fitResREG_A2);
idx = find(thREG_A1 > ICIsREG(1) & thREG_A1 < ICIsREG(end) & thREG_A2 > ICIsREG(1) & thREG_A2 < ICIsREG(end));

%% Plot Behavior threshold res
FigHist = figure;
maximizeFig;
mSubplot(2, 2, 1);
for index = 1:length(idx)
    plot(fitResREG_A1{idx(index)}(1, :), fitResREG_A1{idx(index)}(2, :), 'Color', 'r', 'LineWidth', 1.5);
    hold on;
    plot(fitResREG_A2{idx(index)}(1, :), fitResREG_A2{idx(index)}(2, :), 'Color', 'b', 'LineWidth', 1.5);
end
set(gca, "FontSize", 12);
ylim([0, 1]);
xticks(ICIsREG);
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');

mSubplot(2, 2, 3, "margin_top", 0.15);
meanThREG_A1 = mean(thREG_A1(idx));
meanThREG_A2 = mean(thREG_A2(idx));
mHistogram([thREG_A1(idx), thREG_A2(idx)]', ...
           "BinWidth", mode(diff(ICIsREG)) / 2, ...
           "Color", {[1 0 0], ...
                     [0 0 1]}, ...
           "DisplayName", {['Seamless transition (Mean at ', num2str(meanThREG_A1), ')'], ...
                           ['DMS delay = 600 ms (Mean at ', num2str(meanThREG_A2), ')']});
addLines2Axes(gca, struct("X", meanThREG_A1, "color", "r", "width", 1.5));
addLines2Axes(gca, struct("X", meanThREG_A2, "color", "b", "width", 1.5));
xlim([ICIsREG(1), ICIsREG(end)]);
set(gca, "FontSize", 12);
xlabel('Behavior threshold ICI (ms)');
ylabel('Subject count');
legend;
[~, p] = ttest(thREG_A1(idx), thREG_A2(idx));
title(['Pairwise t-test p=', num2str(p)])

mSubplot(1, 2, 2, "shape", "square-min", "margin_left", 0.15);
scatter(thREG_A1(idx), thREG_A2(idx), 100, "k");
set(gca, "FontSize", 12);
[R, p] = corr(thREG_A1(idx), thREG_A2(idx), "type", "Pearson");
hold on;
plot([ICIsREG(1), ICIsREG(end)], [ICIsREG(1), ICIsREG(end)], "k--", "LineWidth", 2);
xlabel('Behavior threshold ICI (Seamless transition)');
ylabel('Behavior threshold ICI (DMS delay = 600 ms)');
title(['Pearson Corr R=', num2str(R), ' | p=', num2str(p), ' | N=', num2str(length(idx))]);

print(FigHist, '..\Docs\Figures\Figure 8&11\Hist.png', "-dpng", "-r300");
