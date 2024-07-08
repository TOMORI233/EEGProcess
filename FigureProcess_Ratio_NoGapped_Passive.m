ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive3\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'passive3\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio No-Gapped Passive");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\plotConfig.m"));
run(fullfile(pwd, "config\avgConfig_Neuroscan64.m"));

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

% For A1&P3 comparison 
% load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "subjectIdxA1");
% data = data(subjectIdxA1);

%% Wave plot
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    chDataREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataREG_All(dIndex, 1).chErr = calchErr(temp);
    chDataREG_All(dIndex, 1).color = colors{dIndex};
    chDataREG_All(dIndex, 1).legend = ['REG ', num2str(ICIsREG(dIndex))];
end

plotRawWaveMultiEEG(chDataREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [1000 + ICIsREG(1), 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataREG_All, "UniformOutput", false);
t = linspace(window(1), window(2), length(chMean{1}))';
chDataREG = addfield(chDataREG_All, "chMean", chMean);
chDataREG = addfield(chDataREG, "chErr", chErr);
FigGrandAvg = plotRawWaveMulti(chDataREG, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [1000 + ICIsREG(1), 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
mPrint(FigGrandAvg, fullfile(FIGUREPATH, ['Grand average wave REG (', char(area), ').png']), "-dpng", "-r300");

% IRREG
ICIsIRREG = unique([data{1}([data{1}.type] == "IRREG").ICI])';
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    chDataIRREG_All(dIndex, 1).chMean = calchMean(temp);
    chDataIRREG_All(dIndex, 1).chErr = calchErr(temp);
    chDataIRREG_All(dIndex, 1).color = colors{dIndex};
    chDataIRREG_All(dIndex, 1).legend = ['IRREG ', num2str(ICIsIRREG(dIndex))];
end

plotRawWaveMultiEEG(chDataIRREG_All, window, [], EEGPos_Neuroscan64);
scaleAxes("x", [0, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

chMean = arrayfun(@(x) mean(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chErr = arrayfun(@(x) SE(x.chMean(chs2Avg, :), 1), chDataIRREG_All, "UniformOutput", false);
chDataIRREG = addfield(chDataIRREG_All, "chMean", chMean);
chDataIRREG = addfield(chDataIRREG, "chErr", chErr);
plotRawWaveMulti(chDataIRREG, window, ['Grand-averaged wave in ', char(area)]);
xlabel('Time (ms)');
ylabel('Response (\muV)');
scaleAxes("x", [0, 1500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

%% Window config for RM
% change response
tIdxChange = t >= 1000 & t <= 1260;

[~, peakTime] = arrayfun(@(x) maxt(x.chMean(tIdxChange), t(tIdxChange)), chDataREG);
windowChangePeakREG = peakTime + windowBand;
[~, troughTime] = arrayfun(@(x, y) mint(x.chMean(tIdxChange & t > y), t(tIdxChange & t > y)), chDataREG, peakTime);
windowChangeTroughREG = troughTime + windowBand;

[~, peakTime] = arrayfun(@(x) maxt(x.chMean(tIdxChange), t(tIdxChange)), chDataIRREG);
windowChangePeakIRREG = peakTime + windowBand;
[~, troughTime] = arrayfun(@(x, y) mint(x.chMean(tIdxChange & t > y), t(tIdxChange & t > y)), chDataIRREG, peakTime);
windowChangeTroughIRREG = troughTime + windowBand;

%% RM computation (RM of grand-averaged wave)
% REG
RM_baseREG = cell(length(ICIsREG), 1);
RM_changePeakREG = cell(length(ICIsREG), 1);
RM_changeTroughREG = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChangePeakREG(dIndex, :));
    RM_changePeakREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
    temp3 = cutData(temp, window, windowChangeTroughREG(dIndex, :));
    RM_changeTroughREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp3);
end

% IRREG
RM_baseIRREG = cell(length(ICIsIRREG), 1);
RM_changePeakIRREG = cell(length(ICIsIRREG), 1);
RM_changeTroughIRREG = cell(length(ICIsIRREG), 1);
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    temp = cellfun(@(x) x(chs2Avg, :), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChangePeakIRREG(dIndex, :));
    RM_changePeakIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp2);
    temp3 = cutData(temp, window, windowChangeTroughIRREG(dIndex, :));
    RM_changeTroughIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp3);
end

RM_delta_changePeakREG = cellfun(@(x, y) x - y, RM_changePeakREG, RM_baseREG, "UniformOutput", false);
RM_delta_changePeakIRREG = cellfun(@(x, y) x - y, RM_changePeakIRREG, RM_baseIRREG, "UniformOutput", false);
RM_delta_changeTroughREG = cellfun(@(x, y) x - y, RM_changeTroughREG, RM_baseREG, "UniformOutput", false);
RM_delta_changeTroughIRREG = cellfun(@(x, y) x - y, RM_changeTroughIRREG, RM_baseIRREG, "UniformOutput", false);

%% Topo RM computation
% change response
% REG 4-4.06
temp = cellfun(@(x) x([x.ICI] == ICIsREG(end) & [x.type] == "REG").chMean, data, "UniformOutput", false);
[~, peakTime] = maxt(chDataREG_All(end).chMean(:, tIdxChange), t(tIdxChange), 2);
temp1 = cellfun(@(x) rmfcn(x, 2), cutData(temp, window, windowBase), "UniformOutput", false);
temp2 = cellfun(@(x) rowFcn(@(y, z) rmfcn(cutData(y, window, z + windowBand), 2), x, peakTime), temp, "UniformOutput", false);
RM_topo_delta_changePeakREG = calchMean(temp2 - temp1);
[~, p_channels_REG_vs_base] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(temp1), changeCellRowNum(temp2));
p_channels_REG_vs_base = mafdr(p_channels_REG_vs_base, 'BHFDR', true);

% IRREG 4-4.06
temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(end) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
[~, peakTime] = maxt(chDataIRREG_All(end).chMean(:, tIdxChange), t(tIdxChange), 2);
temp1 = cellfun(@(x) rmfcn(x, 2), cutData(temp, window, windowBase), "UniformOutput", false);
temp2 = cellfun(@(x) rowFcn(@(y, z) rmfcn(cutData(y, window, z + windowBand), 2), x, peakTime), temp, "UniformOutput", false);
RM_topo_delta_changePeakIRREG = calchMean(temp2 - temp1);
[~, p_channels_IRREG_vs_base] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(temp1), changeCellRowNum(temp2));
p_channels_IRREG_vs_base = mafdr(p_channels_IRREG_vs_base, 'BHFDR', true);

% onset response
% REG 4
tIdxOnset = t > 0 & t <= 300;
temp = cellfun(@(x) {x([x.type] == "REG").chMean}', data, "UniformOutput", false);
temp = cellfun(@calchMean, temp, "UniformOutput", false);
chMean = calchMean(temp);
[~, peakTime] = maxt(chMean(:, tIdxOnset), t(tIdxOnset), 2);
temp1 = cellfun(@(x) rmfcn(x, 2), cutData(temp, window, windowBase0), "UniformOutput", false);
temp2 = cellfun(@(x) rowFcn(@(y, z) rmfcn(cutData(y, window, z + windowBand), 2), x, peakTime), temp, "UniformOutput", false);
RM_topo_delta_onsetPeakREG = calchMean(temp2 - temp1);
[~, p_channels_onset_vs_base] = cellfun(@(x, y) ttest(x, y), changeCellRowNum(temp1), changeCellRowNum(temp2));
p_channels_onset_vs_base = mafdr(p_channels_onset_vs_base, 'BHFDR', true);

%% Statistics
[~, p_RM_changePeakREG_vs_base] = cellfun(@(x, y) ttest2(x, y), RM_baseREG, RM_changePeakREG);
[~, p_RM_changePeakREG_vs_control] = cellfun(@(x) ttest(RM_changePeakREG{1}, x), RM_changePeakREG);
[~, p_RM_changeTroughREG_vs_base] = cellfun(@(x, y) ttest2(x, y), RM_baseREG, RM_changeTroughREG);
[~, p_RM_changeTroughREG_vs_control] = cellfun(@(x) ttest(RM_changeTroughREG{1}, x), RM_changeTroughREG);

[~, p_RM_changePeakIRREG_vs_base] = cellfun(@(x, y) ttest2(x, y), RM_baseIRREG, RM_changePeakIRREG);
[~, p_RM_changePeakIRREG_vs_control] = cellfun(@(x) ttest(RM_changePeakIRREG{1}, x), RM_changePeakIRREG);
[~, p_RM_changeTroughIRREG_vs_base] = cellfun(@(x, y) ttest2(x, y), RM_baseIRREG, RM_changeTroughIRREG);
[~, p_RM_changeTroughIRREG_vs_control] = cellfun(@(x) ttest(RM_changeTroughIRREG{1}, x), RM_changeTroughIRREG);

[~, p_RM_delta_changePeak_REG_vs_IRREG] = ttest(RM_delta_changePeakREG{end}, RM_delta_changePeakIRREG{end});

%% Tunning plot
FigTuning = figure;
mSubplot(1, 2, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changePeakREG), cellfun(@SE, RM_delta_changePeakREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, RM_delta_changePeakIRREG), cellfun(@SE, RM_delta_changePeakIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change peak}");

mSubplot(1, 2, 2, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changeTroughREG), cellfun(@SE, RM_delta_changeTroughREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, RM_delta_changeTroughIRREG), cellfun(@SE, RM_delta_changeTroughIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change trough}");

mPrint(FigTuning, fullfile(FIGUREPATH, ['RM tuning (', char(area), ').png']), "-dpng", "-r300");

%% REG 4-4.06 vs IRREG 4-4.06
FigREG_vs_IRREG = figure;
mSubplot(1, 2, 1, "shape", "square-min", "margin_left", 0.15);
plot(t - 1000 - ICIsREG(1), chDataREG(end).chMean(:), "Color", "r", "LineWidth", 2, "DisplayName", "REG 4-4.06");
hold on;
plot(t - 1000 - ICIsREG(1), chDataIRREG(end).chMean(:), "Color", "k", "LineWidth", 2, "DisplayName", "IRREG 4-4.06");
legend;
xlabel('Time (ms)');
xlim([-1000, 1000]);
scaleAxes("y", "symOpt", "max");
ylabel('Response (\muV)');
title(['Grand-averaged wave in ', char(area), ' | N=', num2str(length(data))]);
addLines2Axes(gca, struct("X", 0, "color", [255 128 0] / 255, "width", 2));

mSubplot(1, 2, 2, "shape", "square-min", "margin_left", 0.15);
scatter(RM_delta_changePeakIRREG{end}, RM_delta_changePeakREG{end}, 50, "black");
syncXY;
xlabel("\DeltaRM_{IRREG 4-4.06} (\muV)");
ylabel("\DeltaRM_{REG 4-4.06} (\muV)");
title(['REG vs IRREG | p=', num2str(p_RM_delta_changePeak_REG_vs_IRREG)]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));

mPrint(FigREG_vs_IRREG, fullfile(FIGUREPATH, ['REG vs IRREG (', char(area), ').png']), "-dpng", "-r300");

%% save for comparison
params0 = [fieldnames(getVarsFromWorkspace('RM_\W*')); ...
          fieldnames(getVarsFromWorkspace('p_\W*')); ...
          fieldnames(getVarsFromWorkspace('window\W*'))];
save(['..\DATA\MAT DATA\figure\Res P3 (', char(area), ').mat'], ...
     "fs", ...
     "ICIsREG", ...
     "ICIsIRREG", ...
     "chs2Avg", ...
     "chDataREG", ...
     "chDataIRREG", ...
     params0{:});

%% Grand average wave plot of all channels REG vs IRREG
FigREG = plotRawWaveEEG(chDataREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigREG, "x", [0, 2000]);
yRange = scaleAxes(FigREG, "y", "on", "symOpt", "max");
addLines2Axes(FigREG, struct("X", {0; 1000 + ICIsREG(1)}, "color", [255 128 0] / 255, "width", 2));
allAxes = findobj(FigREG, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).XAxis.Visible = "off";
    allAxes(aIndex).YAxis.Visible = "off";
end
mPrint(FigREG, fullfile(FIGUREPATH, 'REG 4-4.06.png'), "-dpng", "-r300");

FigIRREG = plotRawWaveEEG(chDataIRREG_All(end).chMean, [], window, [], EEGPos_Neuroscan64);
scaleAxes(FigIRREG, "x", [0, 2000]);
scaleAxes(FigIRREG, "y", yRange);
addLines2Axes(FigIRREG, struct("X", {0; 1000 + ICIsREG(1)}, "color", [255 128 0] / 255, "width", 2));
allAxes = findobj(FigIRREG, "Type", "axes");
for aIndex = 1:length(allAxes)
    allAxes(aIndex).XAxis.Visible = "off";
    allAxes(aIndex).YAxis.Visible = "off";
end
mPrint(FigIRREG, fullfile(FIGUREPATH, 'IRREG 4-4.06.png'), "-dpng", "-r300");

%% Topo plot
locs = readlocs('Neuroscan_chan64.loc');
channels = 1:length(locs);
chs2Plot = channels(~ismember(channels, [33, 43, 60, 64]))'; % Neuroscan
% chsSelect = chs2Avg;

params0 = [{'plotchans'}, {chs2Plot}                    , ... % indices of channels to plot
           {'plotrad'  }, {0.36}                        , ... % plot radius
           {'headrad'  }, {max([locs(chs2Plot).radius])}, ... % head radius
           {'intrad'   }, {0.4}                         , ... % interpolate radius
           {'conv'     }, {'on'}                        , ... % plot radius just covers maximum channel radius
           {'colormap' }, {'jet'}                       , ...
           {'emarker'  }, {{'o', 'k', 8, 1}}          ];    % {MarkerType, Color, Size, LineWidth}

% NOTICE: channels selected in 'emaker2' option are from channels
%         specified by 'plotchans', instead of from the original channels.

figure;
% onset
chsSelect = find(p_channels_onset_vs_base < alphaVal);
params = [params0, ...
          {'emarker2'}, {{find(ismember(chs2Plot, chsSelect)), '.', 'k', 30, 1}}]; % {Channels, MarkerType, Color, Size, LineWidth}
mSubplot(1, 3, 1, "shape", "square-min");
topoplot(RM_topo_delta_onsetPeakREG, locs, params{:});
title('Onset Response of REG 4', "FontSize", 14);
colorbar;

% REG
chsSelect = find(p_channels_REG_vs_base < alphaVal);
params = [params0, ...
          {'emarker2'}, {{find(ismember(chs2Plot, chsSelect)), '.', 'k', 30, 1}}];
mSubplot(1, 3, 2, "shape", "square-min");
topoplot(RM_topo_delta_changePeakREG, locs, params{:});
title(['Change Response of ', chDataREG(end).legend], "FontSize", 14);
colorbar;

% IRREG
chsSelect = find(p_channels_IRREG_vs_base < alphaVal);
params = [params0, ...
          {'emarker2'}, {{find(ismember(chs2Plot, chsSelect)), '.', 'k', 30, 1}}];
mSubplot(1, 3, 3, "shape", "square-min");
topoplot(RM_topo_delta_changePeakIRREG, locs, params{:});
title(['Change Response of ', chDataIRREG(end).legend], "FontSize", 14);
colorbar;

scaleAxes("c", "ignoreInvisible", false);

%% 
params = params0;
params{end} = {'.', 'k', [], 1};
figure;
mSubplot(1, 2, 1, "shape", "square-min");
topoplot(RM_topo_delta_changePeakREG, locs, params{:});
title(['Change Response of ', chDataREG(end).legend], "FontSize", 14);
colorbar;
mSubplot(1, 2, 2, "shape", "square-min");
topoplot(RM_topo_delta_changePeakIRREG, locs, params{:});
title(['Change Response of ', chDataIRREG(end).legend], "FontSize", 14);
colorbar;
scaleAxes("c", "ignoreInvisible", false);
mPrint(gcf, "..\temp\topo.jpg", "-djpeg", "-r300");
