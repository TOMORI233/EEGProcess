% This script is to export waves averaged across trials for each subject.
% For Neuracle system.
ccc;

ROOTPATH = getAbsPath('..\DATA\MAT DATA - coma\pre');
SAVEROOTPATH = getAbsPath('..\DATA\MAT DATA - coma\temp');

% ROOTPATH = getAbsPath('F:\backup\DATA\MAT DATA - coma\pre');
% SAVEROOTPATH = getAbsPath('F:\backup\DATA\MAT DATA - coma\temp');

protocols = {'151'};
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

        % if exist(fullfile(SAVEPATHs{sIndex}, 'chMean.mat'), 'file')
        %     continue;
        % end

        load(DATAPATHs{sIndex});
        clearvars chData

        trialsEEG = cutData(trialsEEG, window, windowNew);
        window = windowNew;
            
        if strcmp(protocols{pIndex}, '151')
            chData(1, 1).chMean = calchMean(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 4));
            chData(1, 1).chErr  = calchStd(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 4));
            chData(1, 1).ICI    = 4;
            chData(1, 1).freq   = 0;

            chData(2, 1).chMean = calchMean(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 4.06));
            chData(2, 1).chErr  = calchStd(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 4.06));
            chData(2, 1).ICI    = 4.06;
            chData(2, 1).freq   = 0;

            chData(3, 1).chMean = calchMean(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 5));
            chData(3, 1).chErr  = calchStd(trialsEEG([trialAll.type] == "REG" & [trialAll.ICI2] == 5));
            chData(3, 1).ICI    = 5;
            chData(3, 1).freq   = 0;

            chData(4, 1).chMean = calchMean(trialsEEG([trialAll.type] == "PT" & [trialAll.f2] == 200));
            chData(4, 1).chErr  = calchStd(trialsEEG([trialAll.type] == "PT" & [trialAll.f2] == 200));
            chData(4, 1).ICI    = 0;
            chData(4, 1).freq   = 200;
        end

        save(fullfile(SAVEPATHs{sIndex}, 'chMean.mat'), "chData", "window", "fs");
    end
end