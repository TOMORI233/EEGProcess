clear; clc;

fs = 48e3; % Hz
f = [88,125,177,250,354,500,707,1000,1414,2000,2828,4000,5657,8000]; % Hz
duration = 2; % sec
rtTime = 2e-3; % sec

y = genRiseFallEdge(generateTone(f(1), duration, fs, [], "complete"), fs, rtTime, "rise");
for index = 2:length(f) - 1
    y = [y, generateTone(f(index), duration, fs, [], "complete")];
end
y = [y, genRiseFallEdge(generateTone(f(end), duration, fs, [], "complete"), fs, rtTime, "fall")];

audiowrite('Tone Screening.wav', y, fs);