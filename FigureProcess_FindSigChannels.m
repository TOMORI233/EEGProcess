ccc;

% MATPATHsComa = dir("..\DATA\MAT DATA - coma\pre\**\151\data.mat");
MATPATHsComa = dir("..\DATA\MAT DATA - extra\pre\**\113\data.mat");
MATPATHsComa = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHsComa, "UniformOutput", false);
MATPATHsComa(contains(MATPATHsComa, "2024032901")) = [];
[~, temp] = cellfun(@(x) getLastDirPath(x, 2), MATPATHsComa, "UniformOutput", false);
subjectIDsComa = cellfun(@(x) x{1}, temp, "UniformOutput", false);

%% 
windowBase = [-500, -300];
windowOnset = [50, 250];

%% 
for sIndex = 1:length(MATPATHsComa)
    load(MATPATHsComa{sIndex});
    trialsEEG = trialsEEG([trialAll.type] == "REG");
    trialsEEG = cat(3, trialsEEG{:}); % chan_sample_trial
    t = linspace(window(1), window(2), size(trialsEEG, 2));
    tIdxBase = t >= windowBase(1) & t <= windowBase(2);
    tIdxOnset = t >= windowOnset(1) & t <= windowOnset(2);
    RM_base = squeeze(rms(trialsEEG(:, tIdxBase, :), 2)); % chan_trial
    RM_onset = squeeze(rms(trialsEEG(:, tIdxOnset, :), 2));
    [~, p] = rowFcn(@(x, y) ttest(x, y, "Tail", "right"), RM_base, RM_onset);
end