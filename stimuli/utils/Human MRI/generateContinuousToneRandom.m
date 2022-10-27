clear; clc;

fs = 48e3; % Hz
f = [250, 200]; % Hz
durTotal = 10; % sec
N = 10;
randRange = 0.7:0.05:1.3;
rtTime = 2e-3; % sec

try
    load("randTimeSeq.mat");
catch
    randTimeSeq = generateRandTimeSeq(durTotal, N, randRange);
    save("randTimeSeq.mat", "randTimeSeq", "-mat");
end

for sIndex = 1:length(randTimeSeq)

    if sIndex == 1
        y = genRiseFallEdge(generateTone(f(1), randTimeSeq(sIndex), fs, [], "complete"), fs, rtTime, "rise");
    elseif sIndex == length(randTimeSeq)
        y = [y, genRiseFallEdge(generateTone(f(2), randTimeSeq(sIndex), fs, [], "complete"), fs, rtTime, "fall")];
    else
        y = [y, generateTone(f(2 - mod(sIndex, 2)), randTimeSeq(sIndex), fs, [], "complete")];
    end
    
end

audiowrite(['..\..\sounds\MRI usage\', num2str(f(1)), '_', num2str(f(2)), '.wav'], y, fs);

%% Fcn
function [y, t] = generateTone(f, duration, fs, tShift, edgeOpt)
    narginchk(3, 5);

    if nargin < 4 || isempty(tShift)
        tShift = 0;
    end

    if nargin < 5
        edgeOpt = "cut";
    end
    
    switch edgeOpt
        case "cut"
            t = (1:floor(duration * fs)) / fs;
        case "complete"
            t = (1:floor(ceil(duration * f) / f * fs)) / fs;
        otherwise
            error("Invalid edge option input");
    end

    y = sin(2 * pi * f * (t + tShift));
    return;
end

function y = genRiseFallEdge(y, fs, rfTime, rfOpt)
    % Time in sec
    % Frequency in Hz

    narginchk(3, 4);

    if nargin < 4
        rfOpt = "both";
    end

    nRF = fix(rfTime * fs);
    y = reshape(y, [1, length(y)]);

    switch rfOpt
        case "rise"
            y(1:nRF) = y(1:nRF) .* (sin(pi * (0:1 / (nRF - 1):1) - pi / 2) + 1) / 2;
        case "fall"
            y(end - nRF + 1:end) = y(end - nRF + 1:end) .* (sin(pi * (0:1 / (nRF - 1):1) + pi / 2) + 1) / 2;
        case "both"
            y(1:nRF) = y(1:nRF) .* (sin(pi * (0:1 / (nRF - 1):1) - pi / 2) + 1)' / 2;
            y(end - nRF + 1:end) = y(end - nRF + 1:end) .* (sin(pi * (0:1 / (nRF - 1):1) + pi / 2) + 1) / 2;
        otherwise
            error("Invalid rfOpt");
    end

    return;
end