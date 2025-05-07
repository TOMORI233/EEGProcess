function batchExportNeuracleJoint(DATAROOTPATH, SAVEROOTPATH, pIDs, opts)
% You can specify a list of [pIDs] to export (in double). If so, the ICA
% will be performed on the joint data.
% 
% To use a local config file, specify [opts] with your local config file
% and you can make some changes to the default parameters using:
% >> configFcn = @preprocessConfigEEG_local;
% >> opts = configFcn("name1", value1, "name2", value2, ...);
% >> batchExportNeuracleJoint(DATAROOTPATH, SAVEROOTPATH, [], opts);
%
% Before using it, you must make sure that there is only ONE [pID].mat
% file matched to data.bdf in one folder.
%
% All parameters that are user-defined and can be altered are placed
% at the beginning of the script.
%
% Usually, the storage is arranged in this way:
%     E:\EEG\Neuracle\浙江省人民医院\DATA\ (DATAROOTPATH)
%     |----2024011401\ (subjectID)
%     |----2024011402\
%     |----2024032801\
%          |----config.mat (subject info)
%          |----101\ (protocolID)
%          |----102\
%          |----103\
%               |----data.bdf
%               |----evt.bdf
%               |----103.mat (trial info)

%% 
narginchk(2, 4);

if nargin < 3
    pIDs = []; % default=[] for all protocols
end

%% Path definition
%%% Convert relative path to absolute path
DATAROOTPATH = getAbsPath(DATAROOTPATH);
SAVEROOTPATH = getAbsPath(SAVEROOTPATH);

%%% Find the folder paths that contain data.bdf (Usually it is named [pID])
% Use regular expression
DATAPATHs = {dir(fullfile(char(DATAROOTPATH), "**\data.bdf")).folder}';
pIDs0 = cellfun(@(x) str2double(getLastDirPath(x, 1)), DATAPATHs);

if ~isempty(pIDs)
    DATAPATHs = DATAPATHs(ismember(pIDs0, pIDs));
end

%%% Define the folder paths where you save your MAT data
% By replacing the root path of raw data with the root path of MAT data
SAVEPATHs = cellfun(@(x) strrep(x, DATAROOTPATH, SAVEROOTPATH), DATAPATHs, "UniformOutput", false);

%%% Create save paths
cellfun(@mkdir, SAVEPATHs);

%% Parameter settings (IMPORTANT!!)
%%% Read from config file
if nargin < 4
    opts = preprocessConfigEEG;
end

%%% ------------Time window for trial segmentation, in ms-----------------
% DO NOT make it larger than your inter-trial interval
% opts.window = [-1000, 3000];

%%% -------------Bad channel numbers in your recording--------------------
% This setting may influence your ICA result. Be cautious
% opts.badChs = []; % usually it is set empty for none of bad channels
opts.badChs = 60:64; % for Neuracle 64-channel system

%%% ---------EEG Postion that defines the grid map for plotting the wave in actual topography---------
% Location file is usually paired with EEG position function
% You can find these functions in 'EEGProcess\config\'

% ----For Neuracle 32-channel system----
% opts.EEGPos = EEGPos_Neuracle32();

% ----For Neuracle 64-channel system----
opts.EEGPos = EEGPos_Neuracle64();

%%% -----------You can also specify other parameters by assigning it as a field to [opts]----------------
% See private\EEGPreprocessNeuracle.m for other parameters

% e,g. Apply a high cut-off frequency setting to the low-pass filter:
%      opts.flp = 40; % default

%%% ------------ICA option---------------
% If set "on", apply the ICA result of one protocol to the others for one subject
% opts.sameICAOpt = "off"; % default
% opts.ICAPATH = []; % default
opts.nMaxIcaTrial = []; % [] for all trials, default=100

%% Preprocess and save
% Batch
[trialsEEG0, trialAll0, fs, comp] = EEGPreprocessNeuracleJoint(DATAPATHs, opts);
close all force;

for index = 1:length(DATAPATHs)
    % Skip preprocessing for existed MAT data
    if exist(fullfile(SAVEPATHs{index}, "data.mat"), "file")
        disp(['Data file exists in ', char(SAVEPATHs{index}), '. Skip']);
        continue;
    end

    % Separation for each protocol
    idx = find([trialAll0.trialNum] == 1);
    trialAll = trialAll0(idx(index):idx(index + 1) - 1);
    trialsEEG = trialsEEG0(idx(index):idx(index + 1) - 1);

    parseStruct(opts, "window", "badChs");

    % Save
    save(fullfile(SAVEPATHs{index}, "ICA res.mat"), "comp");
    save(fullfile(SAVEPATHs{index}, "data.mat"), "trialAll", "trialsEEG", "window", "badChs", "fs");
end
