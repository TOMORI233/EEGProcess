function clickTrain = genRegClickTrain(click, duration, ICI, fs)
    nICI = fix(ICI * fs);
    nPeriods = ceil(fix(duration * fs) / nICI);
    nTotal = nPeriods * nICI;
    clickTrain = zeros(nTotal, 1);

    for index = 1:nPeriods
        clickTrain(((index - 1) * nICI + 1):((index - 1) * nICI + length(click))) = 1;
    end

    return;
end