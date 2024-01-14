ccc;

ROOTPATH = '..\DATA\MAT DATA\pre';
DATAPATHs = dir(fullfile(ROOTPATH, '**\*.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);
[~, filenames] = cellfun(@fileparts, DATAPATHs, "UniformOutput", false);
DATAPATHs(strcmp(filenames, "ICA res")) = [];
[~, filenames] = cellfun(@fileparts, DATAPATHs, "UniformOutput", false);

EEGPos = EEGPos_Neuroscan64;
LOCPATH = 'Neuroscan_chan64.loc';
badChs = [];

for dIndex = 1:length(DATAPATHs)
    close all force;

    disp(['Current data: ', DATAPATHs{dIndex}]);

    if strcmp(filenames{dIndex}, "data")
        continue;
    end

    load(DATAPATHs{dIndex});
    SUBJECTPATH = getRootDirPath(fileparts(DATAPATHs{dIndex}), 2);

    if ~exist(fullfile(SUBJECTPATH, "ICA", "ICA res.mat"), "file")
        channels = 1:size(trialsEEG{1}, 1);
        [comp, ICs] = ICA_PopulationEEG(trialsEEG, fs, window, "chs2doICA", channels, "EEGPos", EEGPos, "LOCPATH", LOCPATH);
        
        trialsEEG = reconstructData(trialsEEG, comp, ICs);
        
        mkdir(fullfile(SUBJECTPATH, "ICA"));
        save(fullfile(SUBJECTPATH, "ICA", "ICA res.mat"), "comp", "ICs");
    else
        load(fullfile(SUBJECTPATH, "ICA", "ICA res.mat"));
        trialsEEG = reconstructData(trialsEEG, comp, ICs);
    end

    mSave(fullfile(getRootDirPath(fileparts(DATAPATHs{dIndex}), 1), "data.mat"), "trialsEEG", "trialAll", "window", "windowBase", "fs");
end