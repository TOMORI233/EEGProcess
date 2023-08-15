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

    y = sin(2 * pi * f * (t + tShift))';
    return;
end