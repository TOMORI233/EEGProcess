function [p, dResPerm] = wavePermTest(data1, data2, varargin)
% Perform permutation test on average wave data.
% [data1] and [data2] are N-by-S double (N is subject number, S is sample
% number) or T-by-1 cell with elements of C-by-S double (C is channel number).
% If [data1] and [data2] are double matrices (wave), shuffle at sample level between 
% conditions and then average across subjects.
% If [data1] and [data2] are cell arrays (trial data), do permutation test for single
% subject and shuffle at trial level → compute ERP → compute GFP.
% [p] returned as two-tailed (default) or one-tailed p value of the
% permutation test. For 'left' tail, the null hypothesis is data1<data2. In
% this case, if p<0.01 (for example), then reject the null hypothesis (The 
% desired result is data1>data2).
% [dResPerm] returned as the permuted wave difference matrix (nperm-by-S double).

mIp = inputParser;
mIp.addRequired("data1", @(x) validateattributes(x, {'numeric', 'cell'}, {'2d'}));
mIp.addRequired("data2", @(x) validateattributes(x, {'numeric', 'cell'}, {'2d'}));
mIp.addOptional("nperm", 1e3, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}));
mIp.addParameter("Tail", "both", @(x) any(validatestring(x, {'both', 'left', 'right'})));
mIp.addParameter("Type", "ERP", @(x) any(validatestring(x, {'ERP', 'GFP'})));
mIp.parse(data1, data2, varargin{:});

nperm = mIp.Results.nperm;
Tail = mIp.Results.Tail;
Type = mIp.Results.Type;

if isa(data1, "double") && isa(data2, "double")
    disp(['Treat input data as ', char(Type), ' data.']);

    if ~isequal(size(data1), size(data2))
        error("data1 and data2 should be of the same size");
    end

    [nSubjects, nSample] = size(data1);
    [resPerm1, resPerm2] = deal(zeros(nperm, nSample));

    for index = 1:nperm
        shuffleIdx = rand(nSubjects, nSample) > 0.5;
        resPerm1(index, :) = mean(data1 .* shuffleIdx  + data2 .* ~shuffleIdx, 1);
        resPerm2(index, :) = mean(data1 .* ~shuffleIdx + data2 .*  shuffleIdx, 1);
    end

    dWave = mean(data1 - data2, 1);
elseif iscell(data1) && iscell(data2)
    disp("Treat input data as trial data.");

    if ~isequal(size(data1{1}), size(data2{1}))
        error("data1 and data2 should be of the same size");
    end

    if strcmpi(Type, "ERP")
        error("For permutation test on ERP of multi-channel trial data, please use CBPT instead.");
    end
    
    temp = [data1; data2];
    A = length(data1);
    B = length(data2);
    nSample = size(data1{1}, 2);
    [resPerm1, resPerm2] = deal(zeros(nperm, nSample));

    for index = 1:nperm
        shuffleIdx = 1:(A + B);
        shuffleIdx = randperm(length(shuffleIdx));
        resPerm1(index, :) = calGFP(calchMean(temp(shuffleIdx(1:A))));
        resPerm2(index, :) = calGFP(calchMean(temp(shuffleIdx(A + 1:A + B))));
    end

    wave1 = calGFP(calchMean(data1));
    wave2 = calGFP(calchMean(data2));
    dWave = wave1 - wave2;
else
    error("Invalid data type.");
end

dResPerm = resPerm1 - resPerm2;

pLeft = sum(dResPerm > dWave, 1) / nperm;
pRight = sum(dResPerm < dWave, 1) / nperm;
pBoth = min(pLeft, pRight) * 2;

switch Tail
    case "both"
        p = pBoth;
    case "left"
        p = pLeft;
    case "right"
        p = pRight;
end

return;
end