function varargout = plotScatterEEG(xdata, ydata, EEGPos, statFcn, fdrOpt)
narginchk(3, 5);

channels = EEGPos.channels;
chsIgnore = EEGPos.ignore;
channelNames = EEGPos.channelNames;
locs = EEGPos.locs;

% check data: channel-by-subject
if size(xdata, 1) ~= numel(channels) | ...
   size(ydata, 1) ~= numel(channels) | ...
   size(xdata, 2) ~= size(ydata, 2)
    error("Input size not valid");
end

% remove NAN
xdata(isnan(xdata)) = 0;
ydata(isnan(ydata)) = 0;

% statistics: two-sided paired test
if nargin < 4
    % test normality
    if all(rowFcn(@(x) swtest(x, 0.05), xdata) & rowFcn(@(x) swtest(x, 0.05), ydata))
        % parametric
        statFcn = @(x, y) obtainArgoutN(@ttest, 2, x, y);
    else
        % non-parametric
        statFcn = @(x, y) signrank(x, y);
    end

end

if ~isempty(statFcn)
    p = rowFcn(@(x, y) statFcn(x, y), xdata, ydata, "ErrorHandler", @mErrorFcn);

    if nargin < 5
        fdrOpt = true;
    end

    if fdrOpt
        [~, ~, p] = fdr_bh(p, 0.05, 'dep');
    end

else
    p = ones(numel(channels), 1);
end

% location
[~, ~, Th, Rd, ~] = readlocs(locs);
Th = pi / 180 * Th; % convert degrees to radians
[XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates

% flip
X = zeros(length(channels), 1);
Y = zeros(length(channels), 1);
idx = ~ismember(channels, chsIgnore);
X(idx) = mapminmax(YTemp(idx), 0.25, 0.75);
Y(idx) = mapminmax(XTemp(idx), 0.05, 0.92);
dX = 0.03;
dY = 0.03;

Fig = figure;
for chNum = 1:length(channels)

    if ismember(chNum, chsIgnore)
        continue;
    end

    axes('Position', [X(chNum) - dX / 2, Y(chNum) - dY / 2, dX, 2 * dY]);
    scatter(xdata(chNum, :), ydata(chNum, :), 10, "black", "filled");
    
    % mark significant channels with grey background
    if p(chNum) < 0.05
        set(gca, "Color", [.85, .85, .85]);
    end

    title(channelNames{chNum}, "FontSize", 12);
    xticklabels('');
    yticklabels('');
    set(gca, "TickLength", [0, 0]);
    set(gca, "XLimitMethod", "tight");
    set(gca, "YLimitMethod", "tight");
    syncXY;

    % enlarge scatterplot
    xyRange = get(gca, "XLim");
    dXYRange = diff(xyRange);
    set(gca, "XLim", [xyRange(1) - 0.2 * dXYRange, xyRange(2) + 0.2 * dXYRange]);
    set(gca, "YLim", [xyRange(1) - 0.2 * dXYRange, xyRange(2) + 0.2 * dXYRange]);

    addLines2Axes(gca);
end

if nargout <= 1
    varargout{1} = Fig;
else
    error("Unspecified output");
end

return;
end