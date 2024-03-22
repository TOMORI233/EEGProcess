ccc;

%% Path
cd(fileparts(mfilename("fullpath")));
FIGUREPATH = getAbsPath("..\Figures\healthy\population\Channel Select");

for index = 1:2
    %% Load
    if index == 1
        %%%% Neuroscan %%%%
        EEGPos = EEGPos_Neuroscan64;
        run(fullfile(pwd, "config/avgConfig_Neuroscan64.m"));
        FILENAME = fullfile(FIGUREPATH, 'Neuroscan 64.png');
        SYSTEM = 'Neuroscan channel-64';
    else
        %%%% Neuracle %%%%
        EEGPos = EEGPos_Neuracle64;
        run(fullfile(pwd, "config/avgConfig_Neuracle64.m"));
        FILENAME = fullfile(FIGUREPATH, 'Neuracle 64.png');
        SYSTEM = 'Neuracle channel-64';
    end

    %% Params & conversion
    locs = EEGPos.locs;
    [~, ~, Th, Rd, ~] = readlocs(locs);
    Th = pi / 180 * Th; % convert degrees to radians
    [XTemp, YTemp] = pol2cart(Th, Rd); % transform electrode locations from polar to cartesian coordinates

    % remove ignored channels
    channels = 1:length(locs);
    idx = ~ismember(channels, getOr(EEGPos, "ignore"));
    channels = channels(idx);
    XTemp = XTemp(idx);
    YTemp = YTemp(idx);

    % flip & normalize
    X = mapminmax(YTemp, -1, 1);
    Y = mapminmax(XTemp, -1, 1);

    %% Plot
    figure("WindowState", "maximized");
    mSubplot(1, 2, 1, "shape", "square-min");
    scatter(X(ismember(channels, chs2Avg)), Y(ismember(channels, chs2Avg)), 700, "red", "filled");
    hold on;
    scatter(X(~ismember(channels, chs2Avg)), Y(~ismember(channels, chs2Avg)), 700, "red", "LineWidth", 1);
    arrayfun(@(x, y, z) text(gca, x, y, upper(z.labels), "HorizontalAlignment", "center", "FontWeight", "bold", "FontSize", 12), X, Y, locs(idx));
    set(gca, "Visible", "off");

    mSubplot(1, 2, 2, "shape", "square-min");
    scatter(X(ismember(channels, chs2Avg)), Y(ismember(channels, chs2Avg)), 700, "red", "filled");
    hold on;
    scatter(X(~ismember(channels, chs2Avg)), Y(~ismember(channels, chs2Avg)), 700, "red", "LineWidth", 1);
    arrayfun(@(x, y, z) text(gca, x, y, num2str(z), "HorizontalAlignment", "center", "FontWeight", "bold", "FontSize", 12), X, Y, channels);
    set(gca, "Visible", "off");

    addTitle2Fig(gcf, SYSTEM, "FontWeight", "bold");
    print(gcf, FILENAME, "-dpng", "-r300");
end