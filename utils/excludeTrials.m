function idx = excludeTrials(trialsEEG, th)
    narginchk(1, 2);

    if nargin < 2
        th = 0.1;
    end

    temp = changeCellRowNum(trialsEEG);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
    idx = cellfun(@(x) sum(x > chMean + 3 * chStd | x < chMean - 3 * chStd, 2) / size(x, 2), trialsEEG, "UniformOutput", false);
    idx = cellfun(@(x) ~any(x > th), idx);

    if ~isempty(find(~idx, 1))
        idx = find(~idx)';
        disp(['Trial ', num2str(idx), ' excluded.']);
    else
        idx = [];
        disp('All pass');
    end

    return;
end