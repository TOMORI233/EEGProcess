%--------------------------to generate single regular click train------------
function [wave, duration, clickOnEdgeIdx, regClickTrainSampN] = generateRegClickTrain(opts)
optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end
if size(ICIs, 1) == 1
    ICIs = ICIs';
end

clickDurN = ceil(clickDur / 1000 * fs); % sample points of click
regICISampN = ceil(ICIs / 1000 * fs); % number of sample points of each ICI
repeatTime = ceil(soundLength ./ ICIs); % repeat time of clicks for each click train 
% number of sample points for each click train
regClickTrainSampN = cellfun(@(x) ones(x(1) + 1, 1) * x(2), array2VectorCell([repeatTime, regICISampN]), 'UniformOutput', false);
% the index of rise edge for each click onset
clickOnEdgeIdx =cellfun(@(x) [0; cumsum(x)], regClickTrainSampN, 'UniformOutput', false);



for n = 1 : length(ICIs)
    wave{n} = zeros(1, ceil(max(clickOnEdgeIdx{n})));
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN, num2cell(clickOnEdgeIdx{n}),'UniformOutput',false);
    for clickN = 1 : length(clickIdx) - 1
        wave{n}(clickIdx{clickN}) = click;
    end
    wave{n} = wave{n}';
    duration(n, 1) = find(wave{n} == 1, 1, 'last' ) / fs * 1000;
end
wave = wave';
