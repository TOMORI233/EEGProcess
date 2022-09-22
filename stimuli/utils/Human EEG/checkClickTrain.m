clear; clc;
% loadPath = 'E:\ratNeuroPixel\monkeySounds\2022-08-26\interval 0';
loadPath = '..\..\sounds\continuous';
% loadPath = 'D:\Monkey\matlab\parameters';
[y1, fs] = audioread(fullfile(loadPath,'4_Irreg.wav'));


S1Duration = 5009/1000;
TT = (1/fs : 1/fs : length(y1)/fs) - S1Duration;
% [y1,Fs] = audioread(fullfile(loadPath,'4_4.06_IrregStdDev.wav'));
onIdx = find(y1 == y1(1));
toHighIdx = find(y1 == 0) + 1;
changeHighIdx = intersect(onIdx,toHighIdx);
interval = changeHighIdx - [0; changeHighIdx(1:end-1)];

% spectrum 

% irreg
waveT = y1(TT > -4 & TT < 0);
L = length(waveT);
Y1 = fft(waveT);
P2 = abs(Y1/L);
P1Irreg = P2(1:L/2+1);
P1Irreg(2:end-1) = 2*P1Irreg(2:end-1);
fIrreg = fs*(0:(L/2))/L;

% figure
% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlim([0 500]);
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
% 
% 
% 
% length(y1) / fs
% interval(1251:end, 2) = interval(1:1250, 1);
% sum(interval(1:1250,1)) / fs
% sum(interval(1251:2500,1)) / fs