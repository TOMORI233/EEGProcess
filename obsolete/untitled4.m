ccc;

MATPATHs = dir("..\DATA\MAT DATA - extra\temp\**\113\chMean.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

%% Params
interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuracle64.m"));

windowOnset = [0, 250];
windowBase0 = [-500, -300];
windowBase = [800, 1000];
load("windowChange.mat", "windowChange");

nperm = 1e3;
alphaVal = 0.05;

colors = {changeSaturation("r", 0.5), "r", changeSaturation("b", 0.5), "b"};

%% 
data = cellfun(@(x) load(x).chData, MATPATHs, "UniformOutput", false);
fs = load(MATPATHs{1}).fs;
window = load(MATPATHs{1}).window;

data = cellfun(@(x) {x.chMean}', data, "UniformOutput", false);
data = changeCellRowNum(data);

% normalize
data = cellfun(@(x) cellfun(@(y) y ./ std(y, [], 2), x, "UniformOutput", false), data, "UniformOutput", false);

%% 
legendStrs = ["REG4-4", "REG4-5", "PT250-250", "PT250-200"];
for index = 1:length(data)
    chDataAll(index, 1).chMean = calchMean(data{index});
    chDataAll(index, 1).chErr = calchErr(data{index});
    chDataAll(index, 1).legend = legendStrs(index);
    chDataAll(index, 1).color = colors{index};
end

exampleChannel = "POZ";
chIdx = find(upper(EEGPos.channelNames) == exampleChannel);

chData = chDataAll;
chData = addfield(chData, "chMean", arrayfun(@(x) x.chMean(chIdx, :), chDataAll, "UniformOutput", false));
chData = addfield(chData, "chErr", arrayfun(@(x) x.chErr(chIdx, :), chDataAll, "UniformOutput", false));
plotRawWaveMulti(chData, window);
addLines2Axes(struct("X", {0; 1000; 2000}));

%% Statistics
statFcn = @(x, y) rowFcn(@signrank, x, y);

% onset
dataOnsetREG = cat(1, data{1:2});
dataOnsetPT  = cat(1, data{3:4});

% REG
RM_base0REG = calRM(dataOnsetREG, window, windowBase0, @(x) rmfcn(x, 2));
RM_onsetREG = calRM(dataOnsetREG, window, windowOnset, @(x) rmfcn(x, 2));
RM_base0REG = cat(2, RM_base0REG{:});
RM_onsetREG = cat(2, RM_onsetREG{:});
p = statFcn(RM_base0REG, RM_onsetREG);
plotScatterEEG(RM_base0REG, RM_onsetREG, EEGPos, statFcn, false);
params = topoplotConfig(EEGPos, find(p < alphaVal), 4, 13);
mSubplot(3, 4, 4, "shape", "square-min");
topoplot(mean(RM_onsetREG - RM_base0REG, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";

% PT
RM_base0PT = calRM(dataOnsetPT, window, windowBase0, @(x) rmfcn(x, 2));
RM_onsetPT = calRM(dataOnsetPT, window, windowOnset, @(x) rmfcn(x, 2));
RM_base0PT = cat(2, RM_base0PT{:});
RM_onsetPT = cat(2, RM_onsetPT{:});
p = statFcn(RM_base0PT, RM_onsetPT);
plotScatterEEG(RM_base0PT, RM_onsetPT, EEGPos, statFcn, false);
params = topoplotConfig(EEGPos, find(p < alphaVal), 4, 13);
mSubplot(3, 4, 4, "shape", "square-min");
topoplot(mean(RM_onsetPT - RM_base0PT, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";

% change
RM_base   = cellfun(@(x) calRM(x, window, windowBase, @(x) rmfcn(x, 2)), data, "UniformOutput", false);
RM_change = cellfun(@(x) calRM(x, window, windowChange, @(x) rmfcn(x, 2)), data, "UniformOutput", false);
RM_base   = cellfun(@(x) cat(2, x{:}), RM_base  , "UniformOutput", false);
RM_change = cellfun(@(x) cat(2, x{:}), RM_change, "UniformOutput", false);

RM_delta_change = cellfun(@(x, y) x - y, RM_change, RM_base, "UniformOutput", false);

% REG
p1 = statFcn(RM_delta_change{1}, RM_delta_change{2});
plotScatterEEG(RM_delta_change{1}, RM_delta_change{2}, EEGPos, statFcn, false);
params = topoplotConfig(EEGPos, find(p1 < alphaVal), 4, 13);
mSubplot(3, 4, 4, "shape", "square-min");
topoplot(mean(RM_delta_change{2} - RM_delta_change{1}, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";

% PT
p2 = statFcn(RM_delta_change{3}, RM_delta_change{4});
plotScatterEEG(RM_delta_change{3}, RM_delta_change{4}, EEGPos, statFcn, false);
params = topoplotConfig(EEGPos, find(p2 < alphaVal), 4, 13);
mSubplot(3, 4, 4, "shape", "square-min");
topoplot(mean(RM_delta_change{4} - RM_delta_change{3}, 2), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 14;
cb.FontWeight = "bold";