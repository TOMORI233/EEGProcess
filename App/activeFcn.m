function trialsData = activeFcn(app)
    parseStruct(app.params);
    pID = app.pIDList(app.pIDIndex);
    dataPath = fullfile(app.dataPath, [datestr(now, 'yyyymmdd'), '-', app.subjectInfo.ID]);
    fsDevice = fs * 1e3;

    [sounds, soundNames, fsSound, controlIdx] = loadSounds(pID);

    % Hint for manual starting
    [hintSound, fsHint] = audioread(['sounds\hint\', num2str(pID), '.mp3']);
    playAudio(hintSound(:, 1)', fsHint, fsDevice);
    KbGet(32, 60);

    sounds = cellfun(@(x) resampleData(reshape(x, [1, length(x)]), fsSound, fsDevice), sounds, 'UniformOutput', false);
    orders0 = 1:length(sounds);
    orders = repmat(orders0(~controlIdx), 1, nRepeat);
    orders = [orders, repmat(orders0(controlIdx), 1, ceil(nRepeat / 3))];
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
    soundName = cell(length(orders), 1);
    codes = 20 * pID + orders;

    mTrigger(triggerType, ioObj, 20 * pID, address);
    WaitSecs(2);

    nMiss = 0;
    
    for index = 1:length(orders)
        PsychPortAudio('FillBuffer', pahandle, repmat(sounds{orders(index)}, 2, 1));
    
        if index == 1
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        else
            PsychPortAudio('Start', pahandle, 1, startTime{index - 1} + ISIs(pID), 1);
        end
        
        % Trigger for EEG recording
        mTrigger(triggerType, ioObj, codes(index), address);

        [startTime{index}, ~, ~, estStopTime{index}] = PsychPortAudio('Stop', pahandle, 1, 1);
        [pressTime{index}, key{index}] = KbGet([37, 39], choiceWin);

        if key{index} == 37 % left arrow
            mTrigger(triggerType, ioObj, 2, address); % diff
        elseif key{index} == 39 % right arrow
            mTrigger(triggerType, ioObj, 3, address); % same
        else
            nMiss = nMiss + 1;
        end

        soundName{index} = soundNames{orders(index)};
        app.StateLabel.Text = strcat(app.protocolList{app.pIDList(app.pIDIndex)}, '(Total: ', num2str(index), '/', num2str(length(orders)), ', Miss: ', num2str(nMiss), ')');
        
        % For termination
        pause(0.1);

        if strcmp(app.status, 'stop')
            break;
        end

    end
    
    PsychPortAudio('Close');
    trialsData = struct('onset', startTime, ...
                        'offset', estStopTime, ...
                        'soundName', soundName, ...
                        'code', num2cell(codes'), ...
                        'push', pressTime, ...
                        'key', key);
    trialsData(cellfun(@isempty, startTime)) = [];
    protocol = app.protocol{pID};

    if ~exist(fullfile(dataPath, [num2str(pID), '.mat']), 'file')
        save(fullfile(dataPath, [num2str(pID), '.mat']), "trialsData", "protocol");
    else
        save(fullfile(dataPath, [num2str(pID), '_redo.mat']), "trialsData", "protocol");
    end

    WaitSecs(5);
    [hintSound, fsHint] = audioread('sounds\hint\end.mp3');
    playAudio(hintSound(:, 1)', fsHint, fsDevice);

    if strcmp(app.status, 'start')

        if pID == app.pIDList(end)
            app.AddSubjectButton.Enable = 'on';
            app.SetParamsButton.Enable = 'on';
            app.StartButton.Enable = 'off';
            app.NextButton.Enable = 'off';
            app.StopButton.Enable = 'off';
            app.PhaseSelectTree.Enable = 'on';
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