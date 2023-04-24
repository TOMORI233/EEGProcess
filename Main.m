%% Export data
run("batchExport.m");

%% Process individual data
clear; clc;
run("batchSingle.m");

%% Collect individual data
run("batchCollect.m");

%% Behavior and exclude subjects with bad behavior
run("FigureProcess_Behavior.m");

%% Find window for onset response
run("FigureProcess_FindOnsetWin.m");

%% Generate FindChs.mat for each subject
clear; clc; close all force;
batchSingle("passive3");

%% Find channels with significant auditory reaction
run("batchCollect.m");
run("FigureProcess_FindChs.m");

%% Find window for BRI for each protocol
run("FigureProcess_FindBriWin.m");

%% Compute BRI for each protocol and for each subject
run("batchSingle.m");
run("batchCollect.m");

%% Analyze at population level
run("FigureProcess_A1.m");
run("FigureProcess_A2.m");
run("FigureProcess_P1.m");
run("FigureProcess_P2.m");
run("FigureProcess_P3.m");

%% Compare
run("FigureProcess_Compare_A1_P3.m");
run("FigureProcess_Compare_P1_P3.m");
