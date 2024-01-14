% Neuroscan 64
% chs2Avg = [6:8, 12:16, 22, 23]; area = "Frontal";
% chs2Avg = [15, 23, 24, 32, 34, 42]; area = "Temporal";
% chs2Avg = [34:36, 40:59]; area = "Parietal";
% chs2Avg = [53:64]; area = "Occipital";

area = "Temporal-Parietal-Occipital";
chs2Avg = [[15, 23, 24, 32, 34, 42], [34:36, 40:59], [53:64]];

chs2Avg = unique(chs2Avg);
chs2Avg(ismember(chs2Avg, [33, 43, 60, 64])) = []; % Exclude A1,A2,CB1,CB2 from analysis