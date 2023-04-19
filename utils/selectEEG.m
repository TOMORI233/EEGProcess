function [trialsEEG, chMean, chStd, sampleinfo, reservedIdx] = selectEEG(EEGDataset, trials, window)
    scaleFactor = 1;

    windowIndex = fix(window / 1000 * EEGDataset.fs);
    segIndex = [trials.onset];
    reservedIdx = segIndex + windowIndex(1) > 0 & segIndex + windowIndex(2) < size(EEGDataset.data, 2);
    segIndex = segIndex(reservedIdx);

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