function batchCollect(matfilesToCollect)
% Collect individual data and save
narginchk(0, 1);

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

MATROOTPATH = "..\MAT DATA\";
POPUPATH = "..\MAT Population\";

mkdir(POPUPATH);

if nargin < 1
    matfilesToCollect = ["Behavior_A1_Res", ...
                         "Behavior_A2_Res", ...
                         "FindChs", ...
                         "chMean_P1", ...
                         "chMean_P2", ...
                         "chMean_P3", ...
                         "chMean_A1", ...
                         "chMean_A2", ...
                         "BRI_P1", ...
                         "BRI_P2", ...
                         "BRI_P3", ...
                         "BRI_A1", ...
                         "BRI_A2"];
end

%% Load and save
DATESTRs = dir(MATROOTPATH);
DATESTRs = DATESTRs([DATESTRs.isdir]);
DATESTRs = {DATESTRs(3:end).name}';
DAYPATHs = cellfun(@(x) fullfile(MATROOTPATH, x), DATESTRs, "UniformOutput", false);

for mIndex = 1:length(matfilesToCollect)

    if exist("data", "var")
        clearvars data
    end

    nSubject = 1;

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
            matfiles = what(MATDirPATH).mat;
            matfiles = matfiles(contains(matfiles, matfilesToCollect(mIndex)));

            if length(matfiles) > 1
                error("Duplicate MAT file name");
            end

            data(nSubject, 1) = load(fullfile(MATDirPATH, matfiles{1}));
            nSubject = nSubject + 1;
        end

    end

    save(fullfile(POPUPATH, strcat(matfilesToCollect(mIndex), "_Population.mat")), "data");
end