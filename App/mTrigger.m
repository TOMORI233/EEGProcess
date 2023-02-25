function mTrigger(triggerType, ioObj, code, address)
    disp(['Trigger: ', num2str(code)]);

    if strcmpi(triggerType, 'LTP')
        % For curry8 and LTP test
        io64(ioObj, address, code);
        WaitSecs(0.01);
        io64(ioObj, address, 0);
    elseif strcmpi(triggerType, 'triggerBox')
        % For neuracle
        ioObj.OutputEventData(code);
    else
        error('Invalid trigger type.');
    end

end