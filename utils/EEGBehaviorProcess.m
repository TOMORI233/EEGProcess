function trialAll = EEGBehaviorProcess(trialsData, EEGDataset, rules)
    narginchk(2, 3);

    if nargin < 3
        rules = rulesConfig();
    end

    evts = EEGDataset.event;
    fs = EEGDataset.fs; % Hz

    protocol = EEGDataset.protocol;
    rules = rules(cellfun(@string, {rules.protocol}) == EEGDataset.protocol);

    % sIdx = find(ismember([evts.type], [rules.code]));
    % firstSoundOnset = evts(sIdx(2)).latency;
    firstSoundOnset = evts(find([evts.type] == trialsData(1).code, 1)).latency;

    % Abort the first trial
    % trialsData = trialsData(2:end);

    if contains(protocol, "passive") || contains(protocol, "decoding") % Passive/Decoding

        for tIndex = 1:length(trialsData)
            trialAll(tIndex).trialNum = tIndex;
            trialAll(tIndex).onset = firstSoundOnset + fix((trialsData(tIndex).onset - trialsData(1).onset) * fs);
            trialAll(tIndex).offset = firstSoundOnset + fix((trialsData(tIndex).offset - trialsData(1).onset) * fs);
            idx = find([rules.code] == trialsData(tIndex).code);
            trialAll(tIndex).isControl = rules(idx).isControl;
            trialAll(tIndex).type = string(rules(idx).type);
            trialAll(tIndex).freq = rules(idx).freq;
            trialAll(tIndex).variance = rules(idx).variance;
            trialAll(tIndex).ICI = rules(idx).ICI;
            trialAll(tIndex).interval = rules(idx).interval;
        end

    elseif contains(protocol, "active") % Active
    
        for tIndex = 1:length(trialsData)
            trialAll(tIndex).trialNum = tIndex;
            trialAll(tIndex).onset = firstSoundOnset + fix((trialsData(tIndex).onset - trialsData(1).onset) * fs);
            trialAll(tIndex).offset = firstSoundOnset + fix((trialsData(tIndex).offset - trialsData(1).onset) * fs);
            
            if trialsData(tIndex).key ~= 0
                trialAll(tIndex).push = firstSoundOnset + fix((trialsData(tIndex).push - trialsData(1).onset) * fs);
                trialAll(tIndex).miss = false;

                if trialsData(tIndex).key == 37 % diff
                    trialAll(tIndex).isDiff = true;
                elseif trialsData(tIndex).key == 39 % same
                    trialAll(tIndex).isDiff = false;
                else
                    error("Invalid key code");
                end

            else
                trialAll(tIndex).miss = true;
            end
    
            idx = find([rules.code] == trialsData(tIndex).code);
            trialAll(tIndex).isControl = rules(idx).isControl;
            trialAll(tIndex).type = string(rules(idx).type);
            trialAll(tIndex).freq = rules(idx).freq;
            trialAll(tIndex).variance = rules(idx).variance;
            trialAll(tIndex).ICI = rules(idx).ICI;
            trialAll(tIndex).interval = rules(idx).interval;
    
            if ~isempty(trialsData(tIndex).key) && ((trialsData(tIndex).key == 37 && ~trialAll(tIndex).isControl) || (trialsData(tIndex).key == 39 && trialAll(tIndex).isControl))
                trialAll(tIndex).correct = true;
            else
                trialAll(tIndex).correct = false;
            end
    
        end

    else
        error("Invalid protocol ID");
    end

    return;
end