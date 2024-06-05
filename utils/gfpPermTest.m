function [p, dResPerm] = gfpPermTest(gfp1, gfp2, varargin)
% Perform permutation test on GFP data.
% [gfp1] and [gfp2] are N-by-S double (N is subject number, S is sample number).
% [p] returned as two-tailed (default) or one-tailed p value of the
% permutation test. For 'left' tail, the null hypothesis is gfp1<gfp2. In
% this case, if p<0.01 (for example), then reject the null hypothesis (The 
% desired result is gfp1>gfp2).
% [dResPerm] returned as the permuted GFP difference matrix (nperm-by-S double).

mIp = inputParser;
mIp.addRequired("gfp1", @(x) validateattributes(x, {'numeric'}, {'2d'}));
mIp.addRequired("gfp2", @(x) validateattributes(x, {'numeric'}, {'2d'}));
mIp.addOptional("nperm", 1e3, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}));
mIp.addParameter("Tail", "both", @(x) any(validatestring(x, {'both', 'left', 'right'})));
mIp.parse(gfp1, gfp2, varargin{:});

nperm = mIp.Results.nperm;
Tail = mIp.Results.Tail;

if ~isequal(size(gfp1), size(gfp2))
    error("gfp1 and gfp2 should be of the same size");
end

[nSubjects, nSample] = size(gfp1);
[resPerm1, resPerm2] = deal(zeros(nperm, nSample));

for index = 1:nperm
    shuffleIdx = rand(nSubjects, nSample) > 0.5;
    resPerm1(index, :) = mean(gfp1 .* shuffleIdx  + gfp2 .* ~shuffleIdx, 1);
    resPerm2(index, :) = mean(gfp1 .* ~shuffleIdx + gfp2 .*  shuffleIdx, 1);
end
dResPerm = resPerm1 - resPerm2;

pLeft = sum(dResPerm > mean(gfp1 - gfp2, 1), 1) / nperm;
pRight = sum(dResPerm < mean(gfp1 - gfp2, 1), 1) / nperm;
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