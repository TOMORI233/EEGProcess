clear; clc;
Amp = 0.1;
fs = 97656;
toneLength = 5000; % ms
cutLength = 7000; % ms
riseFallTime = 2; % ms
rootPath = fullfile('..\ratSounds', datestr(now, "yyyy-mm-dd"));
% rootPath = fullfile('..\monkeySounds', datestr(now, "yyyy-mm-dd"));
% rootPath = fullfile('..\monkeySounds', '2022-07-25');

mkdir(fullfile(rootPath, 'interval 0'));
% InitializePsychSound
% PsychPortAudio('Close');
% pahandle = PsychPortAudio('Open', [], 1, 1, fs, 2);
fRatio = 1.1;
f1 = 3920;
f2 = f1 * fRatio;

compRatio = [1/16 1/8 1/4 1/2 1 2 4];

for index = 1 : length(f2)
    t = 1/fs : 1 /fs : (toneLength / 1000);
    % calculate rise fall index
    tR = find(t*1000 < riseFallTime);
    tF = find(t*1000 > (toneLength - riseFallTime));
    riseFallR = length(tR);
    riseFallN = length(tF);
    if riseFallTime
        tR(end) = [];
        tF(1) = [];
    end
    sigRise = 1*((sin(pi*(0:1/(riseFallR-1):(1 - 1/(riseFallR-1)))-0.5*pi)+1)/2);
    sigFall = 1*((sin(pi*(0:1/(riseFallN-1):(1 - 1/(riseFallN-1)))+0.5*pi)+1)/2);
    
    for comp = 1 : length(compRatio)
        tone1Temp(comp, :) = Amp * sin(2 * pi * f1(index) * compRatio(comp) * t);
        tone2Temp(comp, :) = Amp * sin(2 * pi * f2(index) * compRatio(comp) * t);
    end
    fuzaTone1 = sum(tone1Temp, 1);
    fuzaTone2 = sum(tone2Temp, 1);

    fuzaTone1(tR) = fuzaTone1(tR) .* sigRise;
    fuzaTone2(tF) = fuzaTone2(tF) .* sigFall;
    
    % cut off last signals for each tone
    [~, ~, zeroIdx1] = findZeroPoint(fuzaTone1); % cross zero point, NP
    fuzaTone1(zeroIdx1(end) : end) = [];
    [~, ~, zeroIdx2] = findZeroPoint(fuzaTone2);
    fuzaTone2(zeroIdx2(end) : end) = [];

    % merge tone
    cutIndex = 1/fs : 1/fs : length([fuzaTone1 fuzaTone2]) / fs  < cutLength / 1000;
    wave1 = [fuzaTone1 fuzaTone2];
    wave1 = wave1(cutIndex);
    wave2 = [fuzaTone2 fuzaTone1];
    wave2 = wave2(cutIndex);

    % cut off last signals for merged tone
    [~, ~, zeroIdx1] = findZeroPoint(wave1); % cross zero point, NP
    wave1(zeroIdx1(end) : end) = [];
    [~, ~, zeroIdx2] = findZeroPoint(wave2);
    wave2(zeroIdx2(end) : end) = [];

    wave1Str = strcat(num2str(fix(f1(index))), "_", num2str(fix(f2(index))) , "_FZPT.wav");
    wave2Str = strcat(num2str(fix(f2(index))), "_", num2str(fix(f1(index))) , "_FZPT.wav");
    
    % save sound
    
    audiowrite(fullfile(rootPath, 'interval 0', wave1Str), wave1, fs);
    audiowrite(fullfile(rootPath, 'interval 0', wave2Str), wave2, fs);

    timeLength1 = length(fuzaTone1) / fs * 1000;
    timeLength2 = length(fuzaTone2) / fs * 1000;


    stimStr{index, 1} = strcat(num2str(fix(f1(index))), "o", num2str(fix(f2(index))));
    fuzaTone1Duration{index, 1} = timeLength1;
    fuzaTone2Duration{index, 1} = timeLength2;

end
fuzaToneOpts = struct("stimStr", stimStr, "fuzaTone1Duration", fuzaTone1Duration, "fuzaTone2Duration", fuzaTone2Duration);
save(fullfile(rootPath, "fuzaToneOpts.mat"), "fuzaToneOpts", "-mat");

L = length(wave1);
Y1 = fft(wave1);
P2 = abs(Y1/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;
plot(f,P1) 
xlim([100 20000])