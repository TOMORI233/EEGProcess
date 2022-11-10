function [wave, clickOnEdgeIdx, irregSampN] = repIrregByReg(irregSampN, regSampN, opts)

if length(irregSampN) ~= length(regSampN)
    error('input argument 1 and 2 have different length');
end

optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

clickDurN = ceil(clickDur / 1000 * fs);

switch pos
    case 'head'
        for i = 1 : length(irregSampN)
            irregSampN{i}(1 : repN) = regSampN{i}(1);
        end
    case 'tail'
        for i = 1 : length(irregSampN)
            irregSampN{i}((end - repN + 1) : end) = regSampN{i}(1);
        end
end

for i = 1 : length(irregSampN)
    clickOnEdgeIdx = [0; cumsum(irregSampN{i})];
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN,num2cell(ceil(clickOnEdgeIdx)),'UniformOutput',false);
    wave{i} = zeros(1, ceil(max(clickOnEdgeIdx)));
    for j = 1 : length(clickIdx) - 1
        wave{i}(clickIdx{j}) = click;
    end
    wave{i} = wave{i}';
end
wave = wave';

end

    

