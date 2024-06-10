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
nperm = 1e3;

interval = 0;
run(fullfile(pwd, "config\plotConfig.m"));
run(fullfile(pwd, "config\avgConfig_Neuroscan64.m"));

EEGPos = EEGPos_Neuroscan64;
chs2Ignore = EEGPos.ignore;

%% Window config for RM
% change response
windowChange = [1000, 1280];

%% Load
window = load(DATAPATHs{1}).window;
fs = load(DATAPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%% GFP plot
% REG
ICIsREG = unique([data{1}([data{1}.type] == "REG").ICI])';
pREG = cell(length(ICIsREG) - 1, 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    temp = cellfun(@(x) calGFP(x, chs2Ignore), temp, "UniformOutput", false);

    if dIndex == 1
        gfpControl = temp;
    else
        pREG{dIndex - 1} = gfpPermTest(cell2mat(temp), cell2mat(gfpControl), nperm, "Tail", "left");
    end

    chDataREG(dIndex, 1).chMean = calchMean(temp);
    chDataREG(dIndex, 1).chErr = calchErr(temp);
    chDataREG(dIndex, 1).color = colors{dIndex};
    chDataREG(dIndex, 1).legend = ['REG ', num2str(ICIsREG(dIndex))];
end

plotRawWaveMulti(chDataREG, window);
scaleAxes("x", [1000 + ICIsREG(1), 1500]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000 + ICIsREG(1); 2000}));
yRange = get(gca, "YLim");
t = linspace(window(1), window(2), size(chDataREG(1).chMean, 2));
for dIndex = 1:length(pREG)
    h = fdr_bh(pREG{dIndex}, 0.01, 'pdep');
    h = double(h);
    h(h == 0) = nan;
    h(h == 1) = yRange(2) + dIndex * 0.05;
    h = scatter(t, h, "MarkerFaceColor", chDataREG(dIndex + 1).color, "MarkerEdgeColor", "none", ...
                "Marker", "square");
    setLegendOff(h);
end
set(gca, "YLim", [yRange(1), yRange(2) + (dIndex + 1) * 0.05]);

% IRREG
ICIsIRREG = unique([data{1}([data{1}.type] == "IRREG").ICI])';
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    temp = cellfun(@(x) calGFP(x, chs2Ignore), temp, "UniformOutput", false);
    chDataIRREG(dIndex, 1).chMean = calchMean(temp);
    chDataIRREG(dIndex, 1).chErr = calchErr(temp);
    chDataIRREG(dIndex, 1).color = colors{dIndex};
    chDataIRREG(dIndex, 1).legend = ['IRREG ', num2str(ICIsIRREG(dIndex))];
end

plotRawWaveMulti(chDataIRREG, window);
scaleAxes("x", [0, 1500]);
scaleAxes("y", "on");
addLines2Axes(struct("X", {0; 1000; 2000}));

%% RM computation (RM of grand-averaged wave)
% REG
RM_baseREG = cell(length(ICIsREG), 1);
RM_changeREG = cell(length(ICIsREG), 1);
for dIndex = 1:length(ICIsREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsREG(dIndex) & [x.type] == "REG").chMean, data, "UniformOutput", false);
    temp = cellfun(@(x) calGFP(x, chs2Ignore), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChange);
    RM_changeREG{dIndex} = cellfun(@(x) max(mean(x, 1)), temp2);
end

% IRREG
RM_baseIRREG = cell(length(ICIsIRREG), 1);
RM_changeIRREG = cell(length(ICIsIRREG), 1);
for dIndex = 1:length(ICIsIRREG)
    temp = cellfun(@(x) x([x.ICI] == ICIsIRREG(dIndex) & [x.type] == "IRREG").chMean, data, "UniformOutput", false);
    temp = cellfun(@(x) calGFP(x, chs2Ignore), temp, "UniformOutput", false);
    temp1 = cutData(temp, window, windowBase);
    RM_baseIRREG{dIndex} = cellfun(@(x) rmfcn(mean(x, 1)), temp1);
    temp2 = cutData(temp, window, windowChange);
    RM_changeIRREG{dIndex} = cellfun(@(x) max(mean(x, 1)), temp2);
end

RM_delta_changeREG = cellfun(@(x, y)   (x - y) ./ (x + y), RM_changeREG, RM_baseREG, "UniformOutput", false);
RM_delta_changeIRREG = cellfun(@(x, y) (x - y) ./ (x + y), RM_changeIRREG, RM_baseIRREG, "UniformOutput", false);

%% Statistics
[~, p_RM_changeREG_vs_base] = cellfun(@(x, y) ttest(x, y), RM_baseREG, RM_changeREG);
[~, p_RM_changeREG_vs_control] = cellfun(@(x) ttest(RM_changeREG{1}, x), RM_changeREG);

[~, p_RM_changeIRREG_vs_base] = cellfun(@(x, y) ttest(x, y), RM_baseIRREG, RM_changeIRREG);
[~, p_RM_changeIRREG_vs_control] = cellfun(@(x) ttest(RM_changeIRREG{1}, x), RM_changeIRREG);

[~, p_RM_delta_change_REG_vs_IRREG] = ttest(RM_delta_changeREG{end}, RM_delta_changeIRREG{end});

%% Tunning plot
FigTuning = figure;
mSubplot(1, 1, 1, "shape", "square-min");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, RM_delta_changeREG), cellfun(@SE, RM_delta_changeREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG");
hold on;
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, RM_delta_changeIRREG), cellfun(@SE, RM_delta_changeIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change}");

%% REG 4-4.06 vs IRREG 4-4.06
FigREG_vs_IRREG = figure;
mSubplot(1, 2, 1, "shape", "square-min", "margin_left", 0.15);
plot(t, chDataREG(end).chMean, "Color", "r", "LineWidth", 2, "DisplayName", "REG 4-4.06");
hold on;
plot(t, chDataIRREG(end).chMean, "Color", "k", "LineWidth", 2, "DisplayName", "IRREG 4-4.06");
legend;
xlabel('Time (ms)');
xlim([-200, 2000]);
scaleAxes("y");
ylabel('Response (\muV)');
title(['Global field power | N=', num2str(length(data))]);
addLines2Axes(gca, struct("X", 1000 + ICIsREG(1), "color", [255 128 0] / 255, "width", 2));

mSubplot(1, 2, 2, "shape", "square-min", "margin_left", 0.15);
scatter(RM_delta_changeIRREG{end}, RM_delta_changeREG{end}, 50, "black");
syncXY;
xlabel("RM_{IRREG 4-4.06} (\muV)");
ylabel("RM_{REG 4-4.06} (\muV)");
title(['REG vs IRREG | p=', num2str(p_RM_delta_change_REG_vs_IRREG)]);
addLines2Axes(gca);
addLines2Axes(gca, struct("X", 0));
addLines2Axes(gca, struct("Y", 0));
