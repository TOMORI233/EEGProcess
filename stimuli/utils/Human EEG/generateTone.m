clear; clc;
Amp = 1;
fs = 48e3;
toneLength = 1000; % ms
riseFallTime = 5; % ms
nRepeat = 5;

f1 = 250;
f2 = [250, 247];

for index = 1:length(f2)
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

    tone1Head = tone1;
    tone2Tail = tone2;
    tone1Head(tR) = tone1(tR) .* sigRise;
    tone2Tail(tF) = tone2(tF) .* sigFall;

    toneBody = [];

    for n = 1:nRepeat - 2
        toneBody = [toneBody, tone1, tone2];
    end
    
    wave = [tone1Head, tone2, toneBody, tone1, tone2Tail];

%     playAudio(wave, fs);
    
    audiowrite(['..\..\sounds\', num2str(fix(f2(index))), '_PT.wav'], wave, fs);
end