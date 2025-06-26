function trialAll = generalProcessFcn(trialsData, rules, controlIdx)
    % This function is to process trial data recorded by EEG App

    narginchk(2, 3);

    if nargin < 3
        controlIdx = []; % number
    end

    if isempty(trialsData)
        trialAll = [];
        return;
    end

    trialAll = struct("trialNum", num2cell((1:length(trialsData))'));
    idx = arrayfun(@(x) find(rules.code == x), [trialsData.code]');
    for vIndex = 1:length(rules.Properties.VariableNames)
        paramName = rules.Properties.VariableNames{vIndex};
        trialAll = addfield(trialAll, paramName, ...
                              rules(idx, :).(paramName));
    end
    trialAll = addfield(trialAll, "RT", arrayfun(@(x) x.push - x.offset, trialsData(:), "UniformOutput", false));
    trialAll = addfield(trialAll, "key", {trialsData.key}');

    if ~isempty(controlIdx)

        for tIndex = 1:length(trialsData)
            idx = find(rules.code == trialsData(tIndex).code);
    
            if isempty(trialAll(tIndex).key)
                continue;
            end
        
            if trialsData(tIndex).key == 0
                trialAll(tIndex).correct = false;
                trialAll(tIndex).miss = true;
                trialAll(tIndex).RT = inf;
            else
                trialAll(tIndex).miss = false;

                if (~ismember(idx, controlIdx) && trialsData(tIndex).key == 37) || (ismember(idx, controlIdx) && trialsData(tIndex).key == 39)
                    trialAll(tIndex).correct = true;
                else
                    trialAll(tIndex).correct = false;
                end

                trialAll(tIndex).RT = trialsData(tIndex).push - trialsData(tIndex).offset;
            end

        end

    end

    return;
end