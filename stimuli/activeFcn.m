function data = activeFcn(pID, nRepeat, ISI, choiceWin, fsDevice, deviceID, volumn, ioObj, address)
    [sounds, fsSound] = loadSounds(pID);
    sounds = cellfun(@(x) resampleData(reshape(x, [1, length(x)]), fsSound, fsDevice), sounds, 'UniformOutput', false);
    orders = repmat(1:(length(sounds) - 2), 1, nRepeat);
    orders = [orders, repmat((length(sounds) - 1):length(sounds), 1, ceil(nRepeat / 3))];
    orders = orders(randperm(length(orders)));
    
    reqlatencyclass = 2;
    nChs = 2;
    mode = 1;
    pahandle = PsychPortAudio('Open', deviceID, mode, reqlatencyclass, fsDevice, nChs);
    PsychPortAudio('Volume', pahandle, volumn);
    
    pressTime = cell(length(orders), 1);
    key = cell(length(orders), 1);
    startTime = cell(length(orders), 1);
    estStopTime = cell(length(orders), 1);
    codes = 30 * pID + orders;
    
    for index = 1:length(orders)
        disp(['Trial - ', num2str(index), '/', num2str(length(orders))]);
        PsychPortAudio('FillBuffer', pahandle, repmat(sounds{orders(index)}, 2, 1));
    
        if index == 1
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        else
            PsychPortAudio('Start', pahandle, 1, startTime{index - 1} + ISI, 1);
        end
        
        mTrigger(ioObj, address, codes(index));
        [startTime{index}, ~, ~, estStopTime{index}] = PsychPortAudio('Stop', pahandle, 1, 1);
        [pressTime{index}, key{index}] = KbGet([37, 39], choiceWin);

        if key{index} == 37
            mTrigger(ioObj, address, 2); % diff
        elseif key{index} == 39
            mTrigger(ioObj, address, 3); % same
        end
        
    end
    
    PsychPortAudio('Close');
    data = struct('onset', startTime, 'offset', estStopTime, 'code', num2cell(codes'), 'push', pressTime, 'key', key);
    return;
end