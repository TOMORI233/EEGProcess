ccc;

cd(fileparts(mfilename("fullpath")));

MATPATHs = dir("..\DATA\MAT DATA\temp\**\passive3\chMean.mat");
% MATPATHs = dir("..\DATA\MAT DATA\pre\**\passive3\data.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);

SAVEPATHs = replace(MATPATHs, "chMean.mat", "source change CT.mat");
FIGUREROOTPATH = "..\Figures\source\change CT (Reg)";

% SAVEPATHs = replace(MATPATHs, "chMean.mat", "source change CT (Irreg).mat");
% FIGUREROOTPATH = "..\Figures\source\change CT (Irreg)";

[~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 2), MATPATHs, "UniformOutput", false);
SUBJECTs = cellfun(@(x) x{1}, SUBJECTs, "UniformOutput", false);

%% Parameters
ft_setPath2Top;

EEGPos = EEGPos_Neuroscan64;

% change
window1 = [1000, 1300]; % ms
window2 = [1000, 1300]; % ms

% onset
% window1 = [-300, 0]; % ms
% window2 = [0, 300]; % ms

%% Load
% remove M1,M2,CB1,CB2
labels0 = EEGPos.channelNames;
excludeChIdx0 = contains(labels0, {'M1', 'M2', 'CB1', 'CB2'});
labels0(excludeChIdx0) = [];

chIdx = ~excludeChIdx0;

[elec, vol, mri, grid, atlas] = prepareSourceAnalysis(labels0);

%% Batch
for sIndex = 1:length(MATPATHs)
    close all;
    
    if exist(SAVEPATHs{sIndex}, "file")
        continue;
    end

    load(MATPATHs{sIndex});

    trialsEEG1 = {chData([chData.type] == "REG" & [chData.ICI] == 4).chMean};
    trialsEEG2 = {chData([chData.type] == "REG" & [chData.ICI] == 4.06).chMean};
    
    % trialsEEG1 = {chData([chData.type] == "IRREG" & [chData.ICI] == 4).chMean};
    % trialsEEG2 = {chData([chData.type] == "IRREG" & [chData.ICI] == 4.06).chMean};

    trialsEEG1 = cutData(trialsEEG1, window, window1);
    trialsEEG2 = cutData(trialsEEG2, window, window2);

    trialsEEG1 = cellfun(@(x) x(chIdx, :), trialsEEG1, "UniformOutput", false);
    trialsEEG2 = cellfun(@(x) x(chIdx, :), trialsEEG2, "UniformOutput", false);

    % base
    [~, ~, data_cov1] = prepareFieldtripData(trialsEEG1, window1, fs, EEGPos.channelNames(chIdx));
    source1 = mSourceAnalysis(data_cov1, elec, vol, grid, 'eloreta');

    % erp
    [~, ~, data_cov2] = prepareFieldtripData(trialsEEG2, window2, fs, EEGPos.channelNames(chIdx));
    source2 = mSourceAnalysis(data_cov2, elec, vol, grid, 'eloreta');

    cfg = [];
    cfg.parameter = 'avg.pow';
    cfg.operation = '((x1-x2)./(x1+x2))'; % normalize
    source_diff = ft_math(cfg, source2, source1);
    [Fig2D, Fig3D] = mSourceplot(source_diff, mri, 'slice', 'jet');

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
cfg.operation = '((x1-x2)./(x1+x2))';
source_diff = ft_math(cfg, source2_avg, source1_avg);
source_diff.pow = source_diff.pow .* (stat.mask == 1);
[~, Fig3D] = mSourceplot(source_diff, mri, 'slice', flipud(slanCM('RdYlBu')), 0.5);
scaleAxes(Fig3D, "c", [-0.7, 0.7], "ignoreInvisible", false);

ax = findobj(Fig3D, "Type", "Axes");
% left
exportgraphics(ax(3), fullfile(FIGUREROOTPATH, "left-population.jpg"), "Resolution", 900);
% right
colorbar(ax(1), "off");
exportgraphics(ax(1), fullfile(FIGUREROOTPATH, "right-population.jpg"), "Resolution", 900);
% colorbar
cRange = get(ax(1), "CLim");
exportcolorbar(cRange, fullfile(FIGUREROOTPATH, "colorbar.jpg"), "jet", "ShowZero", true);