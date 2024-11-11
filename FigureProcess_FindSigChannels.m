ccc;

% MATPATHs = dir("..\DATA\MAT DATA - coma\pre\**\151\data.mat");
% MATPATHs = dir("..\DATA\MAT DATA - extra\pre\**\113\data.mat");
% MATPATHs = dir("..\DATA\MAT DATA\pre\**\passive3\data.mat");
MATPATHs = dir("..\DATA\MAT DATA\temp\**\passive3\chMean.mat");
MATPATHs = arrayfun(@(x) fullfile(x.folder, x.name), MATPATHs, "UniformOutput", false);
MATPATHs(contains(MATPATHs, "2024032901")) = [];
[~, temp] = cellfun(@(x) getLastDirPath(x, 2), MATPATHs, "UniformOutput", false);
subjectIDs = cellfun(@(x) x{1}, temp, "UniformOutput", false);

EEGPos = EEGPos_Neuroscan64;
chsIgnore = [33, 43, 60, 64];
channels = 1:length(EEGPos.locs);

%% 
% for mIndex = 1:length(MATPATHs)
%     load(MATPATHs{mIndex});
% 
%     % reference
%     trialsEEG = cellfun(@(x) x - mean(x, 1), trialsEEG, "UniformOutput", false);
% 
%     chMean = calchMean(trialsEEG([trialAll.type] == "REG"));
%     chErr = calchStd(trialsEEG([trialAll.type] == "REG"));
%     plotRawWaveEEG(chMean, chErr, window, [], EEGPos);
%     addLines2Axes(struct("X", 0));
%     scaleAxes("x", [-500, 500]);
% end

%% 
windowBase0  = [-500, -300];
windowOnset  = [50, 250];
windowBase   = [800, 1000];
windowChange = [1080, 1280];

rms = path2func(fullfile(matlabroot, "toolbox/matlab/datafun/rms.m"));

alphaVal = 0.05;

%% 
window = load(MATPATHs{1}).window;
fs = load(MATPATHs{1}).fs;
data = cellfun(@(x) load(x).chData, MATPATHs, "UniformOutput", false);

%% 
temp = cellfun(@(x) mean(cat(3, x([x.type] == "PT").chMean), 3), data, "UniformOutput", false);
RM_base0 = cellfun(@(x) rms(x, 2), cutData(temp, window, windowBase0), "UniformOutput", false);
RM_onset = cellfun(@(x) rms(x, 2), cutData(temp, window, windowOnset), "UniformOutput", false);

temp = cellfun(@(x) mean(cat(3, x([x.type] == "PT" & [x.freq] ~= 250).chMean), 3), data, "UniformOutput", false);
RM_base   = cellfun(@(x) rms(x, 2), cutData(temp, window, windowBase), "UniformOutput", false);
RM_change = cellfun(@(x) rms(x, 2), cutData(temp, window, windowChange), "UniformOutput", false);

RM_base0  = changeCellRowNum(RM_base0);
RM_onset  = changeCellRowNum(RM_onset);
RM_base   = changeCellRowNum(RM_base);
RM_change = changeCellRowNum(RM_change);

p_onset = cellfun(@(x, y) signrank(x, y), RM_base0, RM_onset);
p_change = cellfun(@(x, y) signrank(x, y), RM_base, RM_change);

figure;
mSubplot(1, 2, 1, "shape", "square-min");
chs2Plot = channels(~ismember(channels, chsIgnore));
params0 = [{'plotchans'}, {chs2Plot}                    , ... % indices of channels to plot
           {'plotrad'  }, {0.36}                        , ... % plot radius
           {'headrad'  }, {max([EEGPos.locs(chs2Plot).radius])}, ... % head radius
           {'intrad'   }, {0.4}                         , ... % interpolate radius
           {'conv'     }, {'on'}                        , ... % plot radius just covers maximum channel radius
           {'colormap' }, {'jet'}                       , ...
           {'emarker'  }, {{'o', 'k', 8, 1}}          ];    % {MarkerType, Color, Size, LineWidth}
params = [params0, ...
          {'emarker2'}, {{find(ismember(chs2Plot, channels(p_onset < alphaVal))), '.', 'k', 30, 1}}]; % {Channels, MarkerType, Color, Size, LineWidth}
topoplot(cellfun(@(x, y) mean(x - y), RM_onset, RM_base0), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 10;
cb.FontWeight = "bold";

mSubplot(1, 2, 2, "shape", "square-min");
params = [params0, ...
          {'emarker2'}, {{find(ismember(chs2Plot, channels(p_change < alphaVal))), '.', 'k', 30, 1}}]; % {Channels, MarkerType, Color, Size, LineWidth}
topoplot(cellfun(@(x, y) mean(x - y), RM_change, RM_base), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 10;
cb.FontWeight = "bold";

%% 
[~, ~, Th, Rd, ~] = readlocs(EEGPos.locs);
Th = pi / 180 * Th; % convert degrees to radians
[XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates

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
    if p_onset(chNum) < alphaVal
        scatter(RM_base0{chNum}, RM_onset{chNum}, 16, "black", "filled");
        % ax.XAxis.LineWidth = 2;
        % ax.YAxis.LineWidth = 2;
        % ax.Box = "on";
        set(gca, "Color", [.85, .85, .85]);
    else
        scatter(RM_base0{chNum}, RM_onset{chNum}, 16, "black", "filled");
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
          {'emarker2'}, {{find(ismember(chs2Plot, channels(p_onset < alphaVal))), '.', 'k', 15, 1}}]; % {Channels, MarkerType, Color, Size, LineWidth}
topoplot(cellfun(@(x, y) mean(x - y), RM_onset, RM_base0), EEGPos.locs, params{:});
cb = colorbar;
cb.FontSize = 10;
cb.FontWeight = "bold";

%% 
% for sIndex = 1:length(MATPATHs)
%     load(MATPATHs{sIndex});
%     trialsEEG = trialsEEG([trialAll.type] == "REG");
%     trialsEEG = cat(3, trialsEEG{:}); % chan_sample_trial
%     t = linspace(window(1), window(2), size(trialsEEG, 2));
%     tIdxBase = t >= windowBase(1) & t <= windowBase(2);
%     tIdxOnset = t >= windowOnset(1) & t <= windowOnset(2);
%     RM_base = squeeze(rms(trialsEEG(:, tIdxBase, :), 2)); % chan_trial
%     RM_onset = squeeze(rms(trialsEEG(:, tIdxOnset, :), 2));
%     [~, p] = rowFcn(@(x, y) ttest(x, y, "Tail", "right"), RM_base, RM_onset);
% end