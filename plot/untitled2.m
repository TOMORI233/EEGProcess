run('EEGPosConfig');

Fig = plotRawWaveEEG(zeros(64,1000), [], [0 500], EEGPos);
plotLayoutEEG(Fig);