function data = dataConvertor(ROOTPATH)
    matFiles = what(ROOTPATH).mat;
    for index = 1:length(matFiles)
        temp = load(fullfile(ROOTPATH, matFiles{index}));
        data(index).trialsData = temp.trialsData;
        data(index).protocol = temp.protocol;
    end
    return;
end