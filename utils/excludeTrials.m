<<<<<<< HEAD
function [trialsEEG, chIdx] = excludeTrials(trialsEEG, th)
=======
function idx = excludeTrials(trialsEEG, th)
    narginchk(1, 2);

    if nargin < 2
        th = 0.1;
    end

>>>>>>> 6b4926c47611e50599dd707cad6a0a81124626a6
    temp = changeCellRowNum(trialsEEG);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
    idx = cellfun(@(x) sum(x > chMean + 3 * chStd | x < chMean - 3 * chStd, 2) / size(x, 2), trialsEEG, "UniformOutput", false);
    chMean2 = mean(chMean, 2);
    chStd2 = std(chMean, 1, 2);
    chIdx = chStd2 <= mean(chStd2) + 3 * std(chStd2);
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

