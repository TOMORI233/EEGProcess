function [trialsEEG, chMean, chStd, sampleinfo] = selectEEG(EEGDataset, trials, window, scaleFactor)
    narginchk(3, 4);

    if nargin < 4
        scaleFactor = 1;
    end

    windowIndex = fix(window / 1000 * EEGDataset.fs);
    segIndex = [trials.onset];

    % by trial
    trialsEEG = cell(length(segIndex), 1);
    sampleinfo = zeros(length(segIndex), 2);

    for index = 1:length(segIndex)
        sampleinfo(index, :) = [segIndex(index) + windowIndex(1), segIndex(index) + windowIndex(2)];
        trialsEEG{index} = EEGDataset.data(:, segIndex(index) + windowIndex(1):segIndex(index) + windowIndex(2));
    end

    % scale
    trialsEEG = cellfun(@(x) x * scaleFactor, trialsEEG, "UniformOutput", false);

    % by channel
    nChs = length(EEGDataset.channels);
    temp = cell2mat(trialsEEG);
    chMean = zeros(nChs, size(trialsEEG{1}, 2));
    chStd = zeros(nChs, size(trialsEEG{1}, 2));
    
    for index = 1:nChs
        chMean(index, :) = mean(temp(index:nChs:length(trialsEEG) * nChs, :), 1);
        chStd(index, :) = std(temp(index:nChs:length(trialsEEG) * nChs, :), [], 1);
    end

    return;
end