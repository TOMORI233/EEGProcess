clear; clc;
nRepeat = 5;

%% important parameters
% basic
opts.fs = 48e3;
opts.rootPath = '..\..\sounds';
mkdir(opts.rootPath);

% for continuous / seperated
s1ICI = 4; % ms
s2ICI = [4 4.04]';
singleDuration = 1000; % ms

amp = 0.5;
ampNorm = normalizeClickTrainSPL(repmat(s1ICI, length(s2ICI), 1), s2ICI, amp, 1);
ampSqrt = normalizeClickTrainSPL(repmat(s1ICI, length(s2ICI), 1), s2ICI, amp, 2);

%% generate single click
opts.Amp = 1;
opts.riseFallTime = 0; % ms
opts.clickDur = 0.2 ; % ms
click = generateClick(opts);

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

longTermRegWaveContinuous0 = mergeSingleWave(s1RegWave, s2RegWave, 0, opts, 1);
% longTermRegWaveContinuous0.s1s2 = cellfun(@(x, y) x * y, {longTermRegWaveContinuous0.s1s2}', num2cell(ampNorm), "UniformOutput", false);
longTermRegWaveContinuous = mergeSingleWave({longTermRegWaveContinuous0.s1s2}', {longTermRegWaveContinuous0.s1s2}', 0, opts, 1);
for index = 1:nRepeat - 2
    longTermRegWaveContinuous = mergeSingleWave({longTermRegWaveContinuous.s1s2}', {longTermRegWaveContinuous0.s1s2}', 0, opts, 1);
end

% save continuous regular long term click train
opts.ICIName = s2ICI; 
opts.folderName = 'continuous';
opts.fileNameTemp = '[s2ICI]_Reg.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({longTermRegWaveContinuous.s1s2}, opts)

% generate irregular click train
opts.baseICI =  4; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara

for index = 1:nRepeat
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
    [sound1, ~, ~] = repIrregByReg(s1IrregSampNHeadRep, s1IrregRepN, opts);
    [sound2, ~, ~] = repIrregByReg(s2IrregSampNHeadRep, s2IrregRepN, opts);
    [s1IrregWaveTailRep, ~, s1IrregSampNTailRep] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
    [s2IrregWaveTailRep, ~, s2IrregSampNTailRep] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);
    
    if index == 1
        mSound = mergeSingleWave(s1IrregWaveTailRep, sound2, 0, opts);
    elseif index == nRepeat
        mSoundTail = mergeSingleWave(sound1, s2IrregWaveHeadRep, 0, opts);
        mSound = mergeSingleWave({mSound.s1s2}', {mSoundTail.s1s2}', 0, opts);
    else
        mSoundBody = mergeSingleWave(sound1, sound2, 0, opts);
        mSound = mergeSingleWave({mSound.s1s2}', {mSoundBody.s1s2}', 0, opts);
    end

end

% save continuous irregular long term click train
opts.ICIName = s2ICI; 
opts.folderName = 'continuous';
opts.fileNameTemp = '[s2ICI]_Irreg.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({mSound.s1s2}, opts)