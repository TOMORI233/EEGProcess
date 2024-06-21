clear; clc;

load("..\DATA\MAT DATA - coma\pre\2024040801\151\data.mat");
% load("..\DATA\MAT DATA - coma\pre\2024041102\151\data.mat");
% load("..\DATA\MAT DATA - extra\pre\subject002\113\data.mat");
nperm = 1e3;
alphaVal = 0.01;

%% 
trialsEEG1 = trialsEEG([trialAll.ICI2] == 4);
trialsEEG2 = trialsEEG([trialAll.ICI2] == 5);
chs2Ignore = 60:64;
gfp1 = calGFP(calchMean(trialsEEG1), chs2Ignore);
gfp2 = calGFP(calchMean(trialsEEG2), chs2Ignore);

p = wavePermTest(trialsEEG1, trialsEEG2, nperm, "Tail", "right", "Type", "GFP", "chs2Ignore", chs2Ignore);

%% 
chData(1).chMean = calchMean(trialsEEG1);
chData(1).color = [.5, .5, .5];
chData(2).chMean = calchMean(trialsEEG2);
chData(2).color = [.5, 0, .5];

temp = chData(1);
temp.color = [0, 0, 0];
plotRawWaveMultiEEG(temp, window, [], EEGPos_Neuracle64);
scaleAxes("x", [-300, 2000]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}, "width", 2, "color", [1, .5, 0]));

temp = chData(2);
temp.color = [0, 0, 0];
plotRawWaveMultiEEG(temp, window, [], EEGPos_Neuracle64);
scaleAxes("x", [-300, 2000]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}, "width", 2, "color", [1, .5, 0]));
allAxes = findobj(gcf, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).XAxis.Visible = "off";
    allAxes(aIndex).YAxis.Visible = "off";
end
mPrint(gcf, "..\temp\example_2024040801_REG4-5.jpg", "-dpng", "-r300");

%% 
h = fdr_bh(p, alphaVal, 'pdep');
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
