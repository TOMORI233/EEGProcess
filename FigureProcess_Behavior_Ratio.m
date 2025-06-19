ccc;

%% Path
ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
FIGUREPATH = getAbsPath("..\Figures\healthy\population\Bahavior-Ratio");

%% Params
margins = [0.05, 0.05, 0.1, 0.1];

ICIsREG = [4, 4.01, 4.02, 4.03, 4.06];
ICIsIRREG = [4, 4.06, 8];
freqs = [246.3054, 250];

thL = 0.3;
thH = 0.6;
thBeh = 0.6;

run(fullfile(pwd, "config\config_plot.m"));

%% Load - A1
DATAPATHs = dir(fullfile(ROOTPATH, '**\active1\behavior.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, '\active1\behavior.mat', '');
temp = split(SUBJECTs, '\');
SUBJECTs = rowFcn(@(x) x{end}, temp, "UniformOutput", false);

% Gender filter
% load("gender.mat", "genders", "subjectIDs");
% idx = cellfun(@(x) find(strcmp(SUBJECTs, x)), subjectIDs);
% genders = genders(idx);

data = cellfun(@(x) load(x).behaviorRes, DATAPATHs, "UniformOutput", false);
% data = data(genders == 1); % male
% data = data(genders == 2); % female

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
% data = data(genders == 1); % male
% data = data(genders == 2); % female

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
FigFit = figure;

% A1
mSubplot(2, 3, 1, 'shape', 'square-min', "margins", margins);
temp = resREG_A1(subjectIdxA1);
for index = 1:length(temp)
    plot(ICIsREG, temp{index}, 'Color', [255 192 203] / 255);
    hold on;
end
temp = changeCellRowNum(cellfun(@(x) x', temp, "UniformOutput", false));
errorbar(ICIsREG, cellfun(@mean, temp), cellfun(@SE, temp), 'Color', 'r', 'LineWidth', 2);
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
errorbar(1:length(ICIsIRREG), mean(cell2mat(temp), 1)', SE(cell2mat(temp), 1)', 'Color', 'b', 'LineWidth', 2);
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
errorbar(1:length(freqs), mean(cell2mat(temp), 1)', SE(cell2mat(temp), 1)', 'Color', 'g', 'LineWidth', 2);
set(gca, "FontSize", 12);
xticks(1:length(freqs));
xticklabels(num2str(freqs'));
xlabel('S2 Frequency (Hz)');
ylabel('Press for difference ratio');
title('A1 Tone');

% A2
mSubplot(2, 3, 4, 'shape', 'square-min', "margins", margins);
temp = resREG_A2(subjectIdxA1 & subjectIdxA2);
for index = 1:length(temp)
    plot(ICIsREG, temp{index}, 'Color', [255 192 203] / 255);
    hold on;
end
set(gca, "FontSize", 12);
temp = changeCellRowNum(cellfun(@(x) x', temp, "UniformOutput", false));
errorbar(ICIsREG, cellfun(@mean, temp), cellfun(@SE, temp), 'Color', 'r', 'LineWidth', 2);
xticks(ICIsREG);
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title(['A2 REG | N=', num2str(sum(subjectIdxA1 & subjectIdxA2))]);

mSubplot(2, 3, 5, 'shape', 'square-min', "margins", margins);
temp = resIRREG_A2(subjectIdxA1 & subjectIdxA2);
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

mPrint(FigFit, fullfile(FIGUREPATH, 'Fit.png'), "-dpng", "-r300");

%% Compare
subjectIdx = subjectIdxA1 & subjectIdxA2;

% REG
figure;
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
    fitResREG_A1 = cellfun(@(x) fitBehavior(x, ICIsREG), resREG_A1, "UniformOutput", false);
    fitResREG_A2 = cellfun(@(x) fitBehavior(x, ICIsREG), resREG_A2, "UniformOutput", false);
    save('..\DATA\MAT DATA\figure\behavior fitres.mat', "fitResREG_A1", "fitResREG_A2");
end

% fitResREG_A1 = fitResREG_A1(genders == 1); % male
% fitResREG_A2 = fitResREG_A2(genders == 1); % male
% fitResREG_A1 = fitResREG_A1(genders == 2); % female
% fitResREG_A2 = fitResREG_A2(genders == 2); % female

thREG_A1 = cellfun(@(x) findBehaviorThreshold(x, thBeh), fitResREG_A1);
thREG_A2 = cellfun(@(x) findBehaviorThreshold(x, thBeh), fitResREG_A2);

% Th Filter
idx = thREG_A1 > ICIsREG(1) & thREG_A1 < ICIsREG(end) & thREG_A2 > ICIsREG(1) & thREG_A2 < ICIsREG(end);
idxA1 = find(subjectIdxA1 & idx);
idxA2 = find(subjectIdxA2 & idx);
idxBoth = find(subjectIdxA1 & subjectIdxA2 & idx);

%% Plot Behavior threshold res
FigHist = figure;
mSubplot(2, 2, 1);
hold(gca, "on");
for index = 1:length(idxA1)
    plot(fitResREG_A1{idxA1(index)}(1, :), fitResREG_A1{idxA1(index)}(2, :), 'Color', 'r', 'LineWidth', 1.5);
end
for index = 1:length(idxA2)
    plot(fitResREG_A2{idxA2(index)}(1, :), fitResREG_A2{idxA2(index)}(2, :), 'Color', 'b', 'LineWidth', 1.5);
end
set(gca, "FontSize", 12);
ylim([0, 1]);
xticks(ICIsREG);
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');

mSubplot(2, 2, 3, "margin_top", 0.15);
meanThREG_A1 = mean(thREG_A1(idxBoth));
meanThREG_A2 = mean(thREG_A2(idxBoth));
mHistogram([thREG_A1(idxBoth), thREG_A2(idxBoth)]', ...
           "BinWidth", mode(diff(ICIsREG)) / 2, ...
           "FaceColor", {[1 0 0], ...
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
[~, p] = ttest(thREG_A1(idxBoth), thREG_A2(idxBoth));
title(['Pairwise t-test p=', num2str(p)]);

mSubplot(1, 2, 2, "shape", "square-min", "margin_left", 0.15);
scatter(thREG_A1(idxBoth), thREG_A2(idxBoth), 100, "k");
set(gca, "FontSize", 12);
[R, p] = corr(thREG_A1(idxBoth), thREG_A2(idxBoth), "type", "Pearson");
hold on;
plot([ICIsREG(1), ICIsREG(end)], [ICIsREG(1), ICIsREG(end)], "k--", "LineWidth", 2);
xlabel('Behavior threshold ICI (Seamless transition)');
ylabel('Behavior threshold ICI (DMS delay = 600 ms)');
title(['Pearson Corr R=', num2str(R), ' | p=', num2str(p), ' | N=', num2str(length(idxBoth))]);

mPrint(FigFit, fullfile(FIGUREPATH, 'Hist.png'), "-dpng", "-r300");

%%
[N, EDGES] = histcounts(thREG_A1(idxA1), 4:0.01/4:4.06);
N = N';
EDGES = EDGES(1:end - 1)' + mode(diff(EDGES)) / 2;
thMedian = median(thREG_A1(idxA1));

[N_A1, EDGES_A1] = histcounts(thREG_A1(idxBoth), 4:0.01/2:4.06);
N_A1 = N_A1';
EDGES_A1 = EDGES_A1(1:end - 1)' + mode(diff(EDGES_A1)) / 2;
thMedianA1 = median(thREG_A1(idxBoth));

[N_A2, EDGES_A2] = histcounts(thREG_A2(idxBoth), 4:0.01/2:4.06);
N_A2 = N_A2';
EDGES_A2 = EDGES_A2(1:end - 1)' + mode(diff(EDGES_A2)) / 2;
thMedianA2 = median(thREG_A2(idxBoth));

%% Figure result
temp = arrayfun(@(x) cellfun(@(y) y(x), resREG_A1(subjectIdxA1)), [1:5]', "UniformOutput", false);
res_mean_REG_A1 = cellfun(@mean, temp);
res_se_REG_A1 = cellfun(@SE, temp);

temp = arrayfun(@(x) cellfun(@(y) y(x), resIRREG_A1(subjectIdxA1)), [1:3]', "UniformOutput", false);
res_mean_IRREG_A1 = cellfun(@mean, temp);
res_se_IRREG_A1 = cellfun(@SE, temp);

temp = arrayfun(@(x) cellfun(@(y) y(x), resPT_A1(subjectIdxA1)), [1:2]', "UniformOutput", false);
res_mean_PT_A1 = flip(cellfun(@mean, temp)); % 250, 246
res_se_PT_A1 = flip(cellfun(@SE, temp));

temp = arrayfun(@(x) cellfun(@(y) y(x), resREG_A2(subjectIdxA2)), [1:5]', "UniformOutput", false);
res_mean_REG_A2 = cellfun(@mean, temp);
res_se_REG_A2 = cellfun(@SE, temp);

res_alone_th_hist_edge_A1 = EDGES;
res_alone_th_hist_N_A1 = N;
res_compare_th_hist_edge = EDGES_A1;
res_compare_th_hist_N_A1 = N_A1;
res_compare_th_hist_N_A2 = N_A2;

temp = arrayfun(@(x) cellfun(@(y) y(x), resREG_A1(subjectIdxA1 & subjectIdxA2)), [1:5]', "UniformOutput", false);
res_compare_mean_REG_A1 = cellfun(@mean, temp);
res_compare_se_REG_A1 = cellfun(@SE, temp);
temp = arrayfun(@(x) cellfun(@(y) y(x), resREG_A2(subjectIdxA1 & subjectIdxA2)), [1:5]', "UniformOutput", false);
res_compare_mean_REG_A2 = cellfun(@mean, temp);
res_compare_se_REG_A2 = cellfun(@SE, temp);

res_compare_th_scatterX_nogapped = thREG_A1(idxBoth);
res_compare_th_scatterY_gapped = thREG_A2(idxBoth);

res_scatterX_PT = cellfun(@(x) x(1), resPT_A1(subjectIdxA1));
res_scatterX_IRREG = cellfun(@(x) x(1), resIRREG_A1(subjectIdxA1));
res_scatterY_REG = cellfun(@(x) x(end), resREG_A1(subjectIdxA1));

%% 
[res_p_IRREG_vs_control, stats_IRREG_vs_control, efsz_IRREG_vs_control, bf10_IRREG_vs_control] = mstat.ttest(res_scatterX_IRREG, cellfun(@(x) x(2), resIRREG_A1(subjectIdxA1)));

[res_p_PT_vs_control, stats_PT_vs_control, efsz_PT_vs_control] = mstat.ttest(cellfun(@(x) x(1), resPT_A1(subjectIdxA1)), ...
                                                                             cellfun(@(x) x(2), resPT_A1(subjectIdxA1)));

[res_p_REG_vs_PT, stats_REG_vs_PT, efsz_REG_vs_PT, ~] = mstat.ttest(res_scatterX_PT, res_scatterY_REG);

[res_p_REG_vs_IRREG, stats_REG_vs_IRREG, efsz_REG_vs_IRREG, ~] = mstat.ttest(res_scatterX_IRREG, res_scatterY_REG);

[res_p_th_A1_vs_A2, stats_th_A1_vs_A2, efsz_th_A1_vs_A2, ~] = mstat.ttest(thREG_A1(idxBoth), thREG_A2(idxBoth));

cat(1, resREG_A1{subjectIdxA1});
cat(1, resIRREG_A1{subjectIdxA1});
cat(1, resPT_A1{subjectIdxA1});

cat(1, resREG_A1{subjectIdxA1 & subjectIdxA2});
cat(1, resREG_A2{subjectIdxA1 & subjectIdxA2});