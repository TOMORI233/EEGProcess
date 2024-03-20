function batchExport(CDTROOTPATH, protocolsToExport, DATESTRs, SUBJECTs)
% Export baseline-correted EEG wave and trials
% SAVEROOTPATH = ROOTPATH\project\MAT DATA\pre\subject\protocol\date\
narginchk(1, 4);

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

SAVEROOTPATH = fullfile(getRootDirPath(fileparts(mfilename("fullpath")), 1), "DATA", "MAT DATA", "pre");

opts.fhp = 0.5;
opts.flp = 40;

if nargin < 2 || isempty(protocolsToExport)
    opts.protocols = ["passive1", "passive2", "passive3", "active1", "active2"];
else
    opts.protocols = protocolsToExport;
end

% window setting, ms
windowBase = [-300, 0];
windows = struct("window",   {[-500, 2500];  ... % passive1
                              [-500, 2500];  ... % passive2
                              [-500, 2500];  ... % passive3
                              [-500, 2500];  ... % active1
                              [-500, 3100]}, ... % active2
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
if nargin < 3
    DATESTRs = dir(CDTROOTPATH);
    DATESTRs = DATESTRs([DATESTRs.isdir]);
    DATESTRs = {DATESTRs(3:end).name}';
end

DAYPATHs = cellfun(@(x) fullfile(CDTROOTPATH, x), DATESTRs, "UniformOutput", false);

% For each day
for dIndex = 1:length(DAYPATHs)
    SUBJECTsTemp = dir(DAYPATHs{dIndex});
        
    if length(SUBJECTsTemp) < 3
        warning(['No DATA found in ', num2str(DATESTRs{dIndex})]);
        continue;
    else
        SUBJECTsTemp = {SUBJECTsTemp(3:end).name}';
    end

    if nargin >= 4
        SUBJECTsTemp = SUBJECTsTemp(contains(SUBJECTsTemp, SUBJECTs));

        if ~all(contains(SUBJECTsTemp, SUBJECTs))
            continue;
        end

    end
    
    % For every subject in a single day
    for sIndex = 1:length(SUBJECTsTemp)
        disp(['Current: Day ', char(DATESTRs{dIndex}), ' ', char(SUBJECTsTemp{sIndex})]);
        DATAPATH = fullfile(CDTROOTPATH, DATESTRs{dIndex}, SUBJECTsTemp{sIndex});
        SAVEPATH = fullfile(SAVEROOTPATH, SUBJECTsTemp{sIndex});

        opts.DATEStr = DATESTRs{dIndex};
        [EEGDatasets, trialDatasets] = EEGPreprocess(DATAPATH, opts);
        fs = EEGDatasets(1).fs;
        protocols = [trialDatasets.protocol]';

        % Protocols
        protocols = protocols(contains(protocols, opts.protocols));

        % For each protocol
        for pIndex = 1:length(protocols)
            mkdir(fullfile(SAVEPATH, protocols{pIndex}));
            MATNAME = fullfile(SAVEPATH, protocols{pIndex}, "data.mat");
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