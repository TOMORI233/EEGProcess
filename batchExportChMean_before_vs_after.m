ccc;

%% Paths
DATAPATHs = dir("..\DATA\MAT DATA\pre\**\passive3\data.mat");
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SAVEPATHs = cellfun(@(x) strrep(x, '\pre\', '\temp\'), DATAPATHs, "UniformOutput", false);
SAVEPATHs = cellfun(@(x) strrep(x, 'data.mat', 'chMeanIRREG_before_after.mat'), SAVEPATHs, "UniformOutput", false);

%% 
for sIndex = 1:length(DATAPATHs)
    load(DATAPATHs{sIndex});

    idx = find([trialAll.ICI] == 4 & [trialAll.type] == "IRREG");
    idxBefore = idx(1:fix(numel(idx) / 2));
    idxAfter = idx(fix(numel(idx) / 2) + 1:end);
    chData(1).chMean = calchMean(trialsEEG(idxBefore));
    chData(1).type = 'before';
    chData(2).chMean = calchMean(trialsEEG(idxAfter));
    chData(2).type = 'after';

    save(SAVEPATHs{sIndex}, "chData", "window", "fs");
end
