clear; clc; close all;

%% Active 1
DATAPATH = "D:\Education\Lab\Projects\EEG\MAT Population\Behavior_A1_Res_Population.mat";
load(DATAPATH);
data = [data.behaviorRes]';

figure;
maximizeFig;

% REG
temp = [data([data.type] == "REG").data]';
ICIsREG = unique([temp.ICI])';
resREG_A1 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(2, 2, 1, 'shape', 'square-min');
for index = 1:length(resREG_A1)
    plot(resREG_A1{index}, 'r');
    hold on;
end
xticks(1:length(ICIsREG));
xticklabels(num2str(ICIsREG));
xlabel('ICI2');
ylabel('Press for difference ratio');

% IRREG
temp = [data([data.type] == "IRREG").data]';
ICIsIRREG = unique([temp.ICI])';
resIRREG_A1 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(2, 2, 2, 'shape', 'square-min');
for index = 1:length(resIRREG_A1)
    plot(resIRREG_A1{index}, 'b');
    hold on;
end
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG));
xlabel('ICI2');
ylabel('Press for difference ratio');

% PT
temp = [data([data.type] == "PT").data]';
freqs = unique([temp.freq])';
resPT_A1 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(2, 2, 3, 'shape', 'square-min');
for index = 1:length(resPT_A1)
    plot(resPT_A1{index}, 'g');
    hold on;
end
xticks(1:length(freqs));
xticklabels(num2str(freqs));
xlabel('frequency2');
ylabel('Press for difference ratio');

%% Active 2
DATAPATH = "D:\Education\Lab\Projects\EEG\MAT Population\Behavior_A2_Res_Population.mat";
load(DATAPATH);
data = [data.behaviorRes]';

figure;
maximizeFig;

% REG
temp = [data([data.type] == "REG").data]';
resREG_A2 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(1, 2, 1, 'shape', 'square-min');
for index = 1:length(resREG_A2)
    plot(resREG_A2{index}, 'r');
    hold on;
end
xticks(1:length(ICIsREG));
xticklabels(num2str(ICIsREG));
xlabel('ICI2');
ylabel('Press for difference ratio');

% IRREG
temp = [data([data.type] == "IRREG").data]';
resIRREG_A2 = arrayfun(@(x) x.nDiff ./ x.nTotal, temp, "UniformOutput", false);

mSubplot(1, 2, 2, 'shape', 'square-min');
for index = 1:length(resIRREG_A2)
    plot(resIRREG_A2{index}, 'b');
    hold on;
end
xticks(1:length(ICIsIRREG));
xticklabels(num2str(ICIsIRREG));
xlabel('ICI2');
ylabel('Press for difference ratio');

%% Compare
% REG
figure;
maximizeFig;
for index = 1:5
    mSubplot(2, 3, index, 'shape', 'square-min');
    X = cellfun(@(x) x(index), resREG_A1);
    Y = cellfun(@(x) x(index), resREG_A2);
    [~, p] = ttest(X, Y);
    scatter(X, Y, 100, "k");
    hold on;
    plot([0, 1], [0, 1], 'k--', 'LineWidth', 1.5);
    title(['REG | ICI2 = ', num2str(ICIsREG(index)), ' ms | p=', num2str(p)]);
end

% IRREG
figure;
maximizeFig;
for index = 1:3
    mSubplot(1, 3, index, 'shape', 'square-min');
    X = cellfun(@(x) x(index), resIRREG_A1([1:2, 4:end]));
    Y = cellfun(@(x) x(index), resIRREG_A2([1:2, 4:end]));
    [~, p] = ttest(X, Y);
    scatter(X, Y, 100, "k");
    hold on;
    plot([0, 1], [0, 1], 'k--', 'LineWidth', 1.5);
    title(['IRREG | ICI2 = ', num2str(ICIsIRREG(index)), ' ms | p=', num2str(p)]);
end