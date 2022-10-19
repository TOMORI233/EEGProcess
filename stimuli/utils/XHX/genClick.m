function click = genClick(duration, fs, riseFallTime)
    narginchk(2, 3);

    if nargin < 3
        riseFallTime = 0;
    end

    nClick = fix(duration * fs);
    nRiseFall = fix(riseFallTime * fs);
    click = ones(nClick, 1);
    click(1:nRiseFall) = click(1:nRiseFall) * (sin(pi * (0:1 / (nRiseFall - 1):1) - pi / 2) + 1) / 2;
    click(end - nRiseFall + 1:end) = click(end - nRiseFall + 1:end) * (sin(pi * (0:1 / (nRiseFall - 1):1) + pi / 2) + 1) / 2;
    return;
end