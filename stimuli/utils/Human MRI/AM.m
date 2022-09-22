clear; clc;
duration = 10; % sec

fs = 48e3;
t = (1/fs:1/fs:duration)';
y = wgn(length(t), 1, 10*log10(0.01));

f = 0.5;
y2 = y .* sin(2*pi*f*t) + 0.5;

% playAudio(y2, fs);

figure;
plot(t, y2);

audiowrite('..\..\sounds\AM.wav', y2, fs);