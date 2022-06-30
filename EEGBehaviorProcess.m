 function [trialsPassive, trialsActive] = EEGBehaviorProcess(EEG, rulesAll)
    narginchk(1, 2);

    if nargin < 2
        rulesAll = rulesConfig();
    end

    eventsAll = EEG.event;
    btns = eventsAll([eventsAll.type] == 2 | [eventsAll.type] == 3);
    fs = EEG.srate; % Hz

    %% passive/decoding
    rules = rulesAll(1).rules;
    idx = zeros(1, length(eventsAll));
    
    for index = 1:length(rulesAll(1).codeRange)
        idx = idx | ([eventsAll.type] > rulesAll(1).codeRange{index}(1) & [eventsAll.type] < rulesAll(1).codeRange{index}(2));
    end

    evts = eventsAll(idx);
    temp = cell(length(evts), 1);
    trialsPassive = struct("trialNum", temp, ...
                     "onset", temp, ...
                     "type", temp, ...
                     "interval", temp, ...
                     "isControl", temp, ...
                     "ICI", temp);

    for tIndex = 1:length(evts)
        trialsPassive(tIndex).trialNum = tIndex;
        trialsPassive(tIndex).onset = evts(tIndex).latency;

        if any(rules.controlCodes == evts(tIndex).type)
            trialsPassive(tIndex).isControl = true;
        else
            trialsPassive(tIndex).isControl = false;
        end

        if any([rules.regCodes] == evts(tIndex).type) % reg
            trialsPassive(tIndex).type = "REG";
            trialsPassive(tIndex).ICI = rules.regICIs([rules.regCodes] == evts(tIndex).type);
            trialsPassive(tIndex).interval = rules.regInts([rules.regCodes] == evts(tIndex).type);
        elseif any([rules.irregCodes] == evts(tIndex).type) % irreg
            trialsPassive(tIndex).type = "IRREG";
            trialsPassive(tIndex).ICI = rules.irregICIs([rules.irregCodes] == evts(tIndex).type);
            trialsPassive(tIndex).interval = rules.irregInts([rules.irregCodes] == evts(tIndex).type);
        else % pure tone
            trialsPassive(tIndex).type = "PT";
            trialsPassive(tIndex).interval = 0;
        end

    end

    %% active
    rules = rulesAll(2).rules;
    idx = zeros(1, length(eventsAll));
    
    for index = 1:length(rulesAll(2).codeRange)
        idx = idx | ([eventsAll.type] > rulesAll(2).codeRange{index}(1) & [eventsAll.type] < rulesAll(2).codeRange{index}(2));
    end

    evts = eventsAll(idx);
    temp = cell(length(evts), 1);
    trialsActive = struct("trialNum", temp, ...
                     "onset", temp, ...
                     "type", temp, ...
                     "isControl", temp, ...
                     "ICI", temp, ...
                     "interval", temp, ...
                     "push", temp, ...
                     "isDiff", temp, ...
                     "correct", temp);

    for tIndex = 1:length(evts)
        trialsActive(tIndex).trialNum = tIndex;
        trialsActive(tIndex).onset = evts(tIndex).latency;

        if tIndex < length(evts)
            firstPush = btns(find([btns.latency] > evts(tIndex).latency & [btns.latency] < evts(tIndex + 1).latency, 1));
        else
            firstPush = btns(find([btns.latency] > evts(tIndex).latency & [btns.latency] < evts(tIndex).latency + 3 * fs, 1));
        end

        if ~isempty(firstPush)
            trialsActive(tIndex).push = firstPush.latency;

            if firstPush.type == 2
                trialsActive(tIndex).isDiff = true;
            else
                trialsActive(tIndex).isDiff = false;
            end

        end

        if any(rules.controlCodes == evts(tIndex).type)
            trialsActive(tIndex).isControl = true;
        else
            trialsActive(tIndex).isControl = false;
        end

        if any([rules.regCodes] == evts(tIndex).type) % reg
            trialsActive(tIndex).type = "REG";
            trialsActive(tIndex).ICI = rules.regICIs([rules.regCodes] == evts(tIndex).type);
            trialsActive(tIndex).interval = rules.regInts([rules.regCodes] == evts(tIndex).type);
        elseif any([rules.irregCodes] == evts(tIndex).type) % irreg
            trialsActive(tIndex).type = "IRREG";
            trialsActive(tIndex).ICI = rules.irregICIs([rules.irregCodes] == evts(tIndex).type);
            trialsActive(tIndex).interval = rules.irregInts([rules.irregCodes] == evts(tIndex).type);
        else % PT
            trialsActive(tIndex).type = "PT";
            trialsActive(tIndex).interval = 0;
        end

        if ~isempty(firstPush) && ((firstPush.type == 2 && ~trialsActive(tIndex).isControl) || (firstPush.type == 3 && trialsActive(tIndex).isControl))
            trialsActive(tIndex).correct = true;
        else
            trialsActive(tIndex).correct = false;
        end

    end

    return;
end