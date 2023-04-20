clear; clc; close all force;

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

windowBase = [-300, 0];
MATROOTPATH = "D:\Lab\Projects\EEG\MAT DATA\";

%% Load and save
DATESTRs = dir(MATROOTPATH);
DATESTRs = DATESTRs([DATESTRs.isdir]);
DATESTRs = {DATESTRs(3:end).name}';
DAYPATHs = cellfun(@(x) fullfile(MATROOTPATH, x), DATESTRs, "UniformOutput", false);

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
        DATAPATH = fullfile(MATROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});
        SAVEPATH = DATAPATH;

        matfiles = what(DATAPATH).mat;
        protocols = cellfun(@(x) obtainArgoutN(@fileparts, 2, x), matfiles, "UniformOutput", false);
        protocolProcessFcns = cellfun(@(x) eval(strcat('@', x, 'ProcessFcn')), protocols, "UniformOutput", false);

        % For each protocol
        for pIndex = 1:length(protocols)
            protocolProcessFcn = protocolProcessFcns{pIndex};
            MATPATH = fullfile(DATAPATH, matfiles{pIndex});
            load(MATPATH);
            trialsEEG = baselineCorrection(trialsEEG, fs, window, windowBase);
            params.SAVEPATH = SAVEPATH;
            params.windowBase = windowBase;
            protocolProcessFcn(trialAll, trialsEEG, window, fs, params);
        end

    end

end