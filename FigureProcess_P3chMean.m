%% 精度
clear; clc; close all force;

load("D:\Education\Lab\Projects\EEG\MAT Population\chMean_P3_Population.mat");

window = [-500, 2000];
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

temp = vertcat(data.chMeanData);
ICIs = unique([temp.ICI])';
ICIs(ICIs == 0) = [];

nREG = 0;
nIRREG = 0;

for index = 1:length(ICIs)
    idx = [temp.ICI] == ICIs(index) & [temp.type] == "REG";
    if any(idx)
        nREG = nREG + 1;
        chMeanREG(nREG, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
        chMeanREG(nREG, 1).ICI = ICIs(index);
        chMeanREG(nREG, 1).type = "REG";
        chMeanREG(nREG, 1).color = colors{index};
    end

    idx = [temp.ICI] == ICIs(index) & [temp.type] == "IRREG";
    if any(idx)
        nIRREG = nIRREG + 1;
        chMeanIRREG(nIRREG, 1).chMean = cell2mat(cellfun(@(x) mean(x, 1), changeCellRowNum({temp(idx).chMean}'), "UniformOutput", false));
        chMeanIRREG(nIRREG, 1).ICI = ICIs(index);
        chMeanIRREG(nIRREG, 1).type = "IRREG";
        chMeanIRREG(nIRREG, 1).color = colors{index};
    end
end

FigREG = plotRawWaveMultiEEG(chMeanREG, window, 1000, "REG");
scaleAxes(FigREG, "x", [1000, 1500]);
scaleAxes(FigREG, "y", "on", "symOpt", "max", "uiOpt", "show");

FigIRREG = plotRawWaveMultiEEG(chMeanIRREG, window, 1000, "IRREG");
scaleAxes(FigIRREG, "x", [0, 2000]);
scaleAxes(FigIRREG, "y", "on", "symOpt", "max", "uiOpt", "show");