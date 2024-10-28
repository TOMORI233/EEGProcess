function batchExportNeuroscan(CDTROOTPATH, SAVEROOTPATH, PROTOCOLs, opts)
% Export baseline-correted EEG wave and trials
% SAVEROOTPATH = ROOTPATH\project\MAT DATA\pre\subject\protocol\date\
narginchk(2, 4);

if nargin < 3
    opts.protocols = ["passive3", "passive1", "active1", "active2"];
else
    opts.protocols = PROTOCOLs;
end

%% Parameter settings
if nargin < 4
    opts = getOrFull(opts, preprocessConfigEEG);
    opts.EEGPos = EEGPos_Neuroscan64;
    opts.badChs = [33, 43]; % M1, M2
end
parseStruct(opts);
window = opts.window;

sameICAOpt = "on";

%% Load and save
DATESTRs = dir(CDTROOTPATH);
DATESTRs = DATESTRs([DATESTRs.isdir]);
DATESTRs = {DATESTRs(3:end).name}';

DAYPATHs = cellfun(@(x) fullfile(CDTROOTPATH, x), DATESTRs, "UniformOutput", false);

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
        close all;
        
        disp(['Current: Day ', char(DATESTRs{dIndex}), ' ', char(SUBJECTs{sIndex})]);
        DATAPATH = fullfile(CDTROOTPATH, DATESTRs{dIndex}, SUBJECTs{sIndex});
        SAVEPATH = fullfile(SAVEROOTPATH, SUBJECTs{sIndex});

        % Check files
        skipIdx = false(length(opts.protocols), 1);
        for pIndex = 1:length(opts.protocols)
            MATNAME = fullfile(SAVEPATH, protocols{pIndex}, "data.mat");
            if exist(MATNAME, "file")
                skipIdx(pIndex) = true;
            end
        end
        
        if all(skipIdx)
            continue;
        end

        % Import raw data
        opts.DATEStr = DATESTRs{dIndex};
        [EEGDatasets, trialDatasets] = EEGPreprocessNeuroscan(DATAPATH, opts);
        fs = EEGDatasets(1).fs;
        protocols = [trialDatasets.protocol]';

        % For each protocol
        protocols = protocols(contains(protocols, opts.protocols));

        for pIndex = 1:length(protocols)
                
            if skipIdx(pIndex)
                continue;
            end

            mkdir(fullfile(SAVEPATH, protocols{pIndex}));
            MATNAME = fullfile(SAVEPATH, protocols{pIndex}, "data.mat");

            % Filter
            EEGDatasets([EEGDatasets.protocol] == protocols(pIndex)).data = ECOGFilter(EEGDatasets([EEGDatasets.protocol] == protocols(pIndex)).data, opts.fhp, opts.flp, fs, "Notch", "on");

            % Epoching
            trialAll = trialDatasets([trialDatasets.protocol] == protocols(pIndex)).trialAll(:);
            trialsEEG = selectEEG(EEGDatasets([EEGDatasets.protocol] == protocols(pIndex)), trialAll, window);

            % Perform ICA
            if strcmpi(opts.icaOpt, "on")
                ICAPATH = dir(fullfile(SAVEPATH, '**\ICA res.mat'));

                if isempty(ICAPATH)
                    opts.ICAPATH = [];
                else
                    opts.ICAPATH = ICAPATH(1).folder;
                end

                if strcmpi(sameICAOpt, "on") && ~isempty(opts.ICAPATH) && exist(fullfile(opts.ICAPATH, "ICA res.mat"), "file")
                    load(fullfile(opts.ICAPATH, "ICA res.mat"), "-mat", "comp");
                    channels = comp.channels;
                    ICs = comp.ICs;
                    badChs = comp.badChs;
                else
                    disp('ICA result does not exist. Performing ICA on data...');
                    channels = 1:size(trialsEEG{1}, 1);
                    temp = baselineCorrection(trialsEEG, fs, window, windowBase);
                    plotRawWave(calchMean(temp), calchStd(temp), window);
                    bc = validateInput(['Input extra bad channels (besides ', num2str(badChs(:)'), '): '], @(x) isempty(x) || all(fix(x) == x & x > 0));
                    badChs = [opts.badChs(:); bc(:)];

                    % First trial exclusion before ICA
                    tIdx = excludeTrials(trialsEEG, 0.4, 20, "userDefineOpt", "off", "badCHs", badChs);
                    trialsEEG(tIdx) = [];
                    trialAll(tIdx) = [];

                    if ~isempty(badChs)
                        disp(['Channel ', num2str(badChs(:)'), ' are excluded from analysis.']);
                        channels(badChs) = [];
                    end

                    if isempty(nMaxIcaTrial)
                        idx = 1:length(trialsEEG);
                    else
                        idx = 1:min(length(trialsEEG), nMaxIcaTrial);
                    end

                    [comp, ICs] = ICA_PopulationEEG(trialsEEG(idx), fs, window, "chs2doICA", channels, "EEGPos", EEGPos);
                end

                % reconstruct data
                trialsEEG = cellfun(@(x) x(channels, :), trialsEEG, "UniformOutput", false);
                trialsEEG = reconstructData(trialsEEG, comp, ICs);
                trialsEEG = cellfun(@(x) insertRows(x, badChs), trialsEEG, "UniformOutput", false);
                trialsEEG = interpolateBadChs(trialsEEG, badChs, EEGPos.neighbours);
            
                comp.channels = channels;
                comp.ICs = ICs;
                comp.badChs = badChs;

                save(fullfile(SAVEPATH, protocols{pIndex}, "ICA res.mat"), "comp");
            else
                badChs = opts.badChs;
            end

            % Baseline correction
            trialsEEG = baselineCorrection(trialsEEG, fs, window, windowBase);

            % Exclude bad trials
            tIdx = excludeTrials(trialsEEG, tTh, chTh, "userDefineOpt", "off", "badCHs", badChs);
            trialsEEG(tIdx) = [];
            trialAll(tIdx) = [];

            save(MATNAME, "windowBase", "window", "trialsEEG", "trialAll", "fs", "badChs");
        end

    end

end