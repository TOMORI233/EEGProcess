clear; clc; close all force;

load("chsAvg.mat", "chsAvg");
load("windows.mat", "windows");
fs = 1e3; % Hz

winWidth = [-35, 35]; % ms

%% For A1, P2, P3
load("..\MAT Population\chMean_P3_Population.mat");
window = windows([windows.protocol] == "passive3").window;

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
title('REG ICI 4 - 4.06 (No interval)');
PKS = PKS(LOCS > 1000 & LOCS < 1300);
LOCS = LOCS(LOCS > 1000 & LOCS < 1300);
peakTime = LOCS(obtainArgoutN(@max, 2, PKS)); % ms
windowBRI = winWidth + peakTime; % ms
res(1, :) = windowBRI;
save("windowBRI4.mat", "windowBRI");

%% For A2
load("..\MAT Population\chMean_A2_Population.mat");
window = windows([windows.protocol] == "active2").window;

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
xlim([-500, 2600]);
title('REG ICI 4 - 4.06 (Interval=600 ms)');
PKS = PKS(LOCS > 1600 & LOCS < 1900);
LOCS = LOCS(LOCS > 1600 & LOCS < 1900);
peakTime = LOCS(obtainArgoutN(@max, 2, PKS)); % ms
windowBRI = winWidth + peakTime; % ms
save("windowBRI4_A2.mat", "windowBRI");

%% For P1
load("..\MAT Population\chMean_P1_Population.mat");
window = windows([windows.protocol] == "passive1").window;

temp = vertcat(data.chMeanData);

% Base ICI = 8
chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp([temp.ICI] == 8.12 & [temp.type] == "REG").chMean}'), "UniformOutput", false));
chMean = mean(chMean(chsAvg, :), 1);
t = linspace(window(1), window(2), length(chMean));
[PKS, LOCS] = findpeaks(chMean, t);
figure;
maximizeFig;
plot(t, chMean, 'b', 'LineWidth', 2);
hold on;
scatter(LOCS, PKS, 60, 'red', 'filled');
title('REG ICI 8 - 8.12');
PKS = PKS(LOCS > 1000 & LOCS < 1300);
LOCS = LOCS(LOCS > 1000 & LOCS < 1300);
peakTime = LOCS(obtainArgoutN(@max, 2, PKS)); % ms
windowBRI = winWidth + peakTime; % ms
res(2, :) = windowBRI;
save("windowBRI8.mat", "windowBRI");

% Base ICI = 16
chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp([temp.ICI] == 16.24 & [temp.type] == "REG").chMean}'), "UniformOutput", false));
chMean = mean(chMean(chsAvg, :), 1);
t = linspace(window(1), window(2), length(chMean));
[PKS, LOCS] = findpeaks(chMean, t);
figure;
maximizeFig;
plot(t, chMean, 'b', 'LineWidth', 2);
hold on;
scatter(LOCS, PKS, 60, 'red', 'filled');
title('REG ICI 16 - 16.24');
PKS = PKS(LOCS > 1000 & LOCS < 1300);
LOCS = LOCS(LOCS > 1000 & LOCS < 1300);
peakTime = LOCS(obtainArgoutN(@max, 2, PKS)); % ms
windowBRI = winWidth + peakTime; % ms
res(3, :) = windowBRI;
save("windowBRI16.mat", "windowBRI");

% Base ICI = 32
chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp([temp.ICI] == 32.48 & [temp.type] == "REG").chMean}'), "UniformOutput", false));
chMean = mean(chMean(chsAvg, :), 1);
t = linspace(window(1), window(2), length(chMean));
[PKS, LOCS] = findpeaks(chMean, t);
figure;
maximizeFig;
plot(t, chMean, 'b', 'LineWidth', 2);
hold on;
scatter(LOCS, PKS, 60, 'red', 'filled');
title('REG ICI 32 - 32.48');
windowBRI = [min(res(:, 1)), max(res(:, 2))]; % ms
res(4, :) = windowBRI;
save("windowBRI32.mat", "windowBRI");