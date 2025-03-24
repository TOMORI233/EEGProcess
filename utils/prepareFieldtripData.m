function data = prepareFieldtripData(trialsData, window, fs, channelNames)
    narginchk(3, 4);

    t = linspace(window(1), window(2), size(trialsData{1}, 2));
    channels = (1:size(trialsData{1}, 1))';

    if nargin < 4
        channelNames = arrayfun(@num2str, channels, "UniformOutput", false);
    else

        if numel(channelNames) ~= numel(channels)
            error("The number of channel labels does not match the number of channels");
        end

    end

    cfg = [];
    cfg.reref = 'yes';              % 启用重新参考
    cfg.refmethod = 'average';       % 设置参考方法为“average reference”
    cfg.refchannel = 'all';          % 选择所有通道作为参考
    cfg.trials = 'all';
    
    data.trial = trialsData(:)';
    data.time = repmat({t}, 1, length(trialsData));
    data.label = channelNames;
    data.fsample = fs;
    data.trialinfo = ones(length(trialsData), 1);
    data = ft_selectdata(cfg, data);

    return;
end