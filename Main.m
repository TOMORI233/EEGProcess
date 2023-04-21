clear; clc; close all force;

%% Export data
run("batchExport.m");

%% Process individual data
run("batchSingle.m");

%% Collect individual data
run("batchCollect.m");

%% Preview
% run("FigureProcess_A1chMean.m");

%% Behavior
run("FigureProcess_Behavior.m");

%% Find channels with significant auditory reaction
run("FigureProcess_FindChs.m");

%% Find window for BRI
run("FigureProcess_FindBriWin.m");
