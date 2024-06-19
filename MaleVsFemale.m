ccc;

% dataMale = load("male P3.mat");
% dataFemale = load("female P3.mat");

dataMale = load("male A1.mat");
dataFemale = load("female A1.mat");

close all;

%% 
ICIsREG = dataMale.ICIsREG;
t = dataMale.t;

%% Wave plot
figure;
for index = 1:length(ICIsREG)
    mSubplot(2, 3, index);
    hold on;
    plot(t, dataMale.chDataREG(index).chMean, "Color", "r", "LineWidth", 2, "DisplayName", ['Male (N=', num2str(length(dataMale.data)), ')']);
    plot(t, dataFemale.chDataREG(index).chMean, "Color", "b", "LineWidth", 2, "DisplayName", ['Female (N=', num2str(length(dataFemale.data)), ')']);
    if index == 1
        legend;
    end
    title(['REG 4-', num2str(ICIsREG(index))]);
end
scaleAxes("x", [-300, 2500]);
scaleAxes("y", "on", "symOpt", "max");
addLines2Axes(struct("X", {0; 1000; 2000}));

%% Tunning plot
FigTuning = figure;
mSubplot(1, 2, 1, "shape", "square-min");
hold on;
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, dataMale.RM_delta_changePeakREG), cellfun(@SE, dataMale.RM_delta_changePeakREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG (Male)");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, dataFemale.RM_delta_changePeakREG), cellfun(@SE, dataFemale.RM_delta_changePeakREG), "Color", "g", "LineWidth", 2, "DisplayName", "REG (Female)");
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, dataMale.RM_delta_changePeakIRREG), cellfun(@SE, dataMale.RM_delta_changePeakIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG (Male)");
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, dataFemale.RM_delta_changePeakIRREG), cellfun(@SE, dataFemale.RM_delta_changePeakIRREG), "Color", "k", "LineWidth", 2, "DisplayName", "IRREG (Female)");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change peak}");

mSubplot(1, 2, 2, "shape", "square-min");
hold on;
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, dataMale.RM_delta_changeTroughREG), cellfun(@SE, dataMale.RM_delta_changeTroughREG), "Color", "r", "LineWidth", 2, "DisplayName", "REG (Male)");
errorbar((1:length(ICIsREG)) - 0.05, cellfun(@mean, dataFemale.RM_delta_changeTroughREG), cellfun(@SE, dataFemale.RM_delta_changeTroughREG), "Color", "g", "LineWidth", 2, "DisplayName", "REG (Female)");
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, dataMale.RM_delta_changeTroughIRREG), cellfun(@SE, dataMale.RM_delta_changeTroughIRREG), "Color", "b", "LineWidth", 2, "DisplayName", "IRREG (Male)");
errorbar([1, length(ICIsREG)] + 0.05, cellfun(@mean, dataFemale.RM_delta_changeTroughIRREG), cellfun(@SE, dataFemale.RM_delta_changeTroughIRREG), "Color", "k", "LineWidth", 2, "DisplayName", "IRREG (Female)");
legend("Location", "northwest");
xticks(1:length(ICIsREG));
xlim([0, length(ICIsREG)] + 0.5);
xticklabels(num2str(ICIsREG));
xlabel("T2 ICI (ms)");
ylabel("\DeltaRM (\muV)");
title("Tuning of RM_{change trough}");
