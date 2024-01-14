function EEGPos = EEGPos_Neuroscan64()
% grid size
EEGPos.grid = [10, 9]; % row-by-column

% channel map
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
EEGPos.ignore = [33, 43, 60, 64];

% channel alias
% 1	     -16.926	 0.31345	     FP1
% 2	           0	 0.32214	     FPZ
% 3	      16.772	 0.31499	     FP2
% 4	     -19.322	 0.25785	     AF3
% 5	      19.107	 0.25805	     AF4
% 6	     -46.727	 0.30162	      F7
% 7	     -41.579	 0.25365	      F5
% 8	     -31.807	 0.21835	      F3
% 9	     -18.598	 0.18516	      F1
% 10	       0	 0.16409	      FZ
% 11	  18.571	 0.18415	      F2
% 12	  31.982	  0.2197	      F4
% 13	  41.636	 0.25635	      F6
% 14	  46.704	 0.30417	      F8
% 15	 -64.392	 0.29014	     FT7
% 16	 -60.094	 0.22429	     FC5
% 17	 -52.083	 0.16129	     FC3
% 18	 -35.446	 0.11489	     FC1
% 19	       0	 0.08358	     FCZ
% 20	  35.446	 0.11489	     FC2
% 21	  52.083	 0.16129	     FC4
% 22	  60.444	 0.22597	     FC6
% 23	  64.609	 0.28955	     FT8
% 24	 -85.185	 0.28058	      T7
% 25	 -85.054	  0.2105	      C5
% 26	 -84.285	  0.1401	      C3
% 27	 -80.837	 0.07007	      C1
% 28	       0	0.014653	      CZ
% 29	  80.837	 0.07007	      C2
% 30	  84.191	 0.13811	      C4
% 31	   84.99	 0.20856	      C6
% 32	  85.164	 0.28021	      T8
% 33	 -107.41	 0.45327	      M1
% 34	 -104.42	 0.27398	     TP7
% 35	 -110.81	 0.21372	     CP5
% 36	 -119.39	 0.14782	     CP3
% 37	 -137.83	0.096916	     CP1
% 38	     180	 0.06938	     CPZ
% 39	  137.93	0.097705	     CP2
% 40	  119.23	 0.14744	     CP4
% 41	  110.39	  0.2114	     CP6
% 42	  104.42	 0.27398	     TP8
% 43	   107.7	  0.4574	      M2
% 44	 -123.76	 0.29696	      P7
% 45	 -131.55	 0.23806	      P5
% 46	 -143.42	 0.19385	      P3
% 47	 -158.64	 0.15961	      P1
% 48	     180	 0.14112	      PZ
% 49	  159.46	 0.16019	      P2
% 50	  143.19	 0.19146	      P4
% 51	  131.04	 0.23645	      P6
% 52	  123.58	 0.29481	      P8
% 53	 -141.45	 0.29485	     PO7
% 54	 -150.38	 0.25267	     PO5
% 55	 -164.82	 0.22392	     PO3
% 56	     180	  0.2148	     POZ
% 57	  164.82	 0.22392	     PO4
% 58	  150.31	 0.24907	     PO6
% 59	  141.55	 0.29274	     PO8
% 60	 -163.49	 0.35144	     CB1
% 61	 -159.39	 0.30114	      O1
% 62	     180	 0.29246	      OZ
% 63	  159.39	 0.30114	      O2
% 64	  163.29	 0.34764	     CB2
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
