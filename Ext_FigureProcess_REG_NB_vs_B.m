ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs1 = dir(fullfile(ROOTPATH, '**\passive3\chMean.mat'));
DATAPATHs2 = dir(fullfile(ROOTPATH, '**\active1\chMeanAll.mat'));
DATAPATHs1 = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs1, "UniformOutput", false);
DATAPATHs2 = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs2, "UniformOutput", false);

[~, ~, SUBJECTs] = cellfun(@(x) getLastDirPath(x, 2), DATAPATHs1, "UniformOutput", false);

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Behavior vs Non-behavior");

%% Params
nperm = 1e3;
alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

chIdx = ~ismember(EEGPos.channels, EEGPos.ignore);
exampleCh = 'POz';
chIdxExample = find(ismember(EEGPos.channelNames, exampleCh));

colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

% subject filter
load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");
DATAPATHs1 = DATAPATHs1(subjectIdxA1);
DATAPATHs2 = DATAPATHs2(subjectIdxA1);
SUBJECTs = SUBJECTs(subjectIdxA1);

% RM window
windowOnset = [64, 234];
windowChange = [1080, 1368];
windowOffset = [2000, 2200];

%% Load
load(DATAPATHs1{1}, "window", "fs");

data1 = cellfun(@(x) load(x).chData, DATAPATHs1, "UniformOutput", false);
data2 = cellfun(@(x) load(x).chData, DATAPATHs2, "UniformOutput", false);

%% 
% REG
ICIs = unique([data1{1}([data1{1}.type] == "REG").ICI])';
[gfp1, gfp2, ...
 trialsEEG_group1, trialsEEG_group2] = deal(cell(length(ICIs), 1));
for dIndex = 1:length(ICIs)
    % Passive
    trialsEEG_group1{dIndex} = cellfun(@(x) x([x.ICI] == ICIs(dIndex) & [x.type] == "REG").chMean, data1, "UniformOutput", false);
    trialsEEG_group1{dIndex} = cellfun(@(x) x ./ std(x, [], 2), trialsEEG_group1{dIndex}, "UniformOutput", false);
    trialsEEG_group1{dIndex} = cellfun(@(x) insertRows(x(chIdx, :), EEGPos.ignore, 0), trialsEEG_group1{dIndex}, "UniformOutput", false);

    chData1(dIndex, 1).chMean = calchMean(trialsEEG_group1{dIndex});
    chData1(dIndex, 1).chErr = calchErr(trialsEEG_group1{dIndex});
    chData1(dIndex, 1).color = colors{dIndex};
    chData1(dIndex, 1).legend = ['REG ', num2str(ICIs(1)), '-', num2str(ICIs(dIndex))];

    gfp1{dIndex} = calGFP(trialsEEG_group1{dIndex}, EEGPos.ignore);
    gfp1{dIndex} = cat(1, gfp1{dIndex}{:});
    gfpData1(dIndex, 1).chMean = mean(gfp1{dIndex}, 1);
    gfpData1(dIndex, 1).chErr = SE(gfp1{dIndex}, 1);
    gfpData1(dIndex, 1).color = colors{dIndex};
    gfpData1(dIndex, 1).legend = ['REG ', num2str(ICIs(1)), '-', num2str(ICIs(dIndex))];

    % Attentive
    trialsEEG_group2{dIndex} = cellfun(@(x) x([x.ICI] == ICIs(dIndex) & [x.type] == "REG").chMean, data2, "UniformOutput", false);
    trialsEEG_group2{dIndex} = cellfun(@(x) x ./ std(x, [], 2), trialsEEG_group2{dIndex}, "UniformOutput", false);
    trialsEEG_group2{dIndex} = cellfun(@(x) insertRows(x(chIdx, :), EEGPos.ignore, 0), trialsEEG_group2{dIndex}, "UniformOutput", false);

    chData2(dIndex, 1).chMean = calchMean(trialsEEG_group2{dIndex});
    chData2(dIndex, 1).chErr = calchErr(trialsEEG_group2{dIndex});
    chData2(dIndex, 1).color = colors{dIndex};
    chData2(dIndex, 1).legend = ['REG ', num2str(ICIs(1)), '-', num2str(ICIs(dIndex))];

    gfp1{dIndex} = calGFP(trialsEEG_group2{dIndex}, EEGPos.ignore);
    gfp1{dIndex} = cat(1, gfp1{dIndex}{:});
    gfpData2(dIndex, 1).chMean = mean(gfp1{dIndex}, 1);
    gfpData2(dIndex, 1).chErr = SE(gfp1{dIndex}, 1);
    gfpData2(dIndex, 1).color = colors{dIndex};
    gfpData2(dIndex, 1).legend = ['REG ', num2str(ICIs(1)), '-', num2str(ICIs(dIndex))];
end

%% Statistics
try
    load("stat_REG_NB_vs_B.mat", "stats");
catch ME
    cfg = [];
    cfg.minnbchan = 1;
    cfg.neighbours = EEGPos.neighbours;
    
    % onset
    
    
    % change & offset
    for dIndex = 1:length(ICIs)
        stats(dIndex, 1) = CBPT(cfg, trialsEEG_group1{dIndex}, trialsEEG_group2{dIndex});
    end
    
    save("stat_REG_NB_vs_B.mat", "stats");
end

%% Example channel
t = linspace(window(1), window(2), size(chData1(1).chMean, 2));

Fig1 = plotRawWaveMulti(chData1, window, 'Passive', [1, 1], chIdxExample);
Fig2 = plotRawWaveMulti(chData2, window, 'Attentive', [1, 1], chIdxExample);
scaleAxes([Fig1, Fig2], "x", [-300, 2500]);
scaleAxes([Fig1, Fig2], "y", "symOpt", "max");

FigCompare1 = figure;
copyaxes(Fig1.Children(2), mSubplot(FigCompare1, 1, 2, 1));
xlabel("Time from onset (ms)");
ylabel("Response (\muV)");
legend;
copyaxes(Fig2.Children(2), mSubplot(FigCompare1, 1, 2, 2));
xlabel("Time from onset (ms)");
legend;
addLines2Axes(FigCompare1, struct("Y", 0, "style", "-", "width", 0.5));
addLines2Axes(FigCompare1, struct("X", {0; 1004; 2000}));
delete([Fig1, Fig2]);

FigCompare2 = figure;
clearvars chDataTemp
for dIndex = 1:length(ICIs)
    chDataTemp(1, 1) = chData1(dIndex);
    chDataTemp(2, 1) = chData2(dIndex);
    chDataTemp = addfield(chDataTemp, "chMean", arrayfun(@(x) x.chMean(chIdxExample, :), chDataTemp, "UniformOutput", false));
    chDataTemp = addfield(chDataTemp, "chErr", arrayfun(@(x) x.chErr(chIdxExample, :), chDataTemp, "UniformOutput", false));
    chDataTemp = addfield(chDataTemp, "color", {'k'; 'r'});
    chDataTemp = addfield(chDataTemp, "legend", {'Passive'; 'Attentive'});
    
    FigTemp = plotRawWaveMulti(chDataTemp, window, chData1(dIndex).legend);
    copyaxes(FigTemp.Children(2), mSubplot(FigCompare2, length(ICIs), 1, dIndex, "nSize", [3/10, 1]));
    delete(FigTemp);
end
scaleAxes(FigCompare2, "y", "symOpt", "max");
addLines2Axes(FigCompare2, struct("Y", 0, "style", "-", "width", 0.5));

for dIndex = 1:length(ICIs)
    mSubplot(FigCompare2, length(ICIs), 1, dIndex, "nSize", [1/5, 1], "alignment", "center-right");
    imagesc("XData", t, "YData", EEGPos.channels, "CData", stats(dIndex).stat);
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
end
scaleAxes(FigCompare2, "x", [800, 2500]);
scaleAxes(FigCompare2, "c", "on", "autoTh", [0, 1]);
addLines2Axes(FigCompare2, struct("X", {0; 1004; 2000}, "style", "-", "width", 1.5));