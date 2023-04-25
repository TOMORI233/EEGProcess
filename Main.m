%% Export data
ccc;
batchExport();

%% Process individual data
ccc;
batchSingle([], false);

%% Collect individual chMean and behavior data
ccc;
batchCollect(["Behavior_A1_Res", ...
              "Behavior_A2_Res", ...
              "chMean_A1", ...
              "chMean_A2", ...
              "chMean_P1", ...
              "chMean_P2", ...
              "chMean_P3"])

%% Behavior and exclude subjects with bad behavior
run("FigureProcess_Behavior.m");

%% Find window for onset response
run("FigureProcess_FindOnsetWin.m");

%% Generate FindChs.mat for each subject
ccc;
batchSingle("passive3", true);

%% Find channels with significant auditory reaction
ccc;
batchCollect("FindChs");
run("FigureProcess_FindChs.m");

%% Find window for BRI for each protocol
run("FigureProcess_FindBriWin.m");

%% Compute BRI for each protocol and for each subject
ccc;
batchSingle([], true);
ccc;
batchCollect(["BRI_P1", ...
              "BRI_P2", ...
              "BRI_P3", ...
              "BRI_A1", ...
              "BRI_A2"]);

%-----------------Final results-----------------------
%% Analyze at population level
run("FigureProcess_A1.m");
run("FigureProcess_A2.m");
run("FigureProcess_P1.m");
run("FigureProcess_P2.m");
run("FigureProcess_P3.m");

%% Compare
run("FigureProcess_Compare_A1_P3.m");
run("FigureProcess_Compare_P1_P3.m");
