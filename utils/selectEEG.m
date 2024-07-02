function [trialsEEG, reservedIdx] = selectEEG(EEGDataset, trials, window)
% This function is to segment trials from data recorded by Neuroscan system.
% 
% If you have [data] (chan-by-sample), [fs], [segmentIdx], and [window], use the 
% following script for trial segment:
% >> trialsEEG = arrayfun(@(x) data(:, x + fix(window(1) / 1000 * fs):x + fix(window(2) / 1000 * fs)), segmentIdx, "uni", false);

scaleFactor = 1;

windowIndex = fix(window / 1000 * EEGDataset.fs);
segIndex = [trials.onset];

% Examine index range
reservedIdx = segIndex + windowIndex(1) > 0 & segIndex + windowIndex(2) < size(EEGDataset.data, 2);
if sum(reservedIdx) ~= length(segIndex)
    warning(['Trial ', num2str(find(~reservedIdx)), ' exceeds data range.']);
    segIndex = segIndex(reservedIdx);
end

% Segment by trial
trialsEEG = cell(length(segIndex), 1);
for index = 1:length(segIndex)
    trialsEEG{index} = EEGDataset.data(:, segIndex(index) + windowIndex(1):segIndex(index) + windowIndex(2));
end

% Scale
trialsEEG = cellfun(@(x) x * scaleFactor, trialsEEG, "UniformOutput", false);

return;
end