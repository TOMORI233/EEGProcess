clear; clc;

fs = 48e3; % Hz
clickDur = 2e-4; % sec
click = genClick(clickDur, fs);

clickTrainDur = 1; % sec
ICI = 4e-3; % sec
rfTime = 5e-3; % sec
clickTrainReg = genRegClickTrain(click, clickTrainDur, ICI, fs);
clickTrainReg = genRiseFallEdge(clickTrainReg, fs, rfTime);

% clickTrainIrreg = genIrregClickTrain(click, clickTrainDur, ICI, fs);

playAudio(clickTrainReg, fs);

figure;
plot(clickTrainReg);