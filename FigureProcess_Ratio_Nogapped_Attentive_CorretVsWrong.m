ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

ROOTPATH = getAbsPath('..\DATA\MAT DATA\temp');
DATAPATHsC = dir(fullfile(ROOTPATH, '**\active1\chMeanC.mat'));
DATAPATHsC = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHsC, "UniformOutput", false);
DATAPATHsW = dir(fullfile(ROOTPATH, '**\active1\chMeanW.mat'));
DATAPATHsW = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHsW, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHsC, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'active1\chMeanC.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

FIGUREPATH = getAbsPath("..\Figures\healthy\population\Ratio No-Gapped Attentive (Independent)");

%% Params
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

interval = 0;
run(fullfile(pwd, "config\plotConfig.m"));
run(fullfile(pwd, "config\avgConfig_Neuroscan64.m"));
EEGPos = EEGPos_Neuroscan64;

windowChange = [1136, 1186];

alphaVal = 0.05;

%% Load
window = load(DATAPATHsC{1}).window;
fs = load(DATAPATHsC{1}).fs;
dataC = cellfun(@(x) load(x).chData, DATAPATHsC, "UniformOutput", false);
dataW = cellfun(@(x) load(x).chData, DATAPATHsW, "UniformOutput", false);

%% behavior
DATAPATHs = dir(fullfile(ROOTPATH, '**\active1\behavior.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);
dataBehavior = cellfun(@(x) load(x), DATAPATHs);
ratio = zeros(length(dataBehavior), 1);
for index = 1:length(dataBehavior)
    temp = dataBehavior(index).behaviorRes;
    % idx = [temp.ICI] == 4 & [temp.type] == "IRREG";
    idx = [temp.ICI] == 4.01 & [temp.type] == "REG";
    ratio(index) = temp(idx).nDiff / temp(idx).nTotal;
end

idx = ratio >= 0.3 & ratio <= 0.7;
dataC = dataC(idx);
dataW = dataW(idx);

%% REG
temp1 = cellfun(@(x) x([x.ICI] == 4.01 & [x.type] == "REG").chMean, dataC, "UniformOutput", false);
chMeanC = calchMean(temp1);
temp2 = cellfun(@(x) x([x.ICI] == 4.01 & [x.type] == "REG").chMean, dataW, "UniformOutput", false);
chMeanW = calchMean(temp2);

chData(1).chMean = chMeanC;
chData(1).color = "r";
chData(2).chMean = chMeanW;
chData(2).color = "k";
plotRawWaveMultiEEG(chData, window, [], EEGPos);
addLines2Axes(struct("X", {0; 1000; 2000}, "color", [255 128 0] / 255, "width", 1.5));
scaleAxes("x", [900, 1500]);
scaleAxes("y", "on", "symOpt", "max");

rms = path2func(fullfile(matlabroot, 'toolbox/matlab/datafun/rms.m'));
indexC = cellfun(@(x, y) mean(x, 2) - mean(y, 2), cutData(temp1, window, windowChange), cutData(temp1, window, windowBase), "UniformOutput", false);
indexW = cellfun(@(x, y) mean(x, 2) - mean(y, 2), cutData(temp2, window, windowChange), cutData(temp2, window, windowBase), "UniformOutput", false);

indexC = changeCellRowNum(indexC);
indexW = changeCellRowNum(indexW);

[p, ~, stats] = cellfun(@(x, y) ranksum(x, y), indexW, indexC);

%% 
[~, ~, Th, Rd, ~] = readlocs(EEGPos.locs);
Th = pi / 180 * Th; % convert degrees to radians
[XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates
channels = 1:length(EEGPos.locs);

% flip
X = zeros(length(channels), 1);
Y = zeros(length(channels), 1);
idx = ~ismember(channels, chsIgnore);
X(idx) = mapminmax(YTemp(idx), 0.25, 0.75);
Y(idx) = mapminmax(XTemp(idx), 0.05, 0.92);
dX = 0.03;
dY = 0.03;

figure;
for chNum = 1:length(channels)

    if ismember(chNum, chsIgnore)
        continue;
    end

    ax = axes('Position', [X(chNum) - dX / 2, Y(chNum) - dY / 2, dX, 2 * dY]);
    if p(chNum) < alphaVal
        scatter(indexW{chNum}, indexC{chNum}, 16, "black", "filled");
        ax.XAxis.LineWidth = 2;
        ax.YAxis.LineWidth = 2;
        ax.Box = "on";
    else
        scatter(indexW{chNum}, indexC{chNum}, 16, "black", "filled");
    end
    title(EEGPos.channelNames{chNum});
    xticklabels('');
    yticklabels('');
    set(gca, "TickLength", [0, 0]);
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    syncXY;
    xyRange = get(gca, "XLim");
    dXYRange = diff(xyRange);
    set(gca, "XLim", [xyRange(1) - 0.2 * dXYRange, xyRange(2) + 0.2 * dXYRange]);
    set(gca, "YLim", [xyRange(1) - 0.2 * dXYRange, xyRange(2) + 0.2 * dXYRange]);
    addLines2Axes(gca);
    title(EEGPos.channelNames{chNum}, "FontSize", 10);
end

mSubplot(3, 4, 4, "shape", "square-min");
chs2Plot = channels(~ismember(channels, chsIgnore));
params0 = [{'plotchans'}, {chs2Plot}                    , ... % indices of channels to plot
           {'plotrad'  }, {0.36}                        , ... % plot radius
           {'headrad'  }, {max([EEGPos.locs(chs2Plot).radius])}, ... % head radius
           {'intrad'   }, {0.4}                         , ... % interpolate radius
           {'conv'     }, {'on'}                        , ... % plot radius just covers maximum channel radius
           {'colormap' }, {'jet'}                       , ...
           {'emarker'  }, {{'o', 'k', 4, 1}}          ];    % {MarkerType, Color, Size, LineWidth}
params = [params0, ...
          {'emarker2'}, {{find(ismember(chs2Plot, channels(p < alphaVal))), '.', 'k', 15, 1}}]; % {Channels, MarkerType, Color, Size, LineWidth}
topoplot(cellfun(@(x, y) mean(x - y), indexC, indexW), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 10;
cb.FontWeight = "bold";
print(gcf, "D:\Education\Lab\Projects\EEG\Figures\healthy\population\Ratio No-Gapped Attentive (Independent)\Behavior 4-4.01 correct vs wrong.jpg", ...
      "-djpeg", "-r1200");

%% 
% CH53 - PO7
figure;
mSubplot(1, 2, 1, "shape", "square-min");
hold on;
t = linspace(window(1) - 1004, window(2) - 1004, size(chMeanC, 2));
plot(t, mean(chMeanC(chs2Avg, :), 1), "Color", [1, 0.5, 0.5], "LineWidth", 2, "DisplayName", "correct (average across channels)");
plot(t, mean(chMeanW(chs2Avg, :), 1), "Color", [0.5, 0.5, 0.5], "LineWidth", 2, "DisplayName", "wrong (average across channels)");
h = xline([-1000, 0, 1000], "LineWidth", 2, "Color", [1, 0.5, 0], "LineStyle", "--");
setLegendOff(h);
legend;
xlim([-300, 500]);
xlabel("Time (ms)");
ylabel("Response (\muV)");
title("Reg_{4-4.01}");

mSubplot(1, 2, 2, "shape", "square-min");
hold on;
t = linspace(window(1) - 1004, window(2) - 1004, size(chMeanC, 2));
plot(t, chMeanC(53, :), "Color", "r", "LineWidth", 2, "DisplayName", "correct");
plot(t, chMeanW(53, :), "Color", "k", "LineWidth", 2, "DisplayName", "wrong");
h = xline([-1000, 0, 1000], "LineWidth", 2, "Color", [1, 0.5, 0], "LineStyle", "--");
setLegendOff(h);
legend;
xlim([-300, 500]);
xlabel("Time (ms)");
ylabel("Response (\muV)");
title("Reg_{4-4.01} | PO7");