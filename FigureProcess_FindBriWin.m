clear; clc; close all force;

load("chsAvg.mat");
fs = 1e3; % Hz

%% For no interval protocols
load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_P3_Population.mat");
window = [-500, 2000]; % ms

temp = vertcat(data.chMeanData);
chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp([temp.ICI] == 4.06 & [temp.type] == "REG").chMean}'), "UniformOutput", false));
chMean = mean(chMean(chsAvg, :), 1);
t = linspace(window(1), window(2), length(chMean));
[PKS, LOCS] = findpeaks(chMean, t);

figure;
maximizeFig;
plot(t, chMean, 'b', 'LineWidth', 2);
hold on;
scatter(LOCS, PKS, 60, 'red', 'filled');

PKS = PKS(LOCS > 1000);
LOCS = LOCS(LOCS > 1000);
peakTime = LOCS(obtainArgoutN(@max, 2, PKS)); % ms
windowBRI = [-35, 35] + peakTime; % ms

save("windowBRI.mat", "windowBRI");

%% For A2 with interval
load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_A2_Population.mat");
window = [-500, 2600]; % ms

temp = vertcat(data.chMeanData);
chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp([temp.ICI] == 4.06 & [temp.type] == "REG").chMean}'), "UniformOutput", false));
chMean = mean(chMean(chsAvg, :), 1);
t = linspace(window(1), window(2), length(chMean));
[PKS, LOCS] = findpeaks(chMean, t);

figure;
maximizeFig;
plot(t, chMean, 'b', 'LineWidth', 2);
hold on;
scatter(LOCS, PKS, 60, 'red', 'filled');

PKS = PKS(LOCS > 1600);
LOCS = LOCS(LOCS > 1600);
peakTime = LOCS(obtainArgoutN(@max, 2, PKS)); % ms
windowBRI = [-35, 35] + peakTime; % ms

save("windowBRI_A2.mat", "windowBRI");