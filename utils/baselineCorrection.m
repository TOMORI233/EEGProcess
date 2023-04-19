function trialsEEG = baselineCorrection(trialsEEG, fs, window, windowBase)
    tBaseIdx = fix((windowBase(1) - window(1)) * fs / 1000) + 1:fix((windowBase(2) - window(1)) * fs / 1000);
    trialsEEG = cellfun(@(x) x - mean(x(:, tBaseIdx), 2), trialsEEG, "UniformOutput", false);
    return;
end