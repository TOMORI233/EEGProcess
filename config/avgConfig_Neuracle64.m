% Neuracle 64
% chs2Avg = [11:16, 22:25]; area = "Frontal";
% chs2Avg = [24, 25, 33, 34, 41, 42]; area = "Temporal";
% chs2Avg = [37:42, 43:56]; area = "Parietal";
% chs2Avg = [50:59]; area = "Occipital";

area = "Temporal-Parietal-Occipital";
chs2Avg = [[24, 25, 33, 34, 41, 42], [37:42, 43:56], [50:59]];

chs2Avg = unique(chs2Avg);
chs2Avg(ismember(chs2Avg, [60:64])) = []; % Exclude A1,A2 and channels not connected from analysis