function axs = createAxesEEG(EEGPos, axSize)
narginchk(1, 2);

if nargin < 2
    axSize = [0.05, 0.06]; % normalized size
end

channels = EEGPos.channels;
channelNames = EEGPos.channelNames;
chsIgnore = EEGPos.ignore;
locs = EEGPos.locs;

[~, ~, Th, Rd, ~] = readlocs(locs);
Th = pi / 180 * Th; % convert degrees to radians
[XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates

% flip
[X, Y] = deal(zeros(length(channels), 1));
idx = ~ismember(channels, chsIgnore);
X(idx) = mapminmax(YTemp(idx), 0.2, 0.8);
Y(idx) = mapminmax(XTemp(idx), 0.05, 0.92);

dX = axSize(1);
dY = axSize(2);

Fig = figure("WindowState", "maximized");
n = 0;
for chNum = 1:length(channels)

    if ismember(chNum, chsIgnore)
        continue;
    end
    
    n = n + 1;
    axs(n, 1) = axes(Fig, 'Position', [X(chNum) - dX / 2, Y(chNum) - dY / 2, dX, dY]);
    title(channelNames{chNum});
end

return;
end