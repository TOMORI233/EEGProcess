function passiveFcn(app)
    parseStruct(app.params);
    pID = app.pIDList(app.pIDIndex);
    dataPath = fullfile(app.dataPath, [datestr(now, 'yyyymmdd'), '-', app.subjectInfo.ID]);
    fsDevice = fs * 1e3;

    [sounds, fsSound] = loadSounds(pID);
    sounds = cellfun(@(x) resampleData(reshape(x, [1, length(x)]), fsSound, fsDevice), sounds, 'UniformOutput', false);
    orders = repmat(1:length(sounds), 1, nRepeat);
    orders = orders(randperm(length(orders)));
    
    reqlatencyclass = 2;
    nChs = 2;
    mode = 1;
    pahandle = PsychPortAudio('Open', [], mode, reqlatencyclass, fsDevice, nChs);
    PsychPortAudio('Volume', pahandle, volumn);
    
    pressTime = cell(length(orders), 1);
    key = cell(length(orders), 1);
    startTime = cell(length(orders), 1);
    estStopTime = cell(length(orders), 1);
    codes = 30 * pID + orders;

    mTrigger(ioObj, address, 30 * pID);
    WaitSecs(2);
    
    for index = 1:length(orders)
        PsychPortAudio('FillBuffer', pahandle, repmat(sounds{orders(index)}, 2, 1));
    
        if index == 1
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        else
            PsychPortAudio('Start', pahandle, 1, startTime{index - 1} + ISIs(pID), 1);
        end
        
        % Trigger for EEG recording
        mTrigger(ioObj, address, codes(index));
        
        [startTime{index}, ~, ~, estStopTime{index}] = PsychPortAudio('Stop', pahandle, 1, 1);

        % For termination
        pause(0.1);

        if strcmp(app.status, 'stop')
            break;
        end

    end
    
    PsychPortAudio('Close');
    data = struct('onset', startTime, 'offset', estStopTime, 'code', num2cell(codes'), 'push', pressTime, 'key', key);
    data(cellfun(@isempty, startTime)) = [];
    protocolName = app.protocolList{pID};

    if ~exist(fullfile(dataPath, [num2str(pID), '.mat']), 'file')
        save(fullfile(dataPath, [num2str(pID), '.mat']), "data", "protocolName");
    else
        save(fullfile(dataPath, [num2str(pID), '_redo.mat']), "data", "protocolName");
    end

    if strcmp(app.status, 'start')

        if pID == app.pIDList(end)
            app.AddSubjectButton.Enable = 'on';
            app.SetParamsButton.Enable = 'on';
            app.StartButton.Enable = 'off';
            app.NextButton.Enable = 'off';
            app.StopButton.Enable = 'off';
            app.StateLabel.Text = '本次试验已完成';
        else
            app.NextButton.Enable = 'on';
            app.timerInit;
            start(app.mTimer);
        end
    
        drawnow;
    end

    return;
end