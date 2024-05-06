ccc;

MATPATHsComa = dir("..\DATA\MAT DATA - coma\temp\**\151\chMean.mat");
MATPATHsComa = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHsComa, "UniformOutput", false);

MATPATHsHealthy = dir("..\DATA\MAT DATA - extra\temp\**\113\chMean.mat");
MATPATHsHealthy = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHsHealthy, "UniformOutput", false);

%% Params
colors = {'k', 'b', 'r'};
run(fullfile(pwd, "config\avgConfig_Neuracle64.m"));

%%
window = load(MATPATHsComa{1}).window;
dataComa = cellfun(@(x) load(x).chData, MATPATHsComa, "UniformOutput", false);
dataHealthy = cellfun(@(x) load(x).chData, MATPATHsHealthy, "UniformOutput", false);

%% 
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataComa, "UniformOutput", false);
temp1 = cat(3, temp{:});
std(temp1, [], 3)
chDataComaAll(1).chMean = calchMean(temp);
chDataComaAll(1).chErr  = calchErr(temp);
chDataComaAll(1).color  = colors{1};
chDataComaAll(1).legend = "REG 4-4";

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataComa, "UniformOutput", false);
chDataComaAll(2).chMean = calchMean(temp);
chDataComaAll(2).chErr  = calchErr(temp);
chDataComaAll(2).color  = colors{2};
chDataComaAll(2).legend = "REG 4-5";

temp = cellfun(@(x) x([x.freq] == 200).chMean, dataComa, "UniformOutput", false);
chDataComaAll(3).chMean = calchMean(temp);
chDataComaAll(3).chErr  = calchErr(temp);
chDataComaAll(3).color  = colors{3};
chDataComaAll(3).legend = "PT 250-200";

plotRawWaveMultiEEG(chDataComaAll, window, [], EEGPos_Neuracle64);

%% 
temp = cellfun(@(x) x([x.ICI] == 4).chMean, dataHealthy, "UniformOutput", false);
chDataHealthyAll(1).chMean = calchMean(temp);
chDataHealthyAll(1).chErr  = calchErr(temp);
chDataHealthyAll(1).color  = colors{1};
chDataHealthyAll(1).legend = "REG 4-4";

temp = cellfun(@(x) x([x.ICI] == 5).chMean, dataHealthy, "UniformOutput", false);
chDataHealthyAll(2).chMean = calchMean(temp);
chDataHealthyAll(2).chErr  = calchErr(temp);
chDataHealthyAll(2).color  = colors{2};
chDataHealthyAll(2).legend = "REG 4-5";

temp = cellfun(@(x) x([x.freq] == 200).chMean, dataHealthy, "UniformOutput", false);
chDataHealthyAll(3).chMean = calchMean(temp);
chDataHealthyAll(3).chErr  = calchErr(temp);
chDataHealthyAll(3).color  = colors{3};
chDataHealthyAll(3).legend = "PT 250-200";