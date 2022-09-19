clear; clc;
Amp = 1;
fs = 384e3;
toneLength = 1000; % ms
riseFallTime = 5; % ms

% InitializePsychSound
% PsychPortAudio('Close');
% pahandle = PsychPortAudio('Open', [], 1, 1, fs, 2);

f1 = 250;
f2 = [250, 246.3054];

for index = 1:2
    t = 1/fs : 1 /fs : (toneLength / 1000);
    
    tR = find(t*1000 < riseFallTime);
    tF = find(t*1000 > (toneLength - riseFallTime));
    riseFallR = length(tR);
    riseFallN = length(tF);
    tR(end) = [];
    tF(1) = [];
    sigRise = 1*((sin(pi*(0:1/(riseFallR-1):(1 - 1/(riseFallR-1)))-0.5*pi)+1)/2);
    sigFall = 1*((sin(pi*(0:1/(riseFallN-1):(1 - 1/(riseFallN-1)))+0.5*pi)+1)/2);
    
    tone1 = Amp * sin(2 * pi * f1 * t);
    tone2 = Amp * sin(2 * pi * f2(index) * t);
    tone1(tR) = tone1(tR) .* sigRise;
    tone2(tF) = tone2(tF) .* sigFall;
    
    wave = [tone1 tone2];
    
    audiowrite(['..\sounds\interval 0\', num2str(fix(f2(index))), '_PT.wav'], wave, fs);
    
%     PsychPortAudio('FillBuffer', pahandle, repmat(wave, 2, 1));
%     PsychPortAudio('Start', pahandle, 1, 0, 1);
end