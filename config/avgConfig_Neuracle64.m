%% Neuracle 64
% area = "Frontal";   chs2Avg = [1:25];
% area = "Temporal";  chs2Avg = [24, 25, 33, 34, 41, 42];
% area = "Parietal";  chs2Avg = [35:56];
% area = "Occipital"; chs2Avg = [50:59];

area = "Temporal-Parietal-Occipital";
chs2Avg = [[24, 25, 33, 34, 41, 42], 35:56, 50:59];

% Remove duplicated channels
chs2Avg = unique(chs2Avg);

% Exclude A1,A2 and channels not connected from analysis
chs2Avg(ismember(chs2Avg, [60:64])) = [];