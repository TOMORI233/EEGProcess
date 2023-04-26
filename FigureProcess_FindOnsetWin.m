clear; clc; close all force;

fs = 1e3; % Hz

chMeanDataP3 = load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_P3_Population.mat").data;
load("windows.mat", "windows");
windowP3 = windows([windows.protocol] == "passive3").window;

temp = vertcat(chMeanDataP3.chMeanData);
chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp([temp.type] == "REG").chMean}'), "UniformOutput", false));
t = linspace(windowP3(1), windowP3(2), length(chMean));
[PKS, LOCS] = rowFcn(@(x) findpeaks(x, t), chMean, "UniformOutput", false);

figure;
maximizeFig;
for cIndex = 1:length(PKS)
    mSubplot(8, 8, cIndex);
    plot(t, chMean(cIndex, :), 'b', 'LineWidth', 2);
    hold on;
    scatter(LOCS{cIndex}, PKS{cIndex}, 30, 'red', 'filled');
end
scaleAxes("x", [0, 500]);
scaleAxes("y", "on", "symOpt", "max");
PKS = cellfun(@(x, y) x(y < 1000), PKS, LOCS, "UniformOutput", false);
LOCS = cellfun(@(x) x(x < 1000), LOCS, "UniformOutput", false);
peakTime = cellfun(@(x, y) y(obtainArgoutN(@max, 2, x)), PKS, LOCS); % ms
windowOnset = [-25, 25] + mode(peakTime); % ms

save("windowOnset.mat", "windowOnset");
