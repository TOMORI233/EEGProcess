ccc;

MATPATHs = dir("..\DATA\MAT DATA - coma\temp\**\151\chMean.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

%% Params
colors = {'k', [.5, .5, .5], 'b', 'r'};
run(fullfile(pwd, "config\avgConfig_Neuracle64.m"));

%%
data = []