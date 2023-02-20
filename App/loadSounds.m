function [sounds, fs, controlIdx] = loadSounds(pID)
    folders = dir('sounds\');
    targetFolder = folders(arrayfun(@(x) isequal(str2double(x.name), pID), folders));
    files = dir(fullfile('sounds\', targetFolder.name));
    [~, filenames, exts] = cellfun(@(x) fileparts(x), {files.name}, "UniformOutput", false);
    soundPaths = arrayfun(@(x) fullfile(x.folder, x.name), files(strcmp(exts, '.wav')), "UniformOutput", false);
    controlIdx = contains(filenames(3:end), 'Control');
    [sounds, fs] = cellfun(@audioread, soundPaths, "UniformOutput", false);
    fs = fs{1};
    return;
end