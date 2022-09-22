function ICINIrreg = irregICISampN(opts)


optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end

soundLength =  opts.soundLength * opts.baseICI / min(ICIs); % ms
intervalMin = 0.3; % min ICI
intervalMax = 1.7; % max ICI
adjacentMin = 0.2; % ms, min interval between two clicks
ICICheckWin = 2;



rollN = ceil(soundLength / trainLength);
ICINIrreg = num2cell(ones(1 , rollN));
repeatTime = ceil(trainLength / baseICI);
baseICIN = baseICI / 1000 * fs;

while std(cell2mat(ICINIrreg(1 : rollN))) / baseICIN < 0.9 / sigmaPara || std(cell2mat(ICINIrreg(1 : rollN))) / baseICIN > 1.1 / sigmaPara
    for jj = 1 : rollN
        disp(['generate round ' num2str(jj) ' , please waiting']);
        seqIdx = ceil((0 : repeatTime) * baseICI / 1000 * fs);
        buffer = [0 0 0 0];
        while any([buffer < baseICIN * intervalMin   buffer > baseICIN * intervalMax  std(buffer)< 0.9*(baseICIN/sigmaPara)  std(buffer)> 1.1*(baseICIN / sigmaPara) ])
            buffer = floor(normrnd(baseICIN , baseICIN / sigmaPara , 1, repeatTime));
            buffer(end) = buffer(end) - (sum(buffer) - baseICIN * (repeatTime));
        end

        for ii = 1 : 10
            for i = 1 : 100
                buffer2{i,ii} = buffer(randperm(length(buffer)));
                inValidN0(i,ii) = ~any(sumSlideWin(buffer2{i,ii} , ICICheckWin) < baseICIN * intervalMin * ICICheckWin * 2) & ~any(sumSlideWin(buffer2{i,ii} , ICICheckWin) > baseICIN * intervalMax * ICICheckWin * 0.9) & ~any(sumSlideWin(buffer2{i,ii} , ICICheckWin + 1) < baseICIN * intervalMin * (ICICheckWin + 1) * 2) & ~any(sumSlideWin(buffer2{i,ii} , ICICheckWin) > baseICIN * intervalMax * (ICICheckWin + 1) * 0.9);
                try
                    inValidN(i,ii) = inValidN0(i,ii) * sum(abs(diff(find(abs(diff(buffer2{i,ii})) < baseICIN * adjacentMin))));
                catch
                    continue
                end
            end

        end

        Idx = find(inValidN == max(max(inValidN)));
        Idx = Idx(1);
        buffer = buffer2{Idx};
        ICINIrreg{jj} = buffer;

    end
end
end

function res = sumSlideWin(data,winSize)
    narginchk(2,2);
    if max(size(data)) < winSize
        error('length of longest dimention is smallize than winSize');
    else
        for q = 1 : length(data) - (winSize - 1)
            res(q) = sum(data(q : q + winSize - 1));
        end
    end
end

