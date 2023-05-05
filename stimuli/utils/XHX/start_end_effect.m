%% start-end effect
ccc;

% Natural sound
[y0, fs] = audioread("end.mp3");
y0 = genRiseFallEdge(y0(3e3:2.5e4, 1)', fs, 50e-3, "fall");
y0(1:1050) = 0;

% Tone
% fs = 48e3;
% dur = 0.5;
% t = 0:1 / fs:dur;
% f = 1e3;
% rfTime = 5e-3;
% silenceTime = 50e-3;
% y_silence = zeros(1, fix(silenceTime * fs));
% y0 = sin(2 * pi * f * t);
% y0 = [y_silence, genRiseFallEdge(y0, fs, rfTime, "both"), y_silence];

%% 
close all;
disp(['Total time: ', num2str(length(y0) / fs), ' sec']);
% N = 1100;
% N = 20000;
N = 10000;
noiseDur = 10e-3;
interval = 500e-3;
snr = 35; % dB
y_noise = awgn(y0, snr);
y1 = [y0(1:N - 1), y_noise(N:N + fix(noiseDur * fs) - 1), y0(N + fix(noiseDur * fs):end)];
y2 = flip(y1);
yF = [y0, zeros(1, fix(interval * fs)), y1];
yB = [flip(y0), zeros(1, fix(interval * fs)), y2];

audiowrite(['forward_', num2str(N), '.wav'], yF, fs);
audiowrite(['backward_', num2str(N), '.wav'], yF, fs);

playAudio(yF, fs);
KbGet(32, 60);
playAudio(yB, fs);

% forward
figure;
subplot(2, 1, 1);
plot(y0);
subplot(2, 1, 2);
plot(y1);
hold on;
plot(N:N + fix(noiseDur * fs) - 1, y_noise(N:N + fix(noiseDur * fs) - 1), 'r.');

% backward
figure;
subplot(2, 1, 1);
plot(flip(y0));
subplot(2, 1, 2);
plot(y2);
hold on;
plot(length(y0) - N - fix(noiseDur * fs) + 2:length(y0) - N + 1, flip(y_noise(N:N + fix(noiseDur * fs) - 1)), 'r.');