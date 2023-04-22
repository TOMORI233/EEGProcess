clear; clc; close all force;

margins = [0.05, 0.05, 0.1, 0.05];

%% Active 1
DATAPATH = "D:\Education\Lab\Projects\EEG\MAT Population\Behavior_A1_Res_Population.mat";
load(DATAPATH);
bData = [data.behaviorRes]';

% REG
temp = [bData([bData.type] == "REG").data]';
ICIsREG = unique([temp.ICI])';
resREG_A1 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

% Reject subjects with bad behavior
subjectIdx = cellfun(@(x) x(1) < 0.3 && x(end) > 0.3, resREG_A1);
save("subjectIdx_A1.mat", "subjectIdx");

bData = [data(subjectIdx).behaviorRes]';
resREG_A1 = resREG_A1(subjectIdx);

[xData, yData] = prepareCurveData(ICIsREG, mean(cell2mat(resREG_A1)));
y = 0;
while y(end) - y(1) < 0.5
    ft = fittype('a/(1+exp(-b*(x-c)))', 'independent', 'x', 'dependent', 'y');
    [fitresult, gof] = fit(xData, yData, ft);
    x = linspace(ICIsREG(1), ICIsREG(end), 1000)';
    a = fitresult.a;
    b = fitresult.b;
    c = fitresult.c;
    y = a ./ (1 + exp(-b * (x - c)));
    resultREG_A1 = [x, y];
end

figure;
maximizeFig;
mSubplot(2, 3, 1, 'shape', 'square-min', "margins", margins);
for index = 1:length(resREG_A1)
    plot(ICIsREG, resREG_A1{index}, 'Color', [255 192 203] / 255);
    hold on;
end
plot(x, y, 'Color', 'r', 'LineWidth', 2);
xticks(ICIsREG);
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title('A1 REG');

% IRREG
temp = [bData([bData.type] == "IRREG").data]';
ICIsIRREG = unique([temp.ICI])';
resIRREG_A1 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(2, 3, 2, 'shape', 'square-min', "margins", margins);
for index = 1:length(resIRREG_A1)
    plot(resIRREG_A1{index}, 'Color', [135 206 235] / 255);
    hold on;
end
errorbar(1:length(ICIsIRREG), mean(cell2mat(resIRREG_A1), 1), SE(cell2mat(resIRREG_A1), 1), 'Color', 'b', 'LineWidth', 2);
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG));
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title('A1 IRREG');

% PT
temp = [bData([bData.type] == "PT").data]';
freqs = unique([temp.freq])';
resPT_A1 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(2, 3, 3, 'shape', 'square-min', "margins", margins);
for index = 1:length(resPT_A1)
    plot(resPT_A1{index}, 'Color', [189 252 201] / 255);
    hold on;
end
errorbar(1:length(freqs), mean(cell2mat(resPT_A1), 1), SE(cell2mat(resPT_A1), 1), 'Color', 'g', 'LineWidth', 2);
xticks(1:length(freqs));
xticklabels(num2str(freqs));
xlabel('S2 Frequency (Hz)');
ylabel('Press for difference ratio');
title('A1 Tone');

%% Active 2
DATAPATH = "D:\Education\Lab\Projects\EEG\MAT Population\Behavior_A2_Res_Population.mat";
load(DATAPATH);
bData = [data.behaviorRes]';

% REG
temp = [bData([bData.type] == "REG").data]';
resREG_A2 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

[xData, yData] = prepareCurveData(ICIsREG, mean(cell2mat(resREG_A2)));
y = 0;
while y(end) - y(1) < 0.5
    ft = fittype('a/(1+exp(-b*(x-c)))', 'independent', 'x', 'dependent', 'y');
    [fitresult, gof] = fit(xData, yData, ft);
    x = linspace(ICIsREG(1), ICIsREG(end), 1000)';
    a = fitresult.a;
    b = fitresult.b;
    c = fitresult.c;
    y = a ./ (1 + exp(-b * (x - c)));
    resultREG_A2 = [x, y];
end

mSubplot(2, 3, 4, 'shape', 'square-min', "margins", margins);
for index = 1:length(resREG_A2)
    plot(ICIsREG, resREG_A2{index}, 'Color', [255 192 203] / 255);
    hold on;
end
plot(x, y, 'Color', 'r', 'LineWidth', 2);
xticks(ICIsREG);
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title('A2 REG');

% IRREG
temp = [bData([bData.type] == "IRREG").data]';
resIRREG_A2 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(2, 3, 5, 'shape', 'square-min', "margins", margins);
for index = 1:length(resIRREG_A2)
    plot(resIRREG_A2{index}, 'Color', [135 206 235] / 255);
    hold on;
end
% idx=3 subject A2 ICI2=8 data missing
temp1 = cell2mat(cellfun(@(x) x(1:2), resIRREG_A2, "UniformOutput", false));
temp2 = cell2mat(cellfun(@(x) x(3), resIRREG_A2([1:2, 4:end]), "UniformOutput", false));
errorbar(1:length(ICIsIRREG), [mean(temp1, 1), mean(temp2, 1)], [SE(temp1, 1), SE(temp2, 1)], 'Color', 'b', 'LineWidth', 2);
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG));
xlabel('S2 ICI (ms)');
ylabel('Press for difference ratio');
title('A2 IRREG');

%% Compare
% REG
figure;
maximizeFig;
for index = 1:5
    mSubplot(2, 3, index, 'shape', 'square-min', "margins", margins);
    X = cellfun(@(x) x(index), resREG_A1);
    Y = cellfun(@(x) x(index), resREG_A2(subjectIdx));
    [~, p] = ttest(X, Y);
    scatter(X, Y, 100, "k");
    hold on;
    plot([0, 1], [0, 1], 'k--', 'LineWidth', 1.5);
    xlabel('A1');
    ylabel('A2');
    title(['REG | ICI2 = ', num2str(ICIsREG(index)), ' ms | p=', num2str(p)]);
end

% IRREG
figure;
maximizeFig;
for index = 1:2
    mSubplot(1, 2, index, 'shape', 'square-min', "margins", margins);
    X = cellfun(@(x) x(index), resIRREG_A1);
    Y = cellfun(@(x) x(index), resIRREG_A2(subjectIdx));
    [~, p] = ttest(X, Y);
    scatter(X, Y, 100, "k");
    hold on;
    plot([0, 1], [0, 1], 'k--', 'LineWidth', 1.5);
    xlabel('A1');
    ylabel('A2');
    title(['IRREG | ICI2 = ', num2str(ICIsIRREG(index)), ' ms | p=', num2str(p)]);
end
