function batchCollect(matfilesToCollect)
% Collect individual data and save
% ROOTPATH\project\MAT DATA\**\subject\protocol\date\
narginchk(0, 1);

addpath(genpath(fileparts(mfilename("fullpath"))), "-begin");

currentPath = getRootDirPath(fileparts(mfilename("fullpath")), 1);
MATROOTPATH = fullfile(currentPath, "DATA", "MAT DATA", "temp");
POPUPATH = fullfile(currentPath, "DATA", "MAT DATA", "population");

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
for mIndex = 1:length(matfilesToCollect)
    
    if exist("data", "var")
        clearvars data
    end

    MATPATHs = pathManager(MATROOTPATH, "matPat", matfilesToCollect(mIndex));
    MATPATHs(cellfun(@isempty, {MATPATHs.path})) = [];
    MATPATHs = MATPATHs.path;

    data = mCell2mat(arrayfun(@(x) load(x), MATPATHs, "UniformOutput", false));
    save(fullfile(POPUPATH, strcat(matfilesToCollect(mIndex), "_Population.mat")), "data");
end