function EEGPos = EEGPos_Neuroscan64()
% channels not to plot
EEGPos.ignore = [33, 43, 60, 64];

%% Actual location
% locs file (highest priority, plot in actual location)
EEGPos.locs = readlocs('Neuroscan_chan64.loc'); % comment this line to plot in grid

%% Grid
% grid size
EEGPos.grid = [10, 9]; % row-by-column

% channel map into grid
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

% channel alias
EEGPos.channelNames{1 , 1} = 'FP1';
EEGPos.channelNames{2 , 1} = 'FPZ';
EEGPos.channelNames{3 , 1} = 'FP2';
EEGPos.channelNames{4 , 1} = 'AF3';
EEGPos.channelNames{5 , 1} = 'AF4';
EEGPos.channelNames{6 , 1} = 'F7' ;
EEGPos.channelNames{7 , 1} = 'F5' ;
EEGPos.channelNames{8 , 1} = 'F3' ;
EEGPos.channelNames{9 , 1} = 'F1' ;
EEGPos.channelNames{10, 1} = 'FZ' ;
EEGPos.channelNames{11, 1} = 'F2' ;
EEGPos.channelNames{12, 1} = 'F4' ;
EEGPos.channelNames{13, 1} = 'F6' ;
EEGPos.channelNames{14, 1} = 'F8' ;
EEGPos.channelNames{15, 1} = 'FT7';
EEGPos.channelNames{16, 1} = 'FC5';
EEGPos.channelNames{17, 1} = 'FC3';
EEGPos.channelNames{18, 1} = 'FC1';
EEGPos.channelNames{19, 1} = 'FCZ';
EEGPos.channelNames{20, 1} = 'FC2';
EEGPos.channelNames{21, 1} = 'FC4';
EEGPos.channelNames{22, 1} = 'FC6';
EEGPos.channelNames{23, 1} = 'FT8';
EEGPos.channelNames{24, 1} = 'T7' ;
EEGPos.channelNames{25, 1} = 'C5' ;
EEGPos.channelNames{26, 1} = 'C3' ;
EEGPos.channelNames{27, 1} = 'C1' ;
EEGPos.channelNames{28, 1} = 'CZ' ;
EEGPos.channelNames{29, 1} = 'C2' ;
EEGPos.channelNames{30, 1} = 'C4' ;
EEGPos.channelNames{31, 1} = 'C6' ;
EEGPos.channelNames{32, 1} = 'T8' ;
EEGPos.channelNames{33, 1} = 'A1' ;
EEGPos.channelNames{34, 1} = 'TP7';
EEGPos.channelNames{35, 1} = 'CP5';
EEGPos.channelNames{36, 1} = 'CP3';
EEGPos.channelNames{37, 1} = 'CP1';
EEGPos.channelNames{38, 1} = 'CPZ';
EEGPos.channelNames{39, 1} = 'CP2';
EEGPos.channelNames{40, 1} = 'CP4';
EEGPos.channelNames{41, 1} = 'CP6';
EEGPos.channelNames{42, 1} = 'TP8';
EEGPos.channelNames{43, 1} = 'A2' ;
EEGPos.channelNames{44, 1} = 'P7' ;
EEGPos.channelNames{45, 1} = 'P5' ;
EEGPos.channelNames{46, 1} = 'P3' ;
EEGPos.channelNames{47, 1} = 'P1' ;
EEGPos.channelNames{48, 1} = 'PZ' ;
EEGPos.channelNames{49, 1} = 'P2' ;
EEGPos.channelNames{50, 1} = 'P4' ;
EEGPos.channelNames{51, 1} = 'P6' ;
EEGPos.channelNames{52, 1} = 'P8' ;
EEGPos.channelNames{53, 1} = 'PO7';
EEGPos.channelNames{54, 1} = 'PO5';
EEGPos.channelNames{55, 1} = 'PO3';
EEGPos.channelNames{56, 1} = 'POZ';
EEGPos.channelNames{57, 1} = 'PO4';
EEGPos.channelNames{58, 1} = 'PO6';
EEGPos.channelNames{59, 1} = 'PO8';
EEGPos.channelNames{60, 1} = 'CB1';
EEGPos.channelNames{61, 1} = 'O1' ;
EEGPos.channelNames{62, 1} = 'OZ' ;
EEGPos.channelNames{63, 1} = 'O2' ;
EEGPos.channelNames{64, 1} = 'CB2';
