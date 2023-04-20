function trialAll = EEGBehaviorProcess(trialsData, EEGDataset, rules)
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
            disp(['Trial ', num2str(cIndex), ' is missing in EEG recording.']);
        else
            nTrial = nTrial + 1;
            rIdx = find([rules.code] == codeMATLAB(cIndex));

            trialAll(nTrial).trialNum = cIndex;
            trialAll(nTrial).code = codeMATLAB(cIndex);
            trialAll(nTrial).onset = evtTrial(tIdx).latency; % sample
            trialAll(nTrial).isControl = rules(rIdx).isControl;
            trialAll(nTrial).type = string(rules(rIdx).type);
            trialAll(nTrial).freq = rules(rIdx).freq;
            trialAll(nTrial).variance = rules(rIdx).variance;
            trialAll(nTrial).ICI = rules(rIdx).ICI;
            trialAll(nTrial).interval = rules(rIdx).interval;
            trialAll(nTrial).ISI = ISI;
        end

    end

    if contains(protocol, "active") % Active
    
        for tIndex = 1:length(trialAll)
            
            if tIndex < length(trialAll)
                idx = find([evtAll.latency] > trialAll(tIndex).onset & [evtAll.latency] < trialAll(tIndex + 1).onset);
            else
                idx = find([evtAll.latency] > trialAll(tIndex).onset);
            end

            temp = [evtAll(idx).type];
            key = temp(find(ismember(temp, [2, 3]), 1));

            if ~isempty(key)
                trialAll(tIndex).push = evtAll(idx).latency;
                trialAll(tIndex).miss = false;

                if key == 2 % diff
                    trialAll(tIndex).isDiff = true;
                elseif key == 3 % same
                    trialAll(tIndex).isDiff = false;
                end

                if (key == 2 && ~trialAll(tIndex).isControl) || (key == 3 && trialAll(tIndex).isControl)
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