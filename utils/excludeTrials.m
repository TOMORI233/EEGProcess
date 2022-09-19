function [trialsEEG, chIdx] = excludeTrials(trialsEEG, th)
    temp = changeCellRowNum(trialsEEG);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
    idx = cellfun(@(x) sum(x > chMean + 3 * chStd | x < chMean - 3 * chStd, 2) / size(x, 2), trialsEEG, "UniformOutput", false);
    chMean2 = mean(chMean, 2);
    chStd2 = std(chMean, 1, 2);
    chIdx = chStd2 <= mean(chStd2) + 3 * std(chStd2);
    idx = cellfun(@(x) ~any(x > th), idx);
    disp(['Trial ', num2str(find(~idx)'), ' are excluded.']);
    trialsEEG = trialsEEG(idx);
    return;
end

