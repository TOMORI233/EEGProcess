ccc;

%% Paths
MATPATHs = dir("..\DATA\MAT DATA\temp\**\passive3\chMeanIRREG_before_after.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

%% Load
data = cellfun(@load, MATPATHs);

window = data(1).window;
fs = data(1).fs;

%% 
temp = arrayfun(@(x) x.chData(1).chMean, data, "UniformOutput", false);
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
chData(1).chMean = calchMean(temp);
chData(1).chErr = calchErr(temp);
chData(1).color = "k";
chData(1).legend = 'Before 100';

temp = arrayfun(@(x) x.chData(2).chMean, data, "UniformOutput", false);
temp = cellfun(@(x) x ./ std(x, [], 2), temp, "UniformOutput", false);
chData(2).chMean = calchMean(temp);
chData(2).chErr = calchErr(temp);
chData(2).color = "r";
chData(2).legend = 'After 100';

plotRawWaveMulti(chData, window);