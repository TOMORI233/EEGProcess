function EEGPos = EEGPos_Neuracle64()
% channels not to plot
EEGPos.ignore = [60:64];

%% Actual location
% locs file (highest priority, plot in actual location)
EEGPos.locs = readlocs('Neuracle_chan64.loc'); % comment this line to plot in grid

%% Channel Alias
EEGPos.channelNames = {EEGPos.locs.labels}';

%% Neighbours
th = 0.4;
neighbours = struct("label", EEGPos.channelNames);
dists = squareform(pdist(cat(1, [EEGPos.locs.X], [EEGPos.locs.Y], [EEGPos.locs.Z])'));

for index = 1:length(neighbours)
    neighbours(index).neighbch = find(dists(index, :) < th);
    neighbours(index).neighbch(neighbours(index).neighbch == index) = [];
    neighbours(index).neighblabel = {neighbours(neighbours(index).neighbch).label};
end

EEGPos.neighbours = neighbours;

%% Grid
% grid size
EEGPos.grid = [10, 9]; % row-by-column

% channel map into grid
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
