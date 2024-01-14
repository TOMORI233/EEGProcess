function EEGPos = EEGPos_Neuracle64()
% grid size
EEGPos.grid = [10, 9]; % row-by-column

% channel map
EEGPos.map(1:3) = [5, 3, 7];
EEGPos.map(4:7) = [12, 16, 10, 18];
EEGPos.map(8) = 23;
EEGPos.map(9:2:15) = 22:-1:19;
EEGPos.map(10:2:16) = 24:27;
EEGPos.map(17) = 32;
EEGPos.map(18:2:24) = 31:-1:28;
EEGPos.map(19:2:25) = 33:36;
EEGPos.map(26) = 41;
EEGPos.map(27:2 : 33) = 40:-1:37;
EEGPos.map(28:2 : 34) = 42:45;
EEGPos.map(35:2:41 ) = 49:-1:46;
EEGPos.map(36:2:42) = 51:54;
EEGPos.map(43) = 59;
EEGPos.map(44:2:48 ) = 57:-1:55;
EEGPos.map(45:2:49) = 61:63;
EEGPos.map(50) = 68;
EEGPos.map(51:2:55 ) = 67:-1:65;
EEGPos.map(52:2:56) = 69:71;
EEGPos.map(57:59) = [77, 76, 78];
EEGPos.map(60:64) = [82, 84, 86, 88, 90];

% channels to ignore
EEGPos.ignore = [60:64];

% channel alias
% 1.000000	0.000000	0.484375	Fpz
% 2.000000	-18.000000	0.484375	Fp1
% 3.000000	18.000000	0.484375	Fp2
% 4.000000	-23.000000	0.390625	AF3
% 5.000000	23.000000	0.390625	AF4
% 6.000000	-38.000000	0.493750	AF7
% 7.000000	38.000000	0.493750	AF8
% 8.000000	0.000000	0.250000	Fz
% 9.000000	-22.000000	0.265625	F1
% 10.000000	22.000000	0.265625	F2
% 11.000000	-39.000000	0.312500	F3
% 12.000000	39.000000	0.312500	F4
% 13.000000	-49.000000	0.406250	F5
% 14.000000	49.000000	0.406250	F6
% 15.000000	-54.000000	0.484375	F7
% 16.000000	54.000000	0.484375	F8
% 17.000000	0.000000	0.121875	FCz
% 18.000000	-45.000000	0.171875	FC1
% 19.000000	45.000000	0.171875	FC2
% 20.000000	-62.000000	0.265625	FC3
% 21.000000	62.000000	0.265625	FC4
% 22.000000	-69.000000	0.375000	FC5
% 23.000000	69.000000	0.375000	FC6
% 24.000000	-72.000000	0.490625	FT7
% 25.000000	72.000000	0.490625	FT8
% 26.000000	0.000000	0.000000	Cz
% 27.000000	-90.000000	0.125000	C1
% 28.000000	90.000000	0.125000	C2
% 29.000000	-90.000000	0.250000	C3
% 30.000000	90.000000	0.250000	C4
% 31.000000	-90.000000	0.375000	C5
% 32.000000	90.000000	0.375000	C6
% 33.000000	-90.000000	0.500000	T7
% 34.000000	90.000000	0.500000	T8
% 35.000000	-135.000000	0.171875	CP1
% 36.000000	135.000000	0.171875	CP2
% 37.000000	-118.000000	0.265625	CP3
% 38.000000	118.000000	0.265625	CP4
% 39.000000	-111.000000	0.375000	CP5
% 40.000000	111.000000	0.375000	CP6
% 41.000000	-108.000000	0.490625	TP7
% 42.000000	108.000000	0.490625	TP8
% 43.000000	-180.000000	0.250000	Pz
% 44.000000	-141.000000	0.312500	P3
% 45.000000	141.000000	0.312500	P4
% 46.000000	-131.000000	0.406250	P5
% 47.000000	131.000000	0.406250	P6
% 48.000000	-126.000000	0.484375	P7
% 49.000000	126.000000	0.484375	P8
% 50.000000	-180.000000	0.390625	POz
% 51.000000	-157.000000	0.390625	PO3
% 52.000000	157.000000	0.390625	PO4
% 53.000000	-142.000000	0.432813	PO5
% 54.000000	142.000000	0.432813	PO6
% 55.000000	-142.000000	0.493750	PO7
% 56.000000	142.000000	0.493750	PO8
% 57.000000	-180.000000	0.484375	Oz
% 58.000000	-162.000000	0.484375	O1
% 59.000000	162.000000	0.484375	O2
% 60.000000	-180.000000	0.571875	ECG
% 61.000000	-155.000000	0.631250	HEOR
% 62.000000	155.000000	0.631250	HEOL
% 63.000000	-137.000000	0.781250	VEOU
% 64.000000	137.000000	0.781250	VEOL
EEGPos.channelNames{1 , 1} = 'Fpz';
EEGPos.channelNames{2 , 1} = 'Fp1';
EEGPos.channelNames{3 , 1} = 'Fp2';
EEGPos.channelNames{4 , 1} = 'AF3';
EEGPos.channelNames{5 , 1} = 'AF4';
EEGPos.channelNames{6 , 1} = 'AF7';
EEGPos.channelNames{7 , 1} = 'AF8';
EEGPos.channelNames{8 , 1} = 'Fz' ;
EEGPos.channelNames{9 , 1} = 'F1' ;
EEGPos.channelNames{10, 1} = 'F2' ;
EEGPos.channelNames{11, 1} = 'F3' ;
EEGPos.channelNames{12, 1} = 'F4' ;
EEGPos.channelNames{13, 1} = 'F5' ;
EEGPos.channelNames{14, 1} = 'F6' ;
EEGPos.channelNames{15, 1} = 'F7' ;
EEGPos.channelNames{16, 1} = 'F8' ;
EEGPos.channelNames{17, 1} = 'FCz';
EEGPos.channelNames{18, 1} = 'FC1';
EEGPos.channelNames{19, 1} = 'FC2';
EEGPos.channelNames{20, 1} = 'FC3';
EEGPos.channelNames{21, 1} = 'FC4';
EEGPos.channelNames{22, 1} = 'FC5';
EEGPos.channelNames{23, 1} = 'FC6';
EEGPos.channelNames{24, 1} = 'FT7';
EEGPos.channelNames{25, 1} = 'FT8';
EEGPos.channelNames{26, 1} = 'Cz' ;
EEGPos.channelNames{27, 1} = 'C1' ;
EEGPos.channelNames{28, 1} = 'C2' ;
EEGPos.channelNames{29, 1} = 'C3' ;
EEGPos.channelNames{30, 1} = 'C4' ;
EEGPos.channelNames{31, 1} = 'C5' ;
EEGPos.channelNames{32, 1} = 'C6' ;
EEGPos.channelNames{33, 1} = 'T7' ;
EEGPos.channelNames{34, 1} = 'T8' ;
EEGPos.channelNames{35, 1} = 'CP1';
EEGPos.channelNames{36, 1} = 'CP2';
EEGPos.channelNames{37, 1} = 'CP3';
EEGPos.channelNames{38, 1} = 'CP4';
EEGPos.channelNames{39, 1} = 'CP5';
EEGPos.channelNames{40, 1} = 'CP6';
EEGPos.channelNames{41, 1} = 'TP7';
EEGPos.channelNames{42, 1} = 'TP8';
EEGPos.channelNames{43, 1} = 'Pz' ;
EEGPos.channelNames{44, 1} = 'P3' ;
EEGPos.channelNames{45, 1} = 'P4' ;
EEGPos.channelNames{46, 1} = 'P5' ;
EEGPos.channelNames{47, 1} = 'P6' ;
EEGPos.channelNames{48, 1} = 'P7' ;
EEGPos.channelNames{49, 1} = 'P8' ;
EEGPos.channelNames{50, 1} = 'POz';
EEGPos.channelNames{51, 1} = 'PO3';
EEGPos.channelNames{52, 1} = 'PO4';
EEGPos.channelNames{53, 1} = 'PO5';
EEGPos.channelNames{54, 1} = 'PO6';
EEGPos.channelNames{55, 1} = 'PO7';
EEGPos.channelNames{56, 1} = 'PO8';
EEGPos.channelNames{57, 1} = 'Oz' ;
EEGPos.channelNames{58, 1} = 'O1' ;
EEGPos.channelNames{59, 1} = 'O2' ;
EEGPos.channelNames{60, 1} = 'ECG';
EEGPos.channelNames{61, 1} = 'HEOR';
EEGPos.channelNames{62, 1} = 'HEOL';
EEGPos.channelNames{63, 1} = 'VEOU';
EEGPos.channelNames{64, 1} = 'VEOL';

