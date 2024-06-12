clear; clc;

% load("..\DATA\MAT DATA - coma\pre\2024040801\151\data.mat");
load("..\DATA\MAT DATA - coma\pre\2024041102\151\data.mat");
% load("..\DATA\MAT DATA - extra\pre\subject002\113\data.mat");
nperm = 1e3;
alphaVal = 0.01;

%% 
trialsEEG1 = trialsEEG([trialAll.ICI2] == 4);
trialsEEG2 = trialsEEG([trialAll.ICI2] == 5);
gfp1 = calGFP(calchMean(trialsEEG1));
gfp2 = calGFP(calchMean(trialsEEG2));

p = gfpPermTest(trialsEEG1, trialsEEG2, nperm, "Tail", "right");

%% 
h = fdr_bh(p, alphaVal, 'dep');
h = double(h);
h(h == 0) = nan;
h(h == 1) = 0;
t = linspace(window(1), window(2), size(trialsEEG{1}, 2));

figure;
plot(t, gfp1, "Color", "k", "LineWidth", 2);
hold on;
plot(t, gfp2, "Color", "r", "LineWidth", 2);
scatter(t, h, 50, "yellow", "filled");
addLines2Axes(gca, struct("X", {0; 1000; 2000}));
