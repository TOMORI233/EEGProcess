ccc;

ROOTPATH = '..\DATA\MAT DATA\pre';
SAVEROOTPATH = '..\DATA\MAT DATA\temp';

protocols = {'active1', 'active2'};

for pIndex = 1:length(protocols)
    disp(['Current protocol: ', protocols{pIndex}]);

    DATAPATHs = dir(fullfile(ROOTPATH, ['**\', protocols{pIndex}, '\data.mat']));
    DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);
    SAVEPATHs = cellfun(@(x) strrep(fileparts(x), ROOTPATH, SAVEROOTPATH), DATAPATHs, "UniformOutput", false);

    SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
    SUBJECTs = strrep(SUBJECTs, [protocols{pIndex}, '\data.mat'], '');
    SUBJECTs = strrep(SUBJECTs, '\', '');

    cellfun(@mkdir, SAVEPATHs);

    for sIndex = 1:length(DATAPATHs)
        disp(['Current: ', SUBJECTs{sIndex}]);

        load(DATAPATHs{sIndex}, "trialAll");

        idx = ~[trialAll.miss];
        trialAll = trialAll(idx);

        % Click train
        ICIs = unique([trialAll.ICI])';
        ICIs(ICIs == 0) = [];
        n = 0;
        clearvars behaviorRes
        for dIndex = 1:length(ICIs)
            % REG
            idx = [trialAll.ICI] == ICIs(dIndex) & [trialAll.type] == "REG";
            if any(idx)
                n = n + 1;
                behaviorRes(n, 1).nDiff = sum(idx & [trialAll.isDiff]);
                behaviorRes(n, 1).nTotal = sum(idx);
                behaviorRes(n, 1).type = "REG";
                behaviorRes(n, 1).freq = 0;
                behaviorRes(n, 1).ICI = ICIs(dIndex);
            end

            % IRREG
            idx = [trialAll.ICI] == ICIs(dIndex) & [trialAll.type] == "IRREG";
            if any(idx)
                n = n + 1;
                behaviorRes(n, 1).nDiff = sum(idx & [trialAll.isDiff]);
                behaviorRes(n, 1).nTotal = sum(idx);
                behaviorRes(n, 1).type = "IRREG";
                behaviorRes(n, 1).freq = 0;
                behaviorRes(n, 1).ICI = ICIs(dIndex);
            end
        end

        % Pure tone
        freqs = unique([trialAll.freq])';
        freqs(freqs == 0) = [];
        for fIndex = 1:length(freqs)
            n = n + 1;
            idx = [trialAll.freq] == freqs(fIndex);
            behaviorRes(n, 1).nDiff = sum(idx & [trialAll.isDiff]);
            behaviorRes(n, 1).nTotal = sum(idx);
            behaviorRes(n, 1).type = "PT";
            behaviorRes(n, 1).freq = freqs(fIndex);
            behaviorRes(n, 1).ICI = 0;
        end

        save(fullfile(SAVEPATHs{sIndex}, 'behavior.mat'), "behaviorRes");
    end
end