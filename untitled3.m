ccc;

% 导入电极位置信息
elec = ft_read_sens('C:\Users\TOMORI\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\EEGLAB\functions\supportfiles\Standard-10-5-Cap385.sfp');
EEGPos = EEGPos_Neuroscan64;
idx = ismember(elec.label, EEGPos.channelNames);
elec.chanpos = elec.chanpos(idx, :);
elec.chantype = elec.chantype(idx, :);
elec.chanunit = elec.chanunit(idx, :);
elec.elecpos = elec.elecpos(idx, :);
elec.label = elec.label(idx, :);

X = elec.elecpos(:, 1);
Y = elec.elecpos(:, 2);

figure;
mSubplot(1,1,1,"shape","square-min");
scatter(X, Y, 40, "filled");