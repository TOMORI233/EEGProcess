clear all; clc

%% important parameters
% basic
opts.fs = 384e3;
opts.rootPath = '..\sounds';
mkdir(opts.rootPath);

% for decode
decodeICI = [2 3 4 5 6 7 8];
decodeDuration = 1000; % ms

% for continuous / seperated
s1ICI = 8; % ms, 8-8.12, 16-16.24, 32-32.48
s2ICI = 8.12;
singleDuration = 1000; % ms
interval = 600; % ms

%% generate single click
opts.Amp = 1;
opts.riseFallTime = 0; % ms
opts.clickDur = 0.2 ; % ms
click = generateClick(opts);

%% for single click train
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = decodeDuration; % ms, sound length, composed of N single trains
opts.ICIs = decodeICI; % ms

% generate regular click train
[singleRegWave, regDur] = generateRegClickTrain(opts);

%% for click train long term
opts.repN = 3; % 
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = singleDuration; % ms, sound length, composed of N single trains
opts.ICIs = [s1ICI; s2ICI]; % ms

% generate regular long term click train
[RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts);
s1RegWave = repmat(RegWave(1), length(RegWave) - 1, 1);
s2RegWave = RegWave(2:end, 1);
longTermRegWaveContinuous = mergeSingleWave(s1RegWave, s2RegWave, 0, opts, 1);
longTermRegWaveSepatated = mergeSingleWave(s1RegWave, s2RegWave, interval, opts, 1); % interval unit: ms

% save continuous regular long term click train
opts.ICIName = s2ICI; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_Reg.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)


% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregLongTermSampN = opts.irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = repmat(irregSampN(1), length(irregSampN) - 1, 1);
s1IrregRepN = regClickTrainSampN(2 : end);

s2IrregSampN = irregSampN(2 : end);
s2IrregRepN = repmat(regClickTrainSampN(1), length(regClickTrainSampN) - 1, 1);



opts.pos = 'head';
[s1IrregWaveHeadRep, ~, s1IrregSampNHeadRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveHeadRep, ~, s2IrregSampNHeadRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);

opts.pos = 'tail';
[s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveTailRep, ~, s2IrregSampNTailRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);


longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, 0, opts);
longTermIrregWaveStdDevSeperated = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, interval, opts);

% longTermIrregWaveDevStd = mergeSingleWave(s2IrregWaveTailRep, s1IrregWaveHeadRep, opts);


% save continuous irregular long term click train
opts.ICIName = s2ICI; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_Irreg.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)

