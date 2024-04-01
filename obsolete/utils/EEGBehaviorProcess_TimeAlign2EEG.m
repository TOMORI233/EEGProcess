function trialAll = EEGBehaviorProcess_TimeAlign2EEG(trialsData, EEGDataset, rules)
    narginchk(2, 3);

    if nargin < 3
        rules = rulesConfig();
    end

    maxError = 1; % For adjusting, sec

    evtAll = EEGDataset.event;
    fs = EEGDataset.fs; % Hz
    protocol = EEGDataset.protocol;
    rules = rules(cellfun(@string, {rules.protocol}) == EEGDataset.protocol);
    ISI = rules(1).ISI; % sec
    evtAll = evtAll(find(ismember([evtAll.type], [rules.code]), 1):end);
    codeEEG = [evtAll.type]';
    codeMATLAB = [trialsData.code]';
    trialsData = trialsData(find(codeMATLAB == codeEEG(1), 1):end);
    codeMATLAB = [trialsData.code]';
    evtTrial = evtAll(ismember([evtAll.type], [rules.code]));
    trialOnsetEEG = [evtTrial.latency]';
    trialOnsetMATLAB = fix(([trialsData.onset]' - trialsData(1).onset) * fs) + trialOnsetEEG(1);

    nTrial = 1;
    lostTrialIdx = false(length(trialsData), 1);
    rIdx = find([rules.code] == codeMATLAB(1));
    trialAll(1).trialNum = 1;
    trialAll(1).code = codeMATLAB(1);
    trialAll(1).onset = evtAll(1).latency;
    trialAll(1).isControl = rules(rIdx).isControl;
    trialAll(1).type = string(rules(rIdx).type);
    trialAll(1).freq = rules(rIdx).freq;
    trialAll(1).variance = rules(rIdx).variance;
    trialAll(1).ICI = rules(rIdx).ICI;
    trialAll(1).interval = rules(rIdx).interval;
    trialAll(1).ISI = ISI;

    for cIndex = 2:length(codeMATLAB)
        tIdx = find(trialOnsetEEG >= trialOnsetMATLAB(cIndex) - fix(maxError * fs) & trialOnsetEEG <= trialOnsetMATLAB(cIndex) + fix(maxError * fs), 1);
        
        if isempty(tIdx) || ~isequal(evtTrial(tIdx).type, codeMATLAB(cIndex))
            lostTrialIdx(cIndex) = true;
        else
            nTrial = nTrial + 1;
            rIdx = find([rules.code] == codeMATLAB(cIndex));

            trialAll(nTrial, 1).trialNum = cIndex;
            trialAll(nTrial, 1).code = codeMATLAB(cIndex);
            trialAll(nTrial, 1).onset = evtTrial(tIdx).latency; % sample
            trialAll(nTrial, 1).isControl = rules(rIdx).isControl;
            trialAll(nTrial, 1).type = string(rules(rIdx).type);
            trialAll(nTrial, 1).freq = rules(rIdx).freq;
            trialAll(nTrial, 1).variance = rules(rIdx).variance;
            trialAll(nTrial, 1).ICI = rules(rIdx).ICI;
            trialAll(nTrial, 1).interval = rules(rIdx).interval;
            trialAll(nTrial, 1).ISI = ISI;
        end

    end

    if any(lostTrialIdx)
        disp(['Trials lost in EEG recording: ', num2str(find(lostTrialIdx'))]);
    end

    if contains(protocol, "active") % Active
        trialsData(lostTrialIdx) = [];
        pushTimeAll = fix(([trialsData.push]' - trialsData(1).onset) * fs) + trialAll(1).onset;
        keys = [trialsData.key]';
    
        for tIndex = 1:length(trialAll)
            
            if tIndex < length(trialAll)
                idx = find(pushTimeAll > trialAll(tIndex).onset & pushTimeAll < trialAll(tIndex + 1).onset, 1);
            else
                idx = find(pushTimeAll > trialAll(tIndex).onset, 1);
            end

            key = keys(idx);
            key(key == 0) = [];

            if ~isempty(key)
                trialAll(tIndex).push = pushTimeAll(idx);
                trialAll(tIndex).miss = false;

                if key == 37 % diff
                    trialAll(tIndex).isDiff = true;
                elseif key == 39 % same
                    trialAll(tIndex).isDiff = false;
                end

                if (key == 37 && ~trialAll(tIndex).isControl) || (key == 39 && trialAll(tIndex).isControl)
                    trialAll(tIndex).correct = true;
                else
                    trialAll(tIndex).correct = false;
                end

            else
                trialAll(tIndex).miss = true;
                trialAll(tIndex).correct = false;
            end

        end

    end

    return;
end