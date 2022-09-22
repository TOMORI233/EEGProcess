function [idx, idxPN, idxNP] = findZeroPoint(data)
    idx = find(data(1 : end - 1) .* data(2 : end) <= 0);
    idxPN = find(data(1 : end - 1) .* data(2 : end) < 0 & data(1 : end - 1) > 0 | data(1 : end - 1) .* data(2 : end) == 0 & data(2 : end) < 0);
    idxNP = find(data(1 : end - 1) .* data(2 : end) < 0 & data(1 : end - 1) < 0 | data(1 : end - 1) .* data(2 : end) == 0 & data(2 : end) > 0);
end
