function res = calBehaviorRes(trialAll)
    trialAll = trialAll(~[trialAll.miss]);
    n = 1;

    %% Regular
    trials = trialAll([trialAll.type] == "REG");

    if ~isempty(trials)
        ICIs = unique([trials.ICI]);
        nTotal = zeros(1, length(ICIs));
        nDiff = zeros(1, length(ICIs));
    
        for index = 1:length(ICIs)
            temp = trials([trials.ICI] == ICIs(index));
            nTotal(index) = length(temp);
            nDiff(index) = sum([temp.isDiff]);
        end
    
        res(n).type = "REG";
        data.nTotal = nTotal;
        data.nDiff = nDiff;
        data.ICI = ICIs;
        res(n).data = data;
        n = n + 1;
    end

    %% Irregular
    trials = trialAll([trialAll.type] == "IRREG");

    if ~isempty(trials)
        ICIs = unique([trials.ICI]);
        nTotal = zeros(1, length(ICIs));
        nDiff = zeros(1, length(ICIs));
    
        for index = 1:length(ICIs)
            temp = trials([trials.ICI] == ICIs(index));
            nTotal(index) = length(temp);
            nDiff(index) = sum([temp.isDiff]);
        end
    
        res(n).type = "IRREG";
        data.nTotal = nTotal;
        data.nDiff = nDiff;
        data.ICI = ICIs;
        res(n).data = data;
        n = n + 1;
    end

    %% Tone
    trials = trialAll([trialAll.type] == "PT");

    if ~isempty(trials)
        freqs = unique([trials.freq]);
        nTotal = zeros(1, length(freqs));
        nDiff = zeros(1, length(freqs));
    
        for index = 1:length(freqs)
            temp = trials([trials.freq] == freqs(index));
            nTotal(index) = length(temp);
            nDiff(index) = sum([temp.isDiff]);
        end
    
        res(n).type = "PT";
        data.nTotal = nTotal;
        data.nDiff = nDiff;
        data.freq = freqs;
        res(n).data = data;
    end

    return;
end