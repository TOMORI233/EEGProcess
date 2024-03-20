function batchSingle(protocolsToProcess, dataOnlyOpt, SUBJECTs)
% Process each protocol for each subject
% ROOTPATH\project\MAT DATA\**\subject\protocol\date\
narginchk(0, 3);

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

currentPath = getRootDirPath(fileparts(mfilename("fullpath")), 1);
MATROOTPATH = fullfile(currentPath, "DATA", "MAT DATA", "pre");

if nargin < 1 || isempty(protocolsToProcess)
    protocolsToProcess = ["passive1", "passive2", "passive3", "active1", "active2"];
end

if nargin < 2
    params.dataOnlyOpt = false; % true - save temporal data only without plotting
else
    params.dataOnlyOpt = dataOnlyOpt;
end

if nargin < 3
    MATPATHs = pathManager(MATROOTPATH);
else
    MATPATHs = pathManager(MATROOTPATH, "subjects", SUBJECTs);
end

MATPATHs = MATPATHs(contains({MATPATHs.protocol}, protocolsToProcess));
protocolProcessFcns = cellfun(@(x) eval(strcat('@', x, 'ProcessFcn')), {MATPATHs.protocol}, "UniformOutput", false);

% For each protocol
for pIndex = 1:length(MATPATHs)
    protocolProcessFcn = protocolProcessFcns{pIndex};

    % For each subject
    for sIndex = 1:length(MATPATHs(pIndex).path)
        load(MATPATHs(pIndex).path(sIndex), "windowBase", "window", "trialsEEG", "trialAll", "fs");
        params.FIGPATH = strrep(fileparts(MATPATHs(pIndex).path(sIndex)), "DATA\MAT DATA\pre", "Figures\pre");
        params.SAVEPATH = strrep(fileparts(MATPATHs(pIndex).path(sIndex)), "MAT DATA\pre", "MAT DATA\temp");
        params.windowBase = windowBase;
        protocolProcessFcn(trialAll, trialsEEG, window, fs, params);
    end
    
end
