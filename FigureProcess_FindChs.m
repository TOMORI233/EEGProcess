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

% Export chs
chsAvg = find(temp > 0.6);
chsAvg(ismember(chsAvg, [33, 43])) = [];
save("chsAvg.mat", "chsAvg");

figure;
maximizeFig;
topoplot(temp, 'Neuroscan_chan64.loc');
cb = colorbar;
cb.Label.String = 'Significant ratio';
cb.Label.FontSize = 18;
cb.Label.FontWeight = "bold";
cb.Label.Rotation = -90;
scaleAxes("c", [0, 1]);

%% Onset - Base diff
figure;
maximizeFig;
avgDiff = cellfun(@(x, y) x - y, avgOnset, avgBase, "UniformOutput", false);
temp = cellfun(@mean, avgDiff);
topoplot(temp, 'Neuroscan_chan64.loc');
cb = colorbar;
cb.Label.String = 'Difference between onset and baseline (\muV)';
cb.Label.FontSize = 18;
cb.Label.FontName = "Arial";
cb.Label.FontWeight = "bold";
cb.Label.Rotation = -90;
