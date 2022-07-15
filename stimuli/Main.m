clear; clc; close all force;

%% Initialization
% PTB
InitializePsychSound;
PsychPortAudio('Close');
% IO
ioObj = io64;
status = io64(ioObj);
address = hex2dec('378'); % standard LPT1 output port address

%% Parameters settings
nRepeat = 1;
fsDevice = 48e3; % Hz
volumn = 0.3;
choiceWin = 2; % sec

devices = PsychPortAudio('GetDevices');
deviceID = [];

%% Part 1: Passive section 1 - different basic ICI
PsychPortAudio('Close');
disp('Press any key to start Part 1 - Passive section 1 - different basic ICI');
KbWait;
mTrigger(ioObj, address, 30);
disp('Part 1 start');
WaitSecs(2);
data(1).trialsData = passiveFcn(1, nRepeat, 4, fsDevice, deviceID, volumn, ioObj, address);
data(1).protocol = "passive1";

%% Part 2: Passive section 2 - different variance
PsychPortAudio('Close');
disp('Press any key to start Part 2 - Passive section 2 - different variance');
KbWait;
mTrigger(ioObj, address, 60);
disp('Part 2 start');
WaitSecs(2);
data(2).trialsData = passiveFcn(2, nRepeat, 4, fsDevice, deviceID, volumn, ioObj, address);
data(2).protocol = "passive2";

%% Part 3: Passive section 3 - behavior (interval = 0)
PsychPortAudio('Close');
disp('Press any key to start Part 3 - Passive section 3 - behavior (interval = 0)');
KbWait;
mTrigger(ioObj, address, 90);
disp('Part 3 start');
WaitSecs(2);
data(3).trialsData = passiveFcn(3, nRepeat, 4, fsDevice, deviceID, volumn, ioObj, address);
data(3).protocol = "passive3";

%% Part 4: Active section 1 - behavior (interval = 0)
PsychPortAudio('Close');
disp('Press any key to start Part 4 - Active section 1 - behavior (interval = 0)');
KbWait;
mTrigger(ioObj, address, 120);
disp('Part 4 start');
WaitSecs(2);
data(4).trialsData = activeFcn(4, nRepeat, 5, choiceWin, fsDevice, deviceID, volumn, ioObj, address);
data(4).protocol = "active1";

%% Part 5: Active section 2 - behavior (interval = 600)
PsychPortAudio('Close');
disp('Press any key to start Part 5 - Active section 2 - behavior (interval = 600)');
KbWait;
mTrigger(ioObj, address, 150);
disp('Part 5 start');
WaitSecs(2);
data(5).trialsData = activeFcn(5, nRepeat, 5, choiceWin, fsDevice, deviceID, volumn, ioObj, address);
data(5).protocol = "active2";

%% Part 6: Decoding
PsychPortAudio('Close');
disp('Press any key to start Part 6 - Decoding');
KbWait;
mTrigger(ioObj, address, 180);
disp('Part 6 start');
WaitSecs(2);
data(6).trialsData = passiveFcn(6, nRepeat, 2, fsDevice, deviceID, volumn, ioObj, address);
data(6).protocol = "decoding";
PsychPortAudio('Close');

%% Saving
mkdir(['Data\', datestr(now, 'yyyymmdd')]);
save(['Data\', datestr(now, 'yyyymmdd'), '\trialsData.mat'], 'data');