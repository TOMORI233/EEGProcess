% This script is to perform ICA on data recorded by Neuroscan system
ccc;

ROOTPATH = '..\DATA\MAT DATA\pre';
DATAPATHs = dir(fullfile(ROOTPATH, '**\data.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);
[~, filenames] = cellfun(@fileparts, DATAPATHs, "UniformOutput", false);
DATAPATHs(strcmp(filenames, "ICA res")) = [];
[~, filenames] = cellfun(@fileparts, DATAPATHs, "UniformOutput", false);

%% 
sameIcaOpt = false;
EEGPos = EEGPos_Neuroscan64;

%% 
for dIndex = 1:length(DATAPATHs)
    close all force;
    disp(['Current data: ', DATAPATHs{dIndex}]);

    if sameIcaOpt
        load(DATAPATHs{dIndex});
        SUBJECTPATH = getRootDirPath(fileparts(DATAPATHs{dIndex}), 1);
    
        if ~exist(fullfile(SUBJECTPATH, "ICA", "ICA res.mat"), "file")
            channels = 1:size(trialsEEG{1}, 1);
            [comp, ICs] = ICA_PopulationEEG(trialsEEG, fs, window, "chs2doICA", channels, "EEGPos", EEGPos);
            
            trialsEEG = reconstructData(trialsEEG, comp, ICs);
            
            mkdir(fullfile(SUBJECTPATH, "ICA"));
            save(fullfile(SUBJECTPATH, "ICA", "ICA res.mat"), "comp", "ICs");
        else

            if exist(fullfile(fileparts(DATAPATHs{dIndex}), "ICA res.mat"), "file")
                disp("ICA already performed. Skip");
            else
                load(fullfile(SUBJECTPATH, "ICA", "ICA res.mat"));
                trialsEEG = reconstructData(trialsEEG, comp, ICs);
                save(fullfile(fileparts(DATAPATHs{dIndex}), "ICA res.mat"), "comp", "ICs");
            end
            
        end

    else

        if exist(fullfile(fileparts(DATAPATHs{dIndex}), "ICA res.mat"), "file")
            disp("ICA already performed. Skip");
        else
            load(DATAPATHs{dIndex});
            channels = 1:size(trialsEEG{1}, 1);
            [comp, ICs] = ICA_PopulationEEG(trialsEEG, fs, window, "chs2doICA", channels, "EEGPos", EEGPos);
            
            trialsEEG = reconstructData(trialsEEG, comp, ICs);
            save(fullfile(fileparts(DATAPATHs{dIndex}), "ICA res.mat"), "comp", "ICs");
        end

    end

    save(fullfile(fileparts(DATAPATHs{dIndex}), "data.mat"), "trialsEEG", "trialAll", "window", "windowBase", "fs");
end