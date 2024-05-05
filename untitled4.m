ccc;

dataMale = load("male Behavior.mat");
dataFemale = load("female Behavior.mat");

% close all;

%% 
ICIsREG = dataMale.ICIsREG;

%% 
figure;
mSubplot(1, 1, 1);
meanThREG_A1_Male = mean(dataMale.thREG_A1(dataMale.idxA1));
meanThREG_A1_Female = mean(dataFemale.thREG_A1(dataFemale.idxA1));
[~, p] = ttest2(dataMale.thREG_A1(dataMale.idxA1), dataFemale.thREG_A1(dataFemale.idxA1));
mHistogram([{dataMale.thREG_A1(dataMale.idxA1)}, {dataFemale.thREG_A1(dataFemale.idxA1)}], ...
           "BinWidth", mode(diff(ICIsREG)) / 2, ...
           "Color", {[1 0 0], ...
                     [0 0 1]}, ...
           "DisplayName", {['Male (Mean at ', num2str(meanThREG_A1_Male), ', N=', num2str(length(dataMale.idxA1)), ')'], ...
                           ['Female (Mean at ', num2str(meanThREG_A1_Female), ', N=', num2str(length(dataFemale.idxA1)), ')']});
addLines2Axes(gca, struct("X", meanThREG_A1_Male, "color", "r", "width", 1.5));
addLines2Axes(gca, struct("X", meanThREG_A1_Female, "color", "b", "width", 1.5));
xlim([ICIsREG(1), ICIsREG(end)]);
set(gca, "FontSize", 12);
xlabel('Behavior threshold ICI (ms)');
ylabel('Subject count');
legend;
title(['Behavior threshold in seamless transition task | Two-sample t-test p = ', num2str(p)]);

