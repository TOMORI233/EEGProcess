clear; clc; close all force;

load("D:\Education\Lab\Projects\EEG\MAT Population\FindChs_Population.mat");

temp = cellfun(@changeCellRowNum, {data.avgBase}', "UniformOutput", false);
avgBase = changeCellRowNum(vertcat(temp{:}));

temp = cellfun(@changeCellRowNum, {data.avgOnset}', "UniformOutput", false);
avgOnset = changeCellRowNum(vertcat(temp{:}));

%% FDR correction
alpha = 0.05;
temp = {data.p}';
temp = cellfun(@(x) mafdr(x, 'BHFDR', true), temp, "UniformOutput", false);
temp = cellfun(@(x) sum(x < alpha) / length(data), changeCellRowNum(temp));
chs = find(temp > 0.6)
figure;
maximizeFig;
mSubplot(1, 1, 1, "shape", "square-min");
topoplot(temp, 'chan64.loc');
colorbar;
scaleAxes("c", [0, 1]);

%% Onset - Base diff
figure;
maximizeFig;
avgDiff = cellfun(@(x, y) x - y, avgOnset, avgBase, "UniformOutput", false);
temp = cellfun(@mean, avgDiff);
topoplot(temp, 'chan64.loc');
colorbar;
scaleAxes("c", "cutoffRange", [-100, 100], "symOpt", "max", "uiOpt", "show");