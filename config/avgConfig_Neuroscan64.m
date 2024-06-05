%% Neuroscan 64
% area = "Frontal";      chs2Avg = [1:23];
% area = "Temporal";     chs2Avg = [15, 23, 24, 32, 34, 42];
% area = "Parietal";     chs2Avg = [34:42, 44:59];
% area = "Occipital";    chs2Avg = [53:59, 61:63];
% area = "All channels"; chs2Avg = 1:64;

area = "Temporal-Parietal-Occipital";
chs2Avg = [[15, 23, 24, 32, 34, 42], [34:37, 39:59], [53:64]];

% Remove duplicated channels
chs2Avg = unique(chs2Avg);

% Exclude A1,A2,CB1,CB2 from analysis
chs2Avg(ismember(chs2Avg, [33, 43, 60, 64])) = [];