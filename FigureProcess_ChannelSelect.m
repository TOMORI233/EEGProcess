ccc;
% run("config\avgConfig_Neuroscan64.m");
% EEGPos = EEGPos_Neuroscan64;

run("config\avgConfig_Neuracle64.m");
EEGPos = EEGPos_Neuracle64;

gridSize = EEGPos.grid;
chsIgnore = getOr(EEGPos, "ignore");
channelNames = getOr(EEGPos, "channelNames");

Fig = figure;
margins = [0.05, 0.05, 0.1, 0.1];
paddings = [0.1, 0.1, 0.03, 0.06];
maximizeFig(Fig);

for rIndex = 1:gridSize(1)

    for cIndex = 1:gridSize(2)
        chNum = (rIndex - 1) * gridSize(2) + cIndex;

        if chNum > 64 || ismember(chNum, chsIgnore)
            continue;
        end

        mSubplot(Fig, gridSize(1), gridSize(2), EEGPos.map(chNum), [1, 1], margins, paddings);
        xticklabels('');
        yticklabels('');
        if ismember(chNum, chs2Avg)
            scatter(1,1,100,"black","filled");
        end
        title(channelNames{chNum});
    end

end
