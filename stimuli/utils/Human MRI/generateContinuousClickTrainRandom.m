clear; clc;
durTotal = 10; % sec
NTrans = 10;

%% important parameters
% basic
opts.fs = 48e3;
opts.rootPath = '..\..\sounds';
mkdir(opts.rootPath);

% for continuous / seperated
s1ICI = 4; % ms
s2ICI = 4.06;
% singleDuration = 1000; % ms

%% generate single click
opts.Amp = 1;
opts.riseFallTime = 0; % ms
opts.clickDur = 0.2 ; % ms
click = generateClick(opts);

%% for click train long term
try
    load("randTimeSeq.mat");
catch
    randTimeSeq = generateRandTimeSeq(durTotal, NTrans, 0.7:0.05:1.3); % sec
    save("randTimeSeq.mat", "randTimeSeq", "-mat");
end
singleDuration = randTimeSeq * 1000; % ms
opts.repN = 3; % 
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.ICIs = [s1ICI; s2ICI]; % ms

opts.soundLength = singleDuration(1); % ms, sound length, composed of N single trains
RegWave = generateRegClickTrain(opts);
y = mergeSingleWave({[]}, RegWave(1), 0, opts, 1);

for sIndex = 2:length(singleDuration)
    opts.soundLength = singleDuration(sIndex); % ms, sound length, composed of N single trains

    % generate regular long term click train
    [RegWave, ~, ~, regClickTrainSampN] = generateRegClickTrain(opts);
    s1RegWave = repmat(RegWave(1), length(RegWave) - 1, 1);
    s2RegWave = RegWave(2:end, 1);
    
    if mod(sIndex, 2) == 1
        y = mergeSingleWave({y.s1s2}', s1RegWave, 0, opts, 1);
    else
        y = mergeSingleWave({y.s1s2}', s2RegWave, 0, opts, 1);
    end

end

% save continuous regular long term click train
opts.ICIName = s2ICI; 
opts.folderName = 'MRI usage';
opts.fileNameTemp = '[s2ICI]_Reg.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({y.s1s2}, opts);

% generate irregular click train
opts.baseICI =  s1ICI; % ms
opts.sigmaPara = 2; % sigma = μ / sigmaPara

for sIndex = 1:length(singleDuration)
    opts.soundLength = singleDuration(sIndex); % ms, sound length, composed of N single trains
    opts.irregICISampNBase = cell2mat(irregICISampN(opts));
    opts.irregLongTermSampN = opts.irregICISampNBase;
    [~, ~, ~, irregSampN] = generateIrregClickTrain(opts);
    
    s1IrregSampN = repmat(irregSampN(1), length(irregSampN) - 1, 1);
    s1IrregRepN = regClickTrainSampN(2 : end);
    
    s2IrregSampN = irregSampN(2 : end);
    s2IrregRepN = repmat(regClickTrainSampN(1), length(regClickTrainSampN) - 1, 1);
    
    opts.pos = 'head';
    [s1IrregWaveHead, ~, s1IrregSampNHead] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
    [s2IrregWaveHead, ~, s2IrregSampNHead] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);
    
    opts.pos = 'tail';
    [sound1, ~, ~] = repIrregByReg(s1IrregSampNHead, s1IrregRepN, opts); % both
    [sound2, ~, ~] = repIrregByReg(s2IrregSampNHead, s2IrregRepN, opts); % both
    [s1IrregWaveTail, ~, s1IrregSampNTail] = repIrregByReg(s1IrregSampN, s1IrregRepN, opts);
    [s2IrregWaveTail, ~, s2IrregSampNTail] = repIrregByReg(s2IrregSampN, s2IrregRepN, opts);
    
    if sIndex == 1
        mSound = mergeSingleWave({[]}, s1IrregWaveTail, 0, opts);
    elseif mod(sIndex, 2) == 1
        mSound = mergeSingleWave({mSound.s1s2}', sound1, 0, opts);
    else
        mSound = mergeSingleWave({mSound.s1s2}', sound2, 0, opts);
    end

end

% save continuous irregular long term click train
opts.ICIName = s2ICI; 
opts.folderName = 'MRI usage';
opts.fileNameTemp = '[s2ICI]_Irreg.wav';
opts.fileNameRep = '[s2ICI]';
exportSoundFile({mSound.s1s2}, opts)