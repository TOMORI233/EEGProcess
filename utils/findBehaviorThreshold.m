function thICI = findBehaviorThreshold(fitRes, thBeh)
    x = fitRes(1, :);
    y = fitRes(2, :);
    idx = find(y >= thBeh, 1);

    if isempty(idx)
        thICI = max(x);
    else
        thICI = x(idx);
    end

    return;
end