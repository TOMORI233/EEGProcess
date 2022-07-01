function trialAll = EEGBehaviorProcess2(trialsData, EEGDataset, pID, rulesAll)
    narginchk(3, 4);

    if nargin < 4
        rulesAll = rulesConfig();
    end

    evts = EEGDataset.event;
    fs = EEGDataset.fs; % Hz

    switch pID
        case 1
            firstSoundOnset = evts(find([evts.type] == rulesAll(1).codeRange{1}(1)) + 1).latency;
        case 2
            firstSoundOnset = evts(find([evts.type] == rulesAll(1).codeRange{2}(1)) + 1).latency;
        case 3
            firstSoundOnset = evts(find([evts.type] == rulesAll(2).codeRange{1}(1)) + 1).latency;
        case 4
            firstSoundOnset = evts(find([evts.type] == rulesAll(2).codeRange{2}(1)) + 1).latency;
        case 5
            firstSoundOnset = evts(find([evts.type] == rulesAll(1).codeRange{3}(1)) + 1).latency;
        otherwise
            error("Invalid protocol ID");
    end

    temp = cell(length(trialsData), 1);

    if pID == 1 || pID == 2 || pID == 5 % Passive/Decoding
        rules = rulesAll(1).rules;
        trialAll = struct("trialNum", temp, ...
                          "onset", temp, ...
                          "offset", temp, ...
                          "type", temp, ...
                          "interval", temp, ...
                          "isControl", temp, ...
                          "ICI", temp);

        for tIndex = 1:length(trialsData)
            trialAll(tIndex).trialNum = tIndex;
            trialAll(tIndex).onset = firstSoundOnset + fix((trialsData(tIndex).onset - trialsData(1).onset) * fs);
            trialAll(tIndex).offset = firstSoundOnset + fix((trialsData(tIndex).offset - trialsData(1).onset) * fs);
    
            if any(rules.controlCodes == trialsData(tIndex).code)
                trialAll(tIndex).isControl = true;
            else
                trialAll(tIndex).isControl = false;
            end
    
            if any([rules.regCodes] == trialsData(tIndex).code) % reg
                trialAll(tIndex).type = "REG";
                trialAll(tIndex).ICI = rules.regICIs([rules.regCodes] == trialsData(tIndex).code);
                trialAll(tIndex).interval = rules.regInts([rules.regCodes] == trialsData(tIndex).code);
            elseif any([rules.irregCodes] == trialsData(tIndex).code) % irreg
                trialAll(tIndex).type = "IRREG";
                trialAll(tIndex).ICI = rules.irregICIs([rules.irregCodes] == trialsData(tIndex).code);
                trialAll(tIndex).interval = rules.irregInts([rules.irregCodes] == trialsData(tIndex).code);
            else % pure tone
                trialAll(tIndex).type = "PT";
                trialAll(tIndex).ICI = 0;
                trialAll(tIndex).interval = 0;
            end
    
        end

    elseif pID == 3 || pID == 4 % Active
        rules = rulesAll(2).rules;
        trialAll = struct("trialNum", temp, ...
                          "onset", temp, ...
                          "offset", temp, ...
                          "type", temp, ...
                          "isControl", temp, ...
                          "ICI", temp, ...
                          "interval", temp, ...
                          "push", temp, ...
                          "miss", temp, ...
                          "isDiff", temp, ...
                          "correct", temp);
    
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
    
            if any(rules.controlCodes == trialsData(tIndex).code)
                trialAll(tIndex).isControl = true;
            else
                trialAll(tIndex).isControl = false;
            end
    
            if any([rules.regCodes] == trialsData(tIndex).code) % reg
                trialAll(tIndex).type = "REG";
                trialAll(tIndex).ICI = rules.regICIs([rules.regCodes] == trialsData(tIndex).code);
                trialAll(tIndex).interval = rules.regInts([rules.regCodes] == trialsData(tIndex).code);
            elseif any([rules.irregCodes] == trialsData(tIndex).code) % irreg
                trialAll(tIndex).type = "IRREG";
                trialAll(tIndex).ICI = rules.irregICIs([rules.irregCodes] == trialsData(tIndex).code);
                trialAll(tIndex).interval = rules.irregInts([rules.irregCodes] == trialsData(tIndex).code);
            else % PT
                trialAll(tIndex).type = "PT";
                trialAll(tIndex).ICI = 0;
                trialAll(tIndex).interval = 0;
            end
    
            if ~isempty(trialsData(tIndex).key) && ((trialsData(tIndex).key == 37 && ~trialAll(tIndex).isControl) || (trialsData(tIndex).key == 39 && trialAll(tIndex).isControl))
                trialAll(tIndex).correct = true;
            else
                trialAll(tIndex).correct = false;
            end
    
        end

    end

    return;
end