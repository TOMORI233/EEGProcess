function exportSoundFile(waveData, opts)

optsNames = fieldnames(opts);
for index = 1:size(optsNames, 1)
    eval([optsNames{index}, '=opts.', optsNames{index}, ';']);
end
ICIName = reshape(ICIName, length(ICIName), 1);

if length(ICIName) ~= length(waveData)
    error('size ICIName differ from size waveData !!!');
end

disp(['find ', num2str(length(waveData)), ' sound waves to exported ...']);

if ~exist(fullfile(rootPath, folderName), 'dir')
    mkdir(fullfile(rootPath, folderName));
end

for i = 1 : length(waveData)
    disp(['exporting wave ', strrep(fileNameTemp, fileNameRep, num2str(ICIName(i))), ' ...']);
    fileName = strrep(fullfile(rootPath, folderName, fileNameTemp), fileNameRep, num2str(ICIName(i)));
    audiowrite(fileName, waveData{i}, fs);
end
end