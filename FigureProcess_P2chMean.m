%% 离散度
clear; clc; close all force;

load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_P2_Population.mat");

window = [-500, 2000];
colors = flip(cellfun(@(x) x / 255, {[0 0 0], [0 0 255], [255 0 0]}, "UniformOutput", false));

temp = vertcat(data.chMeanData);
vars = unique([temp.variance])';

for index = 1:length(vars)
    idx = [temp.variance] == vars(index);
    chMeanVar(index, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
    chMeanVar(index, 1).variance = vars(index);
    chMeanVar(index, 1).color = colors{index};
end

FigVar = plotRawWaveMultiEEG(chMeanVar, window, 1000, "REG");
scaleAxes(FigVar, "x", [1000, 1500]);
scaleAxes(FigVar, "y", "on", "symOpt", "max", "uiOpt", "show");