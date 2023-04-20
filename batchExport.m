clear; clc; close all force;

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

ROOTPATH = "F:\EEG\DATA\";
SAVEROOTPATH = "D:\Education\Lab\Projects\EEG\MAT DATA\";

opts.fhp = 0.5;
opts.flp = 40;
opts.save = false;

% window setting
windows = {[-500, 2000]; ... % passive1
           [-500, 2000]; ... % passive2
           [-500, 2000]; ... % passive3
           [-500, 2000]; ... % active1
           [-500, 2600]};    % active2

% exclude trials
tTh = 0.2;
chTh = 20;

%% Load and save
DATESTRs = dir(ROOTPATH);
DATESTRs = DATESTRs([DATESTRs.isdir]);
DATESTRs = {DATESTRs(3:end).name}';
DAYPATHs = cellfun(@(x) fullfile(ROOTPATH, x), DATESTRs, "UniformOutput", false);

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
        DATAPATH = fullfile(ROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});
        SAVEPATH = fullfile(SAVEROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});

        if ~exist(SAVEPATH, "dir")
            [EEGDatasets, trialDatasets] = EEGPreprocess(DATAPATH, opts);
            fs = EEGDatasets(1).fs;
            protocols = [trialDatasets.protocol]';
        else
            disp(strcat('Day ', DATESTRs{dIndex}, ' ', SUBJECTs{sIndex}, ' already exported. Skip.'));
            continue;
        end

        mkdir(SAVEPATH);

        % Protocols
        protocols = protocols(contains(protocols, ["passive1", "passive2", "passive3", "active1", "active2"]));

        % For each protocol
        for pIndex = 1:length(protocols)
            MATNAME = fullfile(SAVEPATH, strcat(protocols(pIndex), ".mat"));

            if ~exist(MATNAME, "file")
                window = windows{pIndex};
                trialAll = trialDatasets([trialDatasets.protocol] == protocols(pIndex)).trialAll';
                [trialsEEG, ~, ~, ~, reservedIdx] = selectEEG(EEGDatasets([EEGDatasets.protocol] == protocols(pIndex)), trialAll, window);
                trialAll = trialAll(reservedIdx);

                tIdx = excludeTrials(trialsEEG, tTh, chTh, "userDefineOpt", "off");
                trialsEEG(tIdx) = [];
                trialAll(tIdx) = [];
                mSave(MATNAME, "window", "trialsEEG", "trialAll", "fs");
            else
                disp(strcat('Day ', DATESTRs{dIndex}, ' ', SUBJECTs{sIndex}, ' ', protocols(pIndex), ' already exported. Skip.'));
            end

        end

    end

end