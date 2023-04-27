function batchSingle(protocolsToProcess, dataOnlyOpt)
% Process each protocol for each subject
narginchk(0, 2);

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

MATROOTPATH = "..\MAT DATA\";
FIGROOTPATH = "..\Figures\";

if nargin < 1 || isempty(protocolsToProcess)
    protocolsToProcess = ["passive1", "passive2", "passive3", "active1", "active2"];
end

if nargin < 2
    params.dataOnlyOpt = false; % true - save temporal data only without plotting
else
    params.dataOnlyOpt = dataOnlyOpt;
end

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
        MATDirPATH = fullfile(MATROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});
        FIGPATH = fullfile(FIGROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});

        if exist(FIGPATH, "dir") && ~params.dataOnlyOpt
            disp(['Day ', char(DATESTRs{dIndex}), ' ', char(SUBJECTs{sIndex}), ' already processed. Skip.']);
            continue;
        end

        disp(['Current: Day ', char(DATESTRs{dIndex}), ' ', char(SUBJECTs{sIndex})]);
        matfiles = what(MATDirPATH).mat;
        protocols = cellfun(@(x) obtainArgoutN(@fileparts, 2, x), matfiles, "UniformOutput", false);
        idx = contains(protocols, protocolsToProcess);
        protocols = protocols(idx);
        matfiles = matfiles(idx);
        protocolProcessFcns = cellfun(@(x) eval(strcat('@', x, 'ProcessFcn')), protocols, "UniformOutput", false);

        % For each protocol
        for pIndex = 1:length(protocols)
            protocolProcessFcn = protocolProcessFcns{pIndex};
            MATPATH = fullfile(MATDirPATH, matfiles{pIndex});
            load(MATPATH, "windowBase", "window", "trialsEEG", "trialAll", "fs");

            params.FIGPATH = FIGPATH;
            params.SAVEPATH = MATDirPATH;
            params.windowBase = windowBase;
            protocolProcessFcn(trialAll, trialsEEG, window, fs, params);
        end

    end

end