function y = insertNoise(y, f, fs, insertPeriod, y_insert)
    periodStartIdx = 1:fs / f:length(y);
    y = [y(1:periodStartIdx(insertPeriod) - 1), y_insert, y(periodStartIdx(insertPeriod):end)];
    return;
end