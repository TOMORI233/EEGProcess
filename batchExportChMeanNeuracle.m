% This script is to export waves averaged across trials for each subject.
% For Neuracle system.
ccc;

% ROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\pre');
% SAVEROOTPATH = getAbsPath('..\DATA\MAT DATA - extra\temp');

ROOTPATH = getAbsPath('F:\backup\DATA\MAT DATA - extra\pre');
SAVEROOTPATH = getAbsPath('F:\backup\DATA\MAT DATA - extra\temp');

protocols = {'111', '112', '113'};
windowNew = [-500, 2500]; % ms

for pIndex = 1:length(protocols)
    disp(['Current protocol: ', protocols{pIndex}]);

    DATAPATHs = dir(fullfile(ROOTPATH, ['**\', protocols{pIndex}, '\data.mat']));
    DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);
    SAVEPATHs = cellfun(@(x) strrep(fileparts(x), ROOTPATH, SAVEROOTPATH), DATAPATHs, "UniformOutput", false);

    SUBJECTs = strrep(DATAPATHs, ['\', protocols{pIndex}, '\data.mat'], '');
    temp = split(SUBJECTs, '\');
    SUBJECTs = rowFcn(@(x) x{end}, temp, "UniformOutput", false);

    cellfun(@mkdir, SAVEPATHs);

    for sIndex = 1:length(DATAPATHs)
        disp(['Current: ', SUBJECTs{sIndex}]);

        if exist(fullfile(SAVEPATHs{sIndex}, 'chMean.mat'), 'file')
            continue;
        end

        load(DATAPATHs{sIndex});
        clearvars chData

        trialsEEG = cutData(trialsEEG, window, windowNew);
        window = windowNew;

        if strcmp(protocols{pIndex}, '111') % insert
            Ns = unique([trialAll.InsertN])';
            Ns(isnan(Ns)) = [];
            for index = 1:length(Ns)
                chData(index, 1).chMean = calchMean(trialsEEG([trialAll.InsertN] == Ns(index)));
                chData(index, 1).insertN = Ns(index);
            end
            chData(index + 1, 1).chMean = calchMean(trialsEEG(isnan([trialAll.InsertN])));
            chData(index + 1, 1).insertN = nan;

        elseif strcmp(protocols{pIndex}, '112') % variance
            varFactor = unique([trialAll.Var])';
            varFactor(isnan(varFactor)) = [];
            for index = 1:length(varFactor)
                chData(index, 1).chMean = calchMean(trialsEEG([trialAll.Var] == varFactor(index)));
                chData(index, 1).var = varFactor(index);
            end
            chData(index + 1).chMean = calchMean(trialsEEG(isnan([trialAll.Var])));
            chData(index + 1).var = nan;
            
        elseif strcmp(protocols{pIndex}, '113')
            chData(1, 1).chMean = calchMean(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 4));
            chData(1, 1).ICI    = 4;
            chData(1, 1).freq   = 0;

            chData(2, 1).chMean = calchMean(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 5));
            chData(2, 1).ICI    = 5;
            chData(2, 1).freq   = 0;

            chData(3, 1).chMean = calchMean(trialsEEG([trialAll.type] == "PT" & [trialAll.f2] == 250));
            chData(3, 1).ICI    = 0;
            chData(3, 1).freq   = 250;

            chData(4, 1).chMean = calchMean(trialsEEG([trialAll.type] == "PT" & [trialAll.f2] == 200));
            chData(4, 1).ICI    = 0;
            chData(4, 1).freq   = 200;
        end

        save(fullfile(SAVEPATHs{sIndex}, 'chMean.mat'), "chData", "window", "fs");
    end
end