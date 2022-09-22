function [EEGDatasets, trialDatasets] = EEGPreprocess(ROOTPATH, opts)
    narginchk(1, 2);

    if nargin < 2
        opts = [];
    end

    opts = getOrFull(opts, preprocessConfig());

    try
        disp("Try loading data from MAT.");
        temp = string(split(ROOTPATH, '\'));
        temp(end - 1) = "MAT";
        load(fullfile(join(temp, "\"), string(what(ROOTPATH).mat)), "-mat", "EEGDatasets", "trialDatasets");

        if exist("EEGDatasets", "var") && exist("trialDatasets", "var")
            disp("Data loading success.");
            return;
        else
            ME = MException("EEGPreprocess:dataLoading", "File not found.");
            throw(ME);
        end
        
    catch ME
        disp(ME.message);
        disp("Try loading data from *.cdt .");
    end

    files = dir(ROOTPATH);
    load(fullfile(ROOTPATH, string(what(ROOTPATH).mat)), "-mat", "data");
    protocols = cellfun(@string, {data.protocol});

    for index = 1:length(files)
        [~, filename, ext] = fileparts(files(index).name);
        
        if strcmp(ext, ".cdt")
            temp = split(filename, " ");
            temp = string(temp{2});

            if any(contains(protocols, temp, "IgnoreCase", true))
                idx = find(contains(protocols, temp, "IgnoreCase", true), 1);
                EEG = loadcurry(fullfile(char(ROOTPATH), files(index).name));

                EEGDatasets(idx).protocol = protocols(idx);
                EEGDatasets(idx).data = EEG.data(1:end - 1, :);
                EEGDatasets(idx).fs = EEG.srate;
                EEGDatasets(idx).channels = 1:size(EEGDatasets(idx).data, 1);
                EEGDatasets(idx).event = EEG.event;
                EEGDatasets(idx) = EEGFilter(EEGDatasets(idx), opts.fhp, opts.flp);

                trialDatasets(idx).protocol = protocols(idx);
                trialDatasets(idx).trialAll = EEGBehaviorProcess(data(idx).trialsData, EEGDatasets(idx), opts.rules);
            else
                continue;
                % error("Invalid file name for *.cdt");
            end
    
        end
    
    end

    disp("Data loading success.");

    if opts.save
        disp("Saving...");
        temp = string(split(ROOTPATH, '\'));
        temp(end - 1) = "MAT";
        SAVEPATH = join(temp, "\");
        mkdir(SAVEPATH);
        uisave(["EEGDatasets", "trialDatasets"], fullfile(SAVEPATH, "data.mat"));
    end

    return;
end