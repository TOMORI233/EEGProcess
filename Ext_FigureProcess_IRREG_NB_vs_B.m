ccc;

%% Path
cd(fileparts(mfilename("fullpath")));

%% Params
nperm = 1e3;
alphaVal = 0.05;

interval = 0;
run(fullfile(pwd, "config\config_plot.m"));
run(fullfile(pwd, "config\config_Neuroscan64.m"));

chIdx = ~ismember(EEGPos.channels, EEGPos.ignore);

%% Load
dataA = load(['..\DATA\MAT DATA\figure\Res A1 (', char(area), ').mat']);
dataP = load(['..\DATA\MAT DATA\figure\Res P3 (', char(area), ') - Compare with A1.mat']);
load("..\DATA\MAT DATA\figure\subjectIdx_A1.mat", "resIRREG_A1", "subjectIdxA1");

window = dataA.window;

%% Statistics
try
    load("stat_IRREG_NB_vs_B.mat", "statPerm");
catch ME
    cfg = [];
    cfg.minnbchan = 1;
    cfg.neighbours = EEGPos.neighbours;
    temp1 = cellfun(@(x) insertRows(x(chIdx, :), EEGPos.ignore, 0), dataA.dataIRREG_control, "UniformOutput", false);
    temp2 = cellfun(@(x) insertRows(x(chIdx, :), EEGPos.ignore, 0), dataP.dataIRREG_control, "UniformOutput", false);
    statPerm = CBPT(cfg, temp1, temp2);
    save("stat_IRREG_NB_vs_B.mat", "statPerm");
end

%% Plot raw wave
chData(1) = dataA.chDataIRREG_All(1);
chData(1).color = "r";
chData(1).legend = "Behavioral";
chData(2) = dataP.chDataIRREG_All(1);
chData(2).color = "k";
chData(2).legend = "Non-behavioral";

t = linspace(window(1), window(2), size(chData(1).chMean, 2));

plotRawWaveMulti(chData, window);
scaleAxes("x", [800, 1600]);
scaleAxes("y", "on", "autoTh", [0, 1]);
addLines2Axes(struct("X", {0; 1000; 2000}));

plotRawWaveMultiEEG(chData, window, [], EEGPos);
axPerm = mSubplot(4, 4, 4, "shape", "square-min");
imagesc("XData", t, "YData", EEGPos.channels, "CData", abs(statPerm.stat));
set(gca, "XLimitMethod", "tight");
set(gca, "YLimitMethod", "tight");
colormap(slanCM('YlOrRd'));
mColorbar("Interval", -0.05);
scaleAxes("x", [800, 1600]);
scaleAxes(axPerm, "c", [0, inf]);
addLines2Axes(struct("X", {0; 1000; 2000}));

%% RM
X = dataP.RM_changeIRREG{1}; % Non-behavioral (NB)
Y = dataA.RM_changeIRREG{1}; % Behavioral (B)

th = cellfun(@(x) x(1), resIRREG_A1(subjectIdxA1)); % Behavioral threshold (th)
idx1 = th >= 0.6;
idx2 = th < 0.6;
p0 = mstat.signrank(X, Y); % NB vs B (n.s.)
p1 = mstat.signrank(X(idx1), Y(idx1)); % th>=0.6: NB vs B (*)
p2 = mstat.signrank(X(idx2), Y(idx2)); % th<0.6: NB vs B (n.s.)
p3 = mstat.ranksum(X(idx1), X(idx2)); % NB: RM(th>=0.6) vs RM(th<0.6) (*)
p4 = mstat.ranksum(Y(idx1), Y(idx2)); % B: RM(th>=0.6) vs RM(th<0.6) (n.s.)

a_fit = polyfit(th, Y - X, 1);
[rho, p_corr] = corr(th, (Y - X)', "Type", "Spearman");
a_fit1 = polyfit(th(idx1), Y(idx1) - X(idx1), 1);
[rho1, p_corr1] = corr(th(idx1), (Y(idx1) - X(idx1))', "Type", "Spearman");
a_fit2 = polyfit(th(idx2), Y(idx2) - X(idx2), 1);
[rho2, p_corr2] = corr(th(idx2), (Y(idx2) - X(idx2))', "Type", "Spearman");

figure;
mSubplot(1, 2, 1, "shape", "square-min");
scatter(X(idx1), Y(idx1), 80, "blue", "filled", "DisplayName", ['\geq 0.6 (p = ', num2str(p1), ')']);
hold on;
scatter(X(idx2), Y(idx2), 80, "red", "filled", "DisplayName", ['< 0.6 (p = ', num2str(p2), ')']);
legend("Location", "best");
xlabel("RM_{Non-behavioral}");
ylabel("RM_{Behavioral}");
syncXY;
addLines2Axes(gca);
mSubplot(1, 2, 1, "nSize", [0.3, 0.25], "alignment", "left-top");
boxplotGroup({[X(idx1)', Y(idx1)'], [X(idx2)', Y(idx2)']}, ...
             "GroupLines", true, ...
             "Notch", "on", ...
             "PrimaryLabels", {'NB', 'B'}, ...
             "Symbol", '+', ...
             "SecondaryLabels", {'\geq 0.6', '< 0.6'}, ...
             "Colors", [0, 0, 0; validatecolor('#008000')], 'GroupType', 'BetweenGroups');

mSubplot(1, 2, 2, "shape", "square-min");
hold on;
l = yline(0, "LineWidth", 1, "LineStyle", "--", "Color", "k");
setLegendOff(l);
plot([0, 1], polyval(a_fit, [0, 1]), "Color", [0.5, 0.5, 0.5], "LineWidth", 2, "DisplayName", ['r = ', num2str(rho), ', p = ', num2str(p_corr)]);
plot([0.6, 1], polyval(a_fit1, [0.6, 1]), "Color", "b", "LineWidth", 2, "DisplayName", ['r = ', num2str(rho1), ', p = ', num2str(p_corr1)]);
plot([0, 0.6], polyval(a_fit2, [0, 0.6]), "Color", "r", "LineWidth", 2, "DisplayName", ['r = ', num2str(rho2), ', p = ', num2str(p_corr2)]);
scatter(th(idx1), Y(idx1) - X(idx1), 80, "blue", "filled", "DisplayName", '\geq 0.6');
scatter(th(idx2), Y(idx2) - X(idx2), 80, "red", "filled", "DisplayName", '< 0.6');
legend("Location", "best");
xlabel("Ratio of change detection");
ylabel("RM_{Behavioral} - RM_{Non-behavioral}");

%% Topo
val1 = dataA.RM_channels_delta_changeIRREG{1};
val2 = dataP.RM_channels_delta_changeIRREG{1};
p_topo = rowFcn(@mstat.signrank, val1, val2, "ErrorHandler", @mErrorFcn);
[~, ~, ~, p_topo(chIdx)] = fdr_bh(p_topo(chIdx), alphaVal, 'pdep');

figure;
mSubplot(1, 3, 1);
params = topoplotConfig(EEGPos, [], 0, 30);
topoplot(mean(val1, 2), EEGPos.locs, params{:});
title("Behavioral");

mSubplot(1, 3, 2);
params = topoplotConfig(EEGPos, [], 0, 30);
topoplot(mean(val2, 2), EEGPos.locs, params{:});
title("Non-behavioral");

mSubplot(1, 3, 3);
params = topoplotConfig(EEGPos, find(p_topo < alphaVal), 0, 30);
topoplot(mean(val1 - val2, 2), EEGPos.locs, params{:});
title("Diff");
mColorbar("Width", 0.03);

scaleAxes("c", "ignoreInvisible", false);