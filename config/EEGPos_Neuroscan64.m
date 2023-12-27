function EEGPos = EEGPos_Neuroscan64()
EEGPos.grid = [10, 9]; % row-by-column

EEGPos.map(1:3) = 4:6;
EEGPos.map(4:5) = [13, 15];
EEGPos.map(6 : 14) = 19:27;
EEGPos.map(15 : 23) = 28:36;
EEGPos.map(24 : 32) = 37:45;
EEGPos.map(33) = 82;
EEGPos.map(34 : 42) = 46:54;
EEGPos.map(43) = 90;
EEGPos.map(44 : 52) = 55:63;
EEGPos.map(53 : 59) = 65:71;
EEGPos.map(60) = 85;
EEGPos.map(61 : 63) = 76:78;
EEGPos.map(64) = 87;

% channels not to plot
EEGPos.ignore = [33, 43];