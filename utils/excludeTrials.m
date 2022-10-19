function idx = excludeTrials(trialsData, th)
    % Description: exclude trials with sum(Data > mean + 3 * variance | Data < mean - 3 * variance) / length(Data) > th
    % Input:
    %     trialsData: nTrials*1 cell vector with each cell containing an nCh*nSample matrix of data
    %     th: threshold of percentage of bad data
    % Output:
    %     idx: excluded trial index
    % Example:
    %     th = 0.2; % If 20% of data of the trial is not good, exclude it
    %     trialsECOG = selectEcog(ECOGDataset, trials, "dev onset", [-200, 1000]);
    %     idx = excludeTrials(trialsECOG, th);
    %     trialsECOG(idx) = [];
    %     trials(idx) = [];

    narginchk(1, 2);

    if nargin < 2
        th = 0.1;
    end

    temp = changeCellRowNum(trialsData);
    chMean = cell2mat(cellfun(@mean, temp, "UniformOutput", false));
    chStd = cell2mat(cellfun(@std, temp, "UniformOutput", false));
    idx = cellfun(@(x) sum(x > chMean + 3 * chStd | x < chMean - 3 * chStd, 2) / size(x, 2), trialsData, "UniformOutput", false);
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