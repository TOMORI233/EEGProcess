function [EEGDatasets, trialDatasets] = EEGPreprocessNeuroscan(ROOTPATH, opts)
    % This function exports CDT data
    narginchk(1, 2);

    if nargin < 2
        opts = [];
    end

    rulesROOTPATH = fullfile(getRootDirPath(fileparts(mfilename("fullpath")), 2), "rules");
    rulesForOneDay = dir(rulesROOTPATH);
    rulesForOneDay = {rulesForOneDay(cellfun(@(x) strcmp(obtainArgoutN(@fileparts, 3, x), '.xlsx'), {rulesForOneDay.name}')).name}';

    DATEStr = getOr(opts, "DATEStr");
    if ~isempty(DATEStr) && any(contains(rulesForOneDay, DATEStr))
        % Specify rules for one day if rules file exists
        opts.rules = rulesConfig(fullfile(rulesROOTPATH, rulesForOneDay{contains(rulesForOneDay, DATEStr)}));
    else
        opts.rules = rulesConfig();
    end

    files = dir(ROOTPATH);
    load(fullfile(ROOTPATH, string(what(ROOTPATH).mat)), "-mat", "data");

    % Protocols to export defined by user (default: export all defined in trialsData)
    protocols = getOr(opts, "protocols", cellfun(@string, {data.protocol}));

    idx = 0;

    for pIndex = 1:length(protocols)
        temp = {files(contains({files.name}, protocols(pIndex))).name}';

        if isempty(temp)
            disp(['Recording missing for ', char(protocols(pIndex))]);
        else
            disp(['Current protocol: ', char(protocols(pIndex))]);
            disp('Try loading data from *.cdt');
            EEG = loadcurry(char(fullfile(ROOTPATH, temp{1})));
            disp('Done.');

            idx = idx + 1;
            EEGDatasets(idx).protocol = protocols(pIndex);
            EEGDatasets(idx).data = EEG.data(1:64, :);
            EEGDatasets(idx).fs = EEG.srate;
            EEGDatasets(idx).channels = 1:size(EEGDatasets(idx).data, 1);
            EEGDatasets(idx).event = EEG.event;

            trialDatasets(idx).protocol = protocols(pIndex);
            trialDatasets(idx).trialAll = EEGBehaviorProcess(data(cellfun(@string, {data.protocol}) == protocols(pIndex)).trialsData, EEGDatasets(idx), opts.rules);
        end
    end

    disp("Data loading success.");

    return;
end