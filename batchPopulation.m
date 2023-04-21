clear; clc; close all force;

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

MATROOTPATH = "D:\Education\Lab\Projects\EEG\MAT DATA\";
POPUPATH = "D:\Education\Lab\Projects\EEG\MAT Population\";

matfilesToProcess = ["Behavior_A1_Res", ...
                     "Behavior_A2_Res", ...
                     "Ratio_ttest_RMS_res"];

%% Load and save
DATESTRs = dir(MATROOTPATH);
DATESTRs = DATESTRs([DATESTRs.isdir]);
DATESTRs = {DATESTRs(3:end).name}';
DAYPATHs = cellfun(@(x) fullfile(MATROOTPATH, x), DATESTRs, "UniformOutput", false);

for mIndex = 1:length(matfilesToProcess)

    if exist("data", "var")
        clearvars data
    end
    
    nSubject = 1;

    % For each day
    for dIndex = 1:length(DAYPATHs)
        SUBJECTs = dir(DAYPATHs{dIndex});

        if length(SUBJECTs) < 3
            warning(['No DATA found in ', num2str(DATESTRs{dIndex})]);
            continue;
        else
            SUBJECTs = {SUBJECTs(3:end).name}';
        end

        % For every subject in a single day
        for sIndex = 1:length(SUBJECTs)
            MATDirPATH = fullfile(MATROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});
            matfiles = what(MATDirPATH).mat;
            matfiles = matfiles(contains(matfiles, matfilesToProcess(mIndex)));
            data(nSubject, 1) = load(fullfile(MATDirPATH, matfiles{1}));
            nSubject = nSubject + 1;
        end

    end

    mSave(fullfile(POPUPATH, strcat(matfilesToProcess(mIndex), "_Population.mat")), "data");
end