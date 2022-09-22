clear ; clc
nRepeat = 5;

%% important parameters
% basic
opts.fs = 48e3;
% opts.rootPath = fullfile('..\ratSounds', datestr(now, "yyyy-mm-dd"));
opts.rootPath = '..\..\..\sounds\';
mkdir(opts.rootPath);

% for continuous / seperated
% s1ICI = [4,    8,    20,   40,   80,   4, 4, 4,   4,   4,   4,   4,   3,   2.3]  ; % ms
% s2ICI = [4.06, 8.12, 20.3, 40.6, 81.2, 3, 5, 3.2, 3.4, 3.6, 3.8, 5.4, 2.3, 1.76];
% singleDuration = 5000; % ms
s1ICI = [4, 4,    4]  ; % ms
s2ICI = [4, 4.06, 4.2];
singleDuration = 1000; % ms
s2CutOff = []; % if empty, do not cut


%% generate single click
opts.Amp = 0.5;
opts.Amp1 = cellfun(@(x, y) normalizeClickTrainSPL(x, y, opts.Amp, 1), num2cell(s1ICI), num2cell(s2ICI), "UniformOutput", false);
opts.Amp2 = cellfun(@(x, y) normalizeClickTrainSPL(x, y, opts.Amp, 2), num2cell(s1ICI), num2cell(s2ICI), "UniformOutput", false);
opts.riseFallTime = 0; % ms
opts.clickDur = 0.2 ; % ms
click = generateClick(opts);

%% for click train long term
opts.repN = 3; % 
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = singleDuration; % ms, sound length, composed of N single trains
opts.ICIs = reshape([s1ICI; s2ICI], [], 1 ); % ms

%% regular
% generate regular long term click train
[RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts);
s1RegWave = RegWave(1 : 2 : end);
s2RegWave = RegWave(2 : 2 : end);
longTermRegWaveContinuous0 = mergeSingleWave(s1RegWave, s2RegWave, 0, opts, 1);
longTermRegWaveContinuous = mergeSingleWave({longTermRegWaveContinuous0.s1s2}', {longTermRegWaveContinuous0.s1s2}', 0, opts, 1);

for index = 1:nRepeat - 2
    longTermRegWaveContinuous = mergeSingleWave({longTermRegWaveContinuous.s1s2}', {longTermRegWaveContinuous0.s1s2}', 0, opts, 1);
end

% normalize S2 SPL to S1 SPL 
longTermRegWaveContinuousNorm1 = mergeSingleWave(s1RegWave, opts.Amp1' ./ opts.Amp * s2RegWave, 0, opts, 1, s2CutOff);
longTermRegWaveContinuousNorm2 = mergeSingleWave(s1RegWave, opts.Amp2' ./ opts.Amp * s2RegWave, 0, opts, 1, s2CutOff);

% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_RegStdDev.wav';
opts.fileNameRep = '[s2ICI]';
disp("exporting regular click train sounds...");
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)
opts.folderName = 'interval 0 Norm';
exportSoundFile({longTermRegWaveContinuousNorm1.s1s2}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm2.s1s2}, opts)

% save continuous regular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_RegDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s2s1}, opts)
opts.folderName = 'interval 0 Norm';
exportSoundFile({longTermRegWaveContinuousNorm1.s2s1}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermRegWaveContinuousNorm2.s2s1}, opts)

%%  irregular
% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara
opts.irregICISampNBase = cell2mat(irregICISampN(opts));
opts.irregLongTermSampN = opts.irregICISampNBase;
[~, ~, ~, irregSampN] = generateIrregClickTrain(opts);

s1IrregSampN = irregSampN(1 : 2 : end);
s1IrregRepN = regClickTrainSampN(2 : 2 : end);

s2IrregSampN = irregSampN(2 : 2 : end);
s2IrregRepN = regClickTrainSampN(1 : 2 : end);



opts.pos = 'head';
[s1IrregWaveHeadRep, ~, s1IrregSampNHeadRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveHeadRep, ~, s2IrregSampNHeadRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);

opts.pos = 'tail';
[s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
[s2IrregWaveTailRep, ~, s2IrregSampNTailRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);


longTermIrregWaveStdDevContinuous = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveStdDevSeperated = mergeSingleWave(s1IrregWaveTailRep, s2IrregWaveHeadRep, interval, opts, 0, s2CutOff);

longTermIrregWaveDevStdContinuous = mergeSingleWave(s2IrregWaveTailRep, s1IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveDevStdSeperated = mergeSingleWave(s2IrregWaveTailRep, s1IrregWaveHeadRep, interval, opts, 0, s2CutOff);

% normalize S2 SPL to S1 SPL 
longTermIrregWaveStdDevContinuousNorm1 = mergeSingleWave(s1IrregWaveTailRep, opts.Amp1' ./ opts.Amp * s2IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveStdDevSeperatedNorm1 = mergeSingleWave(s1IrregWaveTailRep, opts.Amp1' ./ opts.Amp * s2IrregWaveHeadRep, interval, opts, 0, s2CutOff);

longTermIrregWaveDevStdContinuousNorm1 = mergeSingleWave(s2IrregWaveTailRep, opts.Amp1' ./ opts.Amp * s1IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveDevStdSeperatedNorm1 = mergeSingleWave(s2IrregWaveTailRep, opts.Amp1' ./ opts.Amp * s1IrregWaveHeadRep, interval, opts, 0, s2CutOff);

longTermIrregWaveStdDevContinuousNorm2 = mergeSingleWave(s1IrregWaveTailRep, opts.Amp2' ./ opts.Amp * s2IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveStdDevSeperatedNorm2 = mergeSingleWave(s1IrregWaveTailRep, opts.Amp2' ./ opts.Amp * s2IrregWaveHeadRep, interval, opts, 0, s2CutOff);

longTermIrregWaveDevStdContinuousNorm2 = mergeSingleWave(s2IrregWaveTailRep, opts.Amp2' ./ opts.Amp * s1IrregWaveHeadRep, 0, opts, 0, s2CutOff);
longTermIrregWaveDevStdSeperatedNorm2 = mergeSingleWave(s2IrregWaveTailRep, opts.Amp2' ./ opts.Amp * s1IrregWaveHeadRep, interval, opts, 0, s2CutOff);


% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_IrregStdDev.wav';
opts.fileNameRep = '[s2ICI]';
disp("exporting irregular click train sounds...");
exportSoundFile({longTermIrregWaveStdDevContinuous.s1s2}, opts)
opts.folderName = 'interval 0 Norm';
exportSoundFile({longTermIrregWaveStdDevContinuousNorm1.s1s2}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermIrregWaveStdDevContinuousNorm2.s1s2}, opts)

% save continuous irregular long term click train
opts.ICIName = [s1ICI' s2ICI']; 
opts.folderName = 'interval 0';
opts.fileNameTemp = '[s2ICI]_IrregDevStd.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermIrregWaveDevStdContinuous.s1s2}, opts)
opts.folderName = 'interval 0 Norm';
exportSoundFile({longTermIrregWaveDevStdContinuousNorm1.s1s2}, opts)
opts.folderName = 'interval 0 Norm Sqrt';
exportSoundFile({longTermIrregWaveDevStdContinuousNorm2.s1s2}, opts)

%% wave length for alignment
regStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1RegWave, "UniformOutput", false);
regDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2RegWave, "UniformOutput", false);
irregStdDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s1IrregWaveTailRep, "UniformOutput", false);
irregDevDuration = cellfun(@(x) length(x) * 1000 / opts.fs, s2IrregWaveTailRep, "UniformOutput", false);
stimStr = cellfun(@(x) strjoin(x, "o"), array2VectorCell(string([s1ICI', s2ICI'])), "UniformOutput", false);
soundRealDuration = easyStruct(["stimStr", "regStdDuration", "regDevDuration", "irregStdDuration", "irregDevDuration"], ...
    [stimStr, regStdDuration, regDevDuration, irregStdDuration, irregDevDuration]);
opts.soundRealDuration = soundRealDuration;
opts.interval = interval;
opts.decodeDuration = decodeDuration;
opts.decodeICI = decodeICI;
opts.singleDuration = singleDuration;

save(fullfile(opts.rootPath, 'opts'), 'opts');

