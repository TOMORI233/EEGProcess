ccc;

ROOTPATH = '..\DATA\MAT DATA\temp';
DATAPATHs = dir(fullfile(ROOTPATH, '**\passive3\chMean.mat'));
DATAPATHs = arrayfun(@(x) fullfile(x.folder, x.name), DATAPATHs, "UniformOutput", false);

SUBJECTs = strrep(DATAPATHs, ROOTPATH, '');
SUBJECTs = strrep(SUBJECTs, 'passive3\chMean.mat', '');
SUBJECTs = strrep(SUBJECTs, '\', '');

window = load(DATAPATHs{1}).window;
data = cellfun(@(x) load(x).chData, DATAPATHs, "UniformOutput", false);

%%
chMeanAllREG = cellfun(@(x) {x([x.type] == "REG").chMean}', data, "UniformOutput", false);
chMean = cellfun(@(x) calchMean(x), chMeanAllREG, "UniformOutput", false);
chMean = mean(cell2mat(cellfun(@(x) mean(x, 1), chMean, "UniformOutput", false)), 1);

t = linspace(window(1), window(2), length(chMean));
[PKS, LOCS] = rowFcn(@(x) findpeaks(x, t), chMean, "UniformOutput", false);

figure;
maximizeFig;
plotSize = autoPlotSize(size(chMean, 1));
for cIndex = 1:length(PKS)
    mSubplot(plotSize(1), plotSize(2), cIndex);
    plot(t, chMean(cIndex, :), 'b', 'LineWidth', 2);
    hold on;
    scatter(LOCS{cIndex}, PKS{cIndex}, 50, 'red', 'filled');
end
scaleAxes("x", [0, 500]);
scaleAxes("y", "on", "symOpt", "max");
PKS = cellfun(@(x, y) x(y < 1000), PKS, LOCS, "UniformOutput", false);
LOCS = cellfun(@(x) x(x < 1000), LOCS, "UniformOutput", false);
peakTime = cellfun(@(x, y) y(obtainArgoutN(@max, 2, x)), PKS, LOCS); % ms
windowOnset = [-25, 25] + mode(peakTime); % ms
addLines2Axes(struct("X", {windowOnset(1); windowOnset(2)}));

save("windowOnset.mat", "windowOnset");
disp(['Peak at ', num2str(mode(peakTime)), ' ms']);
