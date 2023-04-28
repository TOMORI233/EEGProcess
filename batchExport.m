function batchExport(protocolsToExport)
% Export baseline-correted EEG wave and trials
narginchk(0, 1);

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

ROOTPATH = "F:\EEG\DATA\";
SAVEROOTPATH = "..\MAT DATA\";

opts.fhp = 0.5;
opts.flp = 40;

if nargin < 1
    opts.protocols = ["passive1", "passive2", "passive3", "active1", "active2"];
else
    opts.protocols = protocolsToExport;
end

% window setting, ms
windowBase = [-300, 0];
windows = struct("window",   {[-500, 2500];  ... % passive1
                              [-500, 2000];  ... % passive2
                              [-500, 2000];  ... % passive3
                              [-500, 2000];  ... % active1
                              [-500, 2600]}, ... % active2
                 "protocol", {"passive1"; ...
                              "passive2"; ...
                              "passive3"; ...
                              "active1";  ...
                              "active2"});
save("windows.mat", "windows", "windowBase");

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
        disp(['Current: Day ', char(DATESTRs{dIndex}), ' ', char(SUBJECTs{sIndex})]);
        DATAPATH = fullfile(ROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});
        SAVEPATH = fullfile(SAVEROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});

        opts.DATEStr = DATESTRs{dIndex};
        [EEGDatasets, trialDatasets] = EEGPreprocess(DATAPATH, opts);
        fs = EEGDatasets(1).fs;
        protocols = [trialDatasets.protocol]';

        mkdir(SAVEPATH);

        % Protocols
        protocols = protocols(contains(protocols, opts.protocols));

        % For each protocol
        for pIndex = 1:length(protocols)
            MATNAME = fullfile(SAVEPATH, strcat(protocols(pIndex), ".mat"));
            window = windows([windows.protocol] == protocols{pIndex}).window;
            trialAll = trialDatasets([trialDatasets.protocol] == protocols(pIndex)).trialAll';
            trialsEEG = selectEEG(EEGDatasets([EEGDatasets.protocol] == protocols(pIndex)), ...
                                              trialAll, ...
                                              window);

            % Baseline correction
            trialsEEG = baselineCorrection(trialsEEG, fs, window, windowBase);

            tIdx = excludeTrials(trialsEEG, tTh, chTh, "userDefineOpt", "off");
            trialsEEG(tIdx) = [];
            trialAll(tIdx) = [];
            save(MATNAME, "windowBase", "window", "trialsEEG", "trialAll", "fs");
        end

    end

end