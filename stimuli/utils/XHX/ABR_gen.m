ccc;
fs = 384e3;
singleClickDur = 2e-4;
clickTrainDur = 30;
click = genClick(singleClickDur, fs);

ICI1 = 4e-3;
clickTrain1 = genRegClickTrain(click, clickTrainDur, ICI1, fs);
audiowrite("0001_type-REG_ICI-4.wav", clickTrain1, fs);

ICI2 = 4.01e-3;
clickTrain2 = genRegClickTrain(click, clickTrainDur, ICI2, fs);

y = [clickTrain1; clickTrain2]';
y1 = 0.01 * sin(2 * pi * 40 * (0:length(y) - 1) / fs);
y2 = y + y1;

figure;
plot(y2);

% audiowrite('001_type-REG_ICI1-4_ICI2-5.wav', y, fs);
playAudio(y, fs, 48e3);
playAudio(y2, fs, 48e3);

figure;
plot(y2);


f1 = 250;
f2 = 200;
rfTime = 5e-3;
toneDur = 0.5;
y1 = genRiseFallEdge(generateTone(f1, toneDur, fs, [], "complete"), fs, rfTime, "rise");
y2 = genRiseFallEdge(generateTone(f2, toneDur, fs, [], "complete"), fs, rfTime, "fall");

yT = [y1, y2];
audiowrite('002_type-PT_f1-250_f2-200.wav', yT, fs);
playAudio(yT, fs, 48e3);

figure;
plot(yT);