clear; clc; close all force;

ROOTPATH = "F:\EEG\DATA\";
SAVEROOTPATH = "D:\Lab\Projects\EEG\MAT DATA\";

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

%% Load and save
DATESTRs = dir(ROOTPATH);
DATESTRs = DATESTRs([DATESTRs.isdir]);
DATESTRs = {DATESTRs(3:end).name}';
DAYPATHs = cellfun(@(x) fullfile(ROOTPATH, x), DATESTRs, "UniformOutput", false);

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
            mkdir(SAVEPATH);
            [EEGDatasets, trialDatasets] = EEGPreprocess(DATAPATH, opts);
            protocols = [trialDatasets.protocol]';
        else
            disp(strcat('Day ', DATESTRs{dIndex}, ' ', SUBJECTs{sIndex}, ' already exported. Skip.'));
            continue;
        end

        for pIndex = 1:length(protocols)
            MATNAME = fullfile(SAVEPATH, strcat(protocols(pIndex), ".mat"));

            if ~exist(MATNAME, "file")
                window = windows{pIndex};
                trialAll = trialDatasets([trialDatasets.protocol] == protocols(pIndex)).trialAll';
                [trialsEEG, ~, ~, ~, reservedIdx] = selectEEG(EEGDatasets([EEGDatasets.protocol] == protocols(pIndex)), trialAll, window);
                trialAll = trialAll(reservedIdx);

                tIdx = excludeTrials(trialsEEG, tTh, 1, "userDefineOpt", "off");
                trialsEEG(tIdx) = [];
                trialAll(tIdx) = [];
                save(MATNAME, "window", "trialsEEG", "trialAll");
            else
                disp(strcat('Day ', DATESTRs{dIndex}, ' ', SUBJECTs{sIndex}, ' ', protocols(pIndex), ' already exported. Skip.'));
            end

        end

    end

end