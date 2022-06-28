function [trials1, trials2, trials3, trials4] = EEGBehaviorProcess(EEG, rulesAll)
    narginchk(1, 2);

    if nargin < 2
        rulesAll = rulesConfig();
    end

    eventsAll = EEG.event;
    btnsAll = eventsAll([eventsAll.type] == 1 | [eventsAll.type] == 2);
    fs = EEG.srate; % Hz
    
    %% 50: active section 1
    evts = eventsAll([eventsAll.type] > 50 & [eventsAll.type] < 100);
    temp = cell(length(evts), 1);
    trials1 = struct("trialNum", temp, ...
                     "type", temp, ...
                     "onset", temp, ...
                     "isReg", temp, ...
                     "isControl", temp, ...
                     "ICI", temp, ...
                     "push", temp, ...
                     "correct", temp);

    rules = rulesAll(1).rules;

    for tIndex = 1:length(evts)
        trials1(tIndex, 1).trialNum = tIndex;
        trials1(tIndex, 1).type = evts(tIndex).type;
        trials1(tIndex, 1).onset = evts(tIndex).latency;
        btns = btnsAll([btnsAll.type] == 2); % left arrow, diff

        if tIndex < length(evts)
            firstPush = btns(find([btns.latency] > evts(tIndex).latency & [btns.latency] < evts(tIndex + 1).latency, 1));
        else
            firstPush = btns(find([btns.latency] > evts(tIndex).latency & [btns.latency] < evts(tIndex).latency + 3 * fs, 1));
        end

        if ~isempty(firstPush)
            trials1(tIndex, 1).push = firstPush.latency;
        end

        if any(rules(1).controlTypes == evts(tIndex).type)
            trials1(tIndex, 1).isControl = true;
        else
            trials1(tIndex, 1).isControl = false;
        end

        if any([rules.regTypes] == evts(tIndex).type) % reg
            trials1(tIndex, 1).isReg = true;
            trials1(tIndex, 1).ICI = rules.regICIs([rules.regTypes] == evts(tIndex).type);
        elseif any([rules.irregTypes] == evts(tIndex).type) % irreg
            trials1(tIndex, 1).isReg = false;
            trials1(tIndex, 1).ICI = rules.irregICIs([rules.irregTypes] == evts(tIndex).type);
        else
            error("Undefined type");
        end

        if (~isempty(firstPush) && ~trials1(tIndex).isControl) || (isempty(firstPush) && trials1(tIndex).isControl)
            trials1(tIndex, 1).correct = true;
        else
            trials1(tIndex, 1).correct = false;
        end

    end

    %% 100: active section 2
    evts = eventsAll([eventsAll.type] > 100 & [eventsAll.type] < 150);
    temp = cell(length(evts), 1);
    trials2 = struct("trialNum", temp, ...
                     "type", temp, ...
                     "onset", temp, ...
                     "isReg", temp, ...
                     "isControl", temp, ...
                     "ICI", temp, ...
                     "interval", temp, ...
                     "push", temp, ...
                     "correct", temp);

    rules = rulesAll(2).rules;

    for tIndex = 1:length(evts)
        trials2(tIndex, 1).trialNum = tIndex;
        trials2(tIndex, 1).type = evts(tIndex).type;
        trials2(tIndex, 1).onset = evts(tIndex).latency;
        btns = btnsAll([btnsAll.type] == 2 | [btnsAll.type] == 3);

        if tIndex < length(evts)
            firstPush = btns(find([btns.latency] > evts(tIndex).latency & [btns.latency] < evts(tIndex + 1).latency, 1));
        else
            firstPush = btns(find([btns.latency] > evts(tIndex).latency & [btns.latency] < evts(tIndex).latency + 3 * fs, 1));
        end

        if ~isempty(firstPush)
            trials2(tIndex, 1).push = firstPush.latency;
        end

        if any(rules(1).controlTypes == evts(tIndex).type)
            trials2(tIndex, 1).isControl = true;
        else
            trials2(tIndex, 1).isControl = false;
        end

        if any([rules.regTypes] == evts(tIndex).type) % reg
            trials2(tIndex, 1).isReg = true;
            trials2(tIndex, 1).ICI = rules.regICIs([rules.regTypes] == evts(tIndex).type);
            trials2(tIndex, 1).interval = rules.regInts([rules.regTypes] == evts(tIndex).type);
        elseif any([rules.irregTypes] == evts(tIndex).type) % irreg
            trials2(tIndex, 1).isReg = false;
            trials2(tIndex, 1).ICI = rules.irregICIs([rules.irregTypes] == evts(tIndex).type);
            trials2(tIndex, 1).interval = rules.irregInts([rules.irregTypes] == evts(tIndex).type);
        else
            error("Undefined type");
        end

        if ~isempty(firstPush) && ((firstPush.type == 2 && ~trials2(tIndex).isControl) || (firstPush.type == 3 && trials2(tIndex).isControl))
            trials2(tIndex, 1).correct = true;
        else
            trials2(tIndex, 1).correct = false;
        end

    end

    %% 150: passive
    evts = eventsAll([eventsAll.type] > 150 & [eventsAll.type] < 200);
    temp = cell(length(evts), 1);
    trials3 = struct("trialNum", temp, ...
                     "type", temp, ...
                     "onset", temp, ...
                     "isReg", temp, ...
                     "isControl", temp, ...
                     "ICI", temp);

    rules = rulesAll(3).rules;

    for tIndex = 1:length(evts)
        trials3(tIndex, 1).trialNum = tIndex;
        trials3(tIndex, 1).type = evts(tIndex).type;
        trials3(tIndex, 1).onset = evts(tIndex).latency;

        if any(rules(1).controlTypes == evts(tIndex).type)
            trials3(tIndex, 1).isControl = true;
        else
            trials3(tIndex, 1).isControl = false;
        end

        if any([rules.regTypes] == evts(tIndex).type) % reg
            trials3(tIndex, 1).isReg = true;
            trials3(tIndex, 1).ICI = rules.regICIs([rules.regTypes] == evts(tIndex).type);
        elseif any([rules.irregTypes] == evts(tIndex).type) % irreg
            trials3(tIndex, 1).isReg = false;
            trials3(tIndex, 1).ICI = rules.irregICIs([rules.irregTypes] == evts(tIndex).type);
        else
            error("Undefined type");
        end

    end

    %% 200: decoding
    evts = eventsAll([eventsAll.type] > 200);
    temp = cell(length(evts), 1);
    trials4 = struct("trialNum", temp, ...
                     "type", temp, ...
                     "onset", temp, ...
                     "isReg", temp, ...
                     "ICI", temp);

    rules = rulesAll(4).rules;

    for tIndex = 1:length(evts)
        trials4(tIndex, 1).trialNum = tIndex;
        trials4(tIndex, 1).type = evts(tIndex).type;
        trials4(tIndex, 1).onset = evts(tIndex).latency;

        if any([rules.regTypes] == evts(tIndex).type) % reg
            trials4(tIndex, 1).isReg = true;
            trials4(tIndex, 1).ICI = rules.regICIs([rules.regTypes] == evts(tIndex).type);
        elseif any([rules.irregTypes] == evts(tIndex).type) % irreg
            trials4(tIndex, 1).isReg = false;
            trials4(tIndex, 1).ICI = rules.irregICIs([rules.irregTypes] == evts(tIndex).type);
        else
            error("Undefined type");
        end

    end

end