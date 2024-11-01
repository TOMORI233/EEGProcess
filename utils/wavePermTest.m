function [p, dResPerm] = wavePermTest(data1, data2, varargin)
% Perform permutation test on GFP data.
%
% [data1] and [data2] are N-by-S double (N is subject number, S is sample
% number) or T-by-1 cell with elements of C-by-S double (C is channel number).
%
% If [data1] and [data2] are double matrices (GFP data), shuffle at sample
% level between conditions and then average across subjects.
% If [data1] and [data2] are cell arrays (raw trial data of one subject),
% shuffle at trial level → compute ERP → compute GFP.
%
% [Type] specifies which kind of data (ERP or GFP) to compare when the
% input data are raw trial data. (default: 'ERP')
%
% To compare ERP, use `CBPT` for permutation test.
%
% [p] returned as two-tailed (default) or one-tailed p value of the
% permutation test.
% For 'left' tail, the alternative hypothesis is data1<data2, that is if 
% p<0.01, reject the null hypothesis (the desired result is data1<data2).
% If you want data1<data2, use 'left'.
% If you want data1>data2, use 'right'.
% If you want data1~=data2, use 'both'.
%
% [dResPerm] returned as the permuted wave difference matrix (nperm-by-S double).

mIp = inputParser;
mIp.addRequired("data1", @(x) validateattributes(x, {'numeric', 'cell'}, {'2d'}));
mIp.addRequired("data2", @(x) validateattributes(x, {'numeric', 'cell'}, {'2d'}));
mIp.addOptional("nperm", 1e3, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}));
mIp.addParameter("Tail", "both", @(x) any(validatestring(x, {'both', 'left', 'right'})));
mIp.addParameter("Type", "ERP", @(x) any(validatestring(x, {'ERP', 'GFP'})));
mIp.addParameter("chs2Ignore", [], @(x) validateattributes(x, {'numeric'}, {'positive', 'integer', 'vector'}));
mIp.parse(data1, data2, varargin{:});

nperm = mIp.Results.nperm;
Tail = mIp.Results.Tail;
Type = mIp.Results.Type;
chs2Ignore = mIp.Results.chs2Ignore;

if isa(data1, "double") && isa(data2, "double")

    if ~isequal(size(data1), size(data2))
        error("data1 and data2 should be of the same size");
    end

    nSubjects = size(data1, 1);
    data1 = mat2cell(data1, ones(nSubjects, 1));
    data2 = mat2cell(data2, ones(nSubjects, 1));
    Type = "ERP";
end

if iscell(data1) && iscell(data2)

    if ~isequal(size(data1{1}), size(data2{1}))
        error("data1 and data2 should be of the same size");
    end

    if strcmpi(Type, "ERP")
        channels = 1:size(data1{1}, 1);
        t = linspace(0, 1, size(data1{1}, 2)); % normalized
        data(1).time = t(:)';
        data(1).label = arrayfun(@num2str, channels(:), "UniformOutput", false);
        data(1).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), data1, "UniformOutput", false));
        data(1).trialinfo = ones(length(data1), 1);
        data(2).time = t(:)';
        data(2).label = arrayfun(@num2str, channels(:), "UniformOutput", false);
        data(2).trial = cell2mat(cellfun(@(x) permute(x, [3, 1, 2]), data2, "UniformOutput", false));
        data(2).trialinfo = 2 * ones(length(data2), 1);

        cfg = [];
        if strcmpi(Tail, "left")
            cfg.tail = -1;
        elseif strcmpi(Tail, "right")
            cfg.tail = 1;
        else
            cfg.tail = 0;
        end
        cfg.clustertail = cfg.tail;

        stat = CBPT(data);
        p = stat.prob;
        dResPerm = [];
        return;

    elseif strcmpi(Type, "GFP")
        temp = [data1; data2];
        A = length(data1);
        B = length(data2);
        nSample = size(data1{1}, 2);
        [resPerm1, resPerm2] = deal(zeros(nperm, nSample));

        for index = 1:nperm
            shuffleIdx = 1:(A + B);
            shuffleIdx = randperm(length(shuffleIdx));
            resPerm1(index, :) = calGFP(calchMean(temp(shuffleIdx(1:A))), chs2Ignore);
            resPerm2(index, :) = calGFP(calchMean(temp(shuffleIdx(A + 1:A + B))), chs2Ignore);
        end

        wave1 = calGFP(calchMean(data1), chs2Ignore);
        wave2 = calGFP(calchMean(data2), chs2Ignore);
        dWave = wave1 - wave2;

        dResPerm = resPerm1 - resPerm2;

        pLeft = sum(dResPerm < dWave, 1) / nperm; % ratio that supports null hypothesis: x < y
        pRight = sum(dResPerm > dWave, 1) / nperm; % ratio that supports null hypothesis: x > y
        pBoth = min(pLeft, pRight) * 2;

        switch Tail
            case "both"
                p = pBoth;
            case "left"
                p = pLeft;
            case "right"
                p = pRight;
        end

    end

end

return;
end