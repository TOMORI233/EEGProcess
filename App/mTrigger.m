function mTrigger(ioObj, address, code)
    disp(['Trigger: ', num2str(code)]);
    io64(ioObj, address, code);
    WaitSecs(0.01);
    io64(ioObj, address, 0);
end