ccc;

ROOTPATH = getAbsPath('..\DATA\MAT DATA\pre');
SAVEROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');

protocols = {'passive1', 'passive2', 'passive3', 'active1', 'active2'};

for pIndex = 1:length(protocols)
    disp(['Current protocol: ', protocols{pIndex}]);

    DATAPATHs = dir(fullfile(ROOTPATH, ['**\', protocols{pIndex}, '\data.mat']));
    DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);
    SAVEPATHs = cellfun(@(x) strrep(fileparts(x), ROOTPATH, SAVEROOTPATH), DATAPATHs, "UniformOutput", false);

    SUBJECTs = strrep(DATAPATHs, ['\', protocols{pIndex}, '\data.mat'], '');
    temp = split(SUBJECTs, '\');
    SUBJECTs = rowFcn(@(x) x{end}, temp, "UniformOutput", false);

    cellfun(@mkdir, SAVEPATHs);

    for sIndex = 1:length(DATAPATHs)
        disp(['Current: ', SUBJECTs{sIndex}]);
        
        if exist(fullfile(SAVEPATHs{sIndex}, 'chMean.mat'), 'file')
            continue;
        end

        load(DATAPATHs{sIndex});
        clearvars chData

        if contains(protocols{pIndex}, 'active')
            idx = (([trialAll.type] == "REG" | [trialAll.type] == "PT") & [trialAll.correct]) ...
                  | ([trialAll.type] == "IRREG" & ~[trialAll.miss]);
            trialAll = trialAll(idx);
            trialsEEG = trialsEEG(idx);
        end

        if strcmp(protocols{pIndex}, 'passive2')
            vars = unique([trialAll.variance])';
            for vIndex = 1:length(vars)
                idx = [trialAll.variance] == vars(vIndex);
                chData(vIndex, 1).chMean = calchMean(trialsEEG(idx));
                chData(vIndex, 1).variance = vars(vIndex);
                chData(vIndex, 1).type = "IRREG";
                chData(vIndex, 1).nTrial = sum(idx);
            end
        else
            % Click train
            ICIs = unique([trialAll.ICI])';
            ICIs(ICIs == 0) = [];
            n = 0;
            for dIndex = 1:length(ICIs)
                % REG
                idx = [trialAll.ICI] == ICIs(dIndex) & [trialAll.type] == "REG";
                if any(idx)
                    n = n + 1;
                    chData(n, 1).chMean = calchMean(trialsEEG(idx));
                    chData(n, 1).ICI = ICIs(dIndex);
                    chData(n, 1).freq = 0;
                    chData(n, 1).type = "REG";
                    chData(n, 1).nTrial = sum(idx);
                end

                % IRREG
                idx = [trialAll.ICI] == ICIs(dIndex) & [trialAll.type] == "IRREG";
                if any(idx)
                    n = n + 1;
                    chData(n, 1).chMean = calchMean(trialsEEG(idx));
                    chData(n, 1).ICI = ICIs(dIndex);
                    chData(n, 1).freq = 0;
                    chData(n, 1).type = "IRREG";
                    chData(n, 1).nTrial = sum(idx);
                end
            end

            % Pure tone
            freqs = unique([trialAll.freq])';
            freqs(freqs == 0) = [];
            for fIndex = 1:length(freqs)
                n = n + 1;
                idx = [trialAll.freq] == freqs(fIndex);
                chData(n, 1).chMean = calchMean(trialsEEG(idx));
                chData(n, 1).ICI = 0;
                chData(n, 1).freq = freqs(fIndex);
                chData(n, 1).type = "PT";
                chData(n, 1).nTrial = sum(idx);
            end
        end

        save(fullfile(SAVEPATHs{sIndex}, 'chMean.mat'), "chData", "window", "fs");
    end
end