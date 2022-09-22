function res = mergeSingleWave(s1Wave, s2Wave, interval, opts, reverseFlag)
% interval unit : ms
% if reverseFlag is true, the function conduct both s1s2 mergence and s2s1 mergence
narginchk(4, 5);
if nargin < 5
    reverseFlag = 0;
end


optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

intSampN = zeros(ceil(interval / 1000 * fs), 1);
s1s2 = cellfun(@(x) [x{1}; intSampN; x{2}], array2VectorCell([s1Wave s2Wave]), 'UniformOutput', false);
s1Duration = cellfun(@(x) find(x == 1, 1 , 'last') / fs * 1000, s1Wave, 'UniformOutput', false);
s1End = cellfun(@(x) length(x) / fs * 1000, s1Wave, 'UniformOutput', false);
s1Str = cellfun(@(x) strcat(num2str(x), 'ms'), num2cell(repmat(ICIs(1), size(s1Wave, 1), 1)) , 'UniformOutput', false);
s2Str = cellfun(@(x) strcat(num2str(x), 'ms'), num2cell(ICIs(2 : end)) , 'UniformOutput', false);
res = struct('s1s2', s1s2, 's1Duration', s1Duration, 's1End', s1End, 's1Str', s1Str, 's2Str', s2Str, 'interval', num2cell(repmat(interval, size(s1Wave, 1), 1)));

if reverseFlag
    s2s1 = cellfun(@(x) [x{1}; x{2}], array2VectorCell([s2Wave s1Wave]), 'UniformOutput', false);
    s2Duration = cellfun(@(x) find(x == 1, 1 , 'last') / fs * 1000, s2Wave, 'UniformOutput', false);
    s2End = cellfun(@(x) length(x) / fs * 1000, s2Wave, 'UniformOutput', false);
    res = addFieldToStruct(res, {'s2s1'; 's2Duration'; 's2End'}, [s2s1 s2Duration s2End]);
end
end