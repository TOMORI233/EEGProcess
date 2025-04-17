function [p, h, stats, r] = mSignrank(x, y, varargin)

if isvector(x) && isvector(y)
    x = x(:)';
    y = y(:)';
end

if ~isequal(size(x), size(y))
    error("Samples should be paired");
end

if isequal(x, y)
    p = ones(size(x, 1), 1);
    h = zeros(size(x, 1), 1);
    stats = struct("signedrank", num2cell(zeros(size(x, 1), 1)));
    r = nan(size(x, 1), 1);
    return;
end

% Wilcoxon signed-rank test along rows
[p, h, stats] = rowFcn(@(x1, x2) signrank(x1, x2, varargin{:}), x, y);

% z-value
Z = [stats.zval]';

% remove equal samples
N = rowFcn(@(x1, x2) sum(x1 ~= x2), x, y);

% effect size r
r = Z ./ sqrt(N);

return;
end