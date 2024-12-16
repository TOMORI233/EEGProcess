function addScaleEEG(Fig, EEGPos, unitX, unitY)
narginchk(2, 4);

if nargin < 3
    unitX = [];
end

if nargin < 4
    unitY = [];
end

% load
locs = EEGPos.locs;
channels = EEGPos.channels;
chsIgnore = getOr(EEGPos, "ignore");

% coordinate
[~, ~, Th, Rd, ~] = readlocs(locs);
Th = pi / 180 * Th; % convert degrees to radians
[XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates

% flip
X = zeros(length(channels), 1);
Y = zeros(length(channels), 1);
idx = ~ismember(channels, chsIgnore);
X(idx) = mapminmax(YTemp(idx), 0.2, 0.8);
Y(idx) = mapminmax(XTemp(idx), 0.05, 0.92);
dX = 0.05;
dY = 0.06;

% get all axes
allAxes = findobj(Fig, "Type", "axes");
xRange = get(allAxes(end), "XLim");
yRange = get(allAxes(end), "YLim");

% add scale
tempX = [0, mode(diff(get(allAxes(end), "XTick")))];
tempY = [0, mode(diff(get(allAxes(end), "YTick")))];

ax = axes(Fig, 'Position', [min(X(idx)) - dX / 2, min(Y(idx)) - dY / 2, dX, dY]);
addLines2Axes(ax, struct("X", [0, 0], "Y", tempY, "width", 2, "style", "-"));
addLines2Axes(ax, struct("X", tempX, "Y", [0, 0], "width", 2, "style", "-"));
xlim(ax, xRange);
ylim(ax, yRange);
xticks(ax, tempX);
yticks(ax, tempY);
ax.Visible = "off";

strX = num2str(tempX(2));
strY = num2str(tempY(2));

if ~isempty(unitX)
    strX = [strX, char(unitX)];
end

if ~isempty(unitY)
    strY = [strY, char(unitY)];
end

text(ax, diff(tempX), 0, strX, "HorizontalAlignment", "left", "VerticalAlignment", "middle", "FontSize", 14, "FontWeight", "bold");
text(ax, 0, diff(tempY), strY, "HorizontalAlignment", "center", "VerticalAlignment", "bottom", "FontSize", 14, "FontWeight", "bold");

return;
end