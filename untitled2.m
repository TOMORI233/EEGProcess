srcPaths = dir("..\Figures\coma\**\151\Raw wave-all channels.jpg");
srcPaths = arrayfun(@(x) fullfile(x.folder, x.name), srcPaths, "UniformOutput", false);
[~, temp] = cellfun(@(x) getLastDirPath(x, 2), srcPaths, "UniformOutput", false);
temp = cellfun(@(x) x{1}, temp, "UniformOutput", false);
tarPaths = "..\temp";
tarPaths = cellfun(@(x) strrep(x, fileparts(x), tarPaths), srcPaths, "UniformOutput", false);
tarPaths = cellfun(@(x, y) strrep(x, "Raw wave-all channels", y), tarPaths, temp, "UniformOutput", false);

cellfun(@(x, y) copyfile(x, y), srcPaths, tarPaths);