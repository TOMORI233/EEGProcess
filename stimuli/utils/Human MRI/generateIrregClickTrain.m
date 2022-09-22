%--------------------------to generate single irregular click train------------
function [wave, duration, clickOnEdgeIdx, irregICISampN] = generateIrregClickTrain(opts)
optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

clickDurN = ceil(clickDur / 1000 * fs); % sample points of click


for i = 1 : length(ICIs)
    irregICISampN{i} = irregICISampNBase * ICIs(i) / opts.baseICI;
    idx = find(cumsum(irregICISampN{i}) < ceil(soundLength * fs / 1000));
    idx(end + 1) = idx(end);
    irregICISampN{i} = irregICISampN{i}(idx)';
    clickOnEdgeIdx = [0; cumsum(irregICISampN{i})];
    clickIdx = cellfun(@(x) x+1:1:x+clickDurN,num2cell(ceil(clickOnEdgeIdx)),'UniformOutput',false);
    wave{i} = zeros(1, ceil(max(clickOnEdgeIdx)));
    for j = 1 : length(clickIdx)-1
        wave{i}(clickIdx{j}) = click;
    end
    wave{i} = wave{i}';
    duration(i, 1) = find(wave{i} == Amp, 1, 'last' ) / fs * 1000;
end
wave = wave';
irregICISampN = irregICISampN';

end
