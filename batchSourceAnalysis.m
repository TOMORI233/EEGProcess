ccc;

cd(fileparts(mfilename("fullpath")));

MATPATHs = dir("..\DATA\MAT DATA\temp\**\passive3\chMean.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

SAVEPATHs = replace(MATPATHs, "chMean.mat", "source change CT.mat");

FIGUREROOTPATH = "..\Figures\source\change CT";

[~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 2), MATPATHs, "UniformOutput", false);
SUBJECTs = cellfun(@(x) x{1}, SUBJECTs, "UniformOutput", false);

%% Parameters
ft_setPath2Top;

EEGPos = EEGPos_Neuroscan64;

% remove M1, M2
EEGPos.channelNames([33, 43]) = [];

[elec, vol, mri, leadfield] = prepareSourceAnalysis(EEGPos);
idx = cellfun(@(x) find(ismember(upper(EEGPos.channelNames), upper(x))), elec.label);

window1 = [700, 1000]; % ms
window2 = [1000, 1300]; % ms

%% Batch
for sIndex = 1:length(MATPATHs)
    close all;
    
    if exist(SAVEPATHs{sIndex}, "file")
        continue;
    end

    load(MATPATHs{sIndex});

    % based on trial data
    temp = {chData([chData.type] == "PT").chMean}';
    temp = cutData(temp, window, window1);
    temp = cellfun(@(x) x(idx, :), temp, "UniformOutput", false);
    [~, ~, data_cov1] = prepareFieldtripData(temp, window1, fs, EEGPos.channelNames(idx));
    source1 = mSourceAnalysis(data_cov1, elec, vol, leadfield);

    temp = {chData([chData.type] == "PT").chMean}';
    temp = cutData(temp, window, window2);
    temp = cellfun(@(x) x(idx, :), temp, "UniformOutput", false);
    [~, ~, data_cov2] = prepareFieldtripData(temp, window2, fs, EEGPos.channelNames(idx));
    source2 = mSourceAnalysis(data_cov2, elec, vol, leadfield);

    cfg = [];
    cfg.parameter = 'avg.pow';
    cfg.operation = 'subtract';
    source_diff = ft_math(cfg, source2, source1);
    [Fig2D, Fig3D] = mSourceplot(source_diff, mri, "slice");

    save(SAVEPATHs{sIndex}, "source1", "source2");
    exportgraphics(Fig2D, fullfile(FIGUREROOTPATH, ['2D-', SUBJECTs{sIndex}, '.jpg']), "Resolution", 300);
    exportgraphics(Fig3D, fullfile(FIGUREROOTPATH, ['3D-', SUBJECTs{sIndex}, '.jpg']), "Resolution", 300);
end

%% Load
matres = cellfun(@(x) matfile(x), SAVEPATHs, "UniformOutput", false);
source1 = cellfun(@(x) x.source1, matres, "UniformOutput", false);
source2 = cellfun(@(x) x.source2, matres, "UniformOutput", false);

cfg = [];
cfg.parameter = 'avg.pow';
source1_avg = ft_sourcegrandaverage(cfg, source1{:});
source2_avg = ft_sourcegrandaverage(cfg, source2{:});

% mSourceplot(source1_avg, mri, "slice", "Base");
% mSourceplot(source2_avg, mri, "slice", "Onset");

%% Permutation test
cfg = [];
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.correctm = 'cluster';
cfg.numrandomization = 1e3;
cfg.tail = 0;  % two-tailed
cfg.alpha = 0.05;
cfg.clusteralpha = 0.05;
cfg.clustertail = 0;
cfg.minnbchan = 0;
cfg.parameter = 'pow';

numSubjects = length(source1);
design = zeros(2, 2 * numSubjects);
design(1, 1:numSubjects) = 1;
design(1, numSubjects+1:end) = 2;
design(2, :) = repmat(1:numSubjects, 1, 2);

cfg.design = design;
cfg.ivar = 1;
cfg.uvar = 2;

stat = ft_sourcestatistics(cfg, source1{:}, source2{:});

% plot
cfg = [];
cfg.parameter = 'avg.pow';
cfg.operation = 'subtract';
source_diff = ft_math(cfg, source2_avg, source1_avg);
source_diff.pow = source_diff.pow .* stat.mask;
[Fig2D, Fig3D] = mSourceplot(source_diff, mri, "slice", "Diff-stat");
