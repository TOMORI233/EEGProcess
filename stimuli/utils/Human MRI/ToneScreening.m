clear; clc;

fs = 48e3; % Hz
f = [88,125,177,250,354,500,707,1000,1414,2000,2828,4000,5657,8000]; % Hz
duration = 2; % sec
rtTime = 5e-3; % sec

A = zeros(length(f), 1);
A(1) = 1;

y0 = generateTone(f(1), duration, fs, [], "complete");
y = genRiseFallEdge(y0, fs, rtTime, "rise");
for index = 2:length(f) - 1
    temp = generateTone(f(index), duration, fs, [], "complete");
    A(index) = f(1)^2*norm(y0(1:fix(fs/f(1))))^2 / (f(index)^2*norm(temp(1:fix(fs/f(index))))^2);
    y = [y, A(index) * temp];
end
A(end) = f(1)^2*norm(y0(1:fix(fs/f(1))))^2 / (f(end)^2*norm(temp(1:fix(fs/f(end))))^2);
y = [y, genRiseFallEdge(A(end) * generateTone(f(end), duration, fs, [], "complete"), fs, rtTime, "fall")];

figure;
plot(y);

% playAudio(y, fs);
audiowrite('..\..\sounds\MRI usage\Tone Screening.wav', y, fs);

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