function [evtIdxEEG, evtIdxMATLAB] = trialCorrection(evtCodeEEG, evtCodeMATLAB)

    if isequal(evtCodeEEG, evtCodeMATLAB)
        evtIdxEEG = (1:length(evtCodeEEG))';
        evtIdxMATLAB = (1:length(evtCodeMATLAB))';
        return;
    end

    idxEEG = 1;
    idxMATLAB = 1;
    evtIdxEEG = [];
    evtIdxMATLAB = [];

    while idxEEG <= length(evtCodeEEG) && idxMATLAB <= length(evtCodeMATLAB)

        if evtCodeEEG(idxEEG) == evtCodeMATLAB(idxMATLAB)
            evtIdxEEG = [evtIdxEEG; idxEEG];
            evtIdxMATLAB = [evtIdxMATLAB; idxMATLAB];
            idxMATLAB = idxMATLAB + 1;
        else

            if idxEEG > length(evtCodeEEG) - 9
                return;
            end

            loc = findVectorLoc(evtCodeMATLAB, evtCodeEEG(idxEEG:idxEEG + 9));
            
            while isempty(loc) && idxEEG + 9 <= length(evtCodeEEG)
                idxEEG = idxEEG + 1;
                loc = findVectorLoc(evtCodeMATLAB, evtCodeEEG(idxEEG:idxEEG + 9));
            end

            evtIdxEEG = [evtIdxEEG; idxEEG];
            evtIdxMATLAB = [evtIdxMATLAB; loc];
            disp(['Trial lost: ', num2str(idxMATLAB:loc - 1)]);
            idxMATLAB = loc + 1;
        end

        idxEEG = idxEEG + 1;
    end

    return;
end