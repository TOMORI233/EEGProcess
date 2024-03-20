ccc;

FILENAMEs = dir("FigureProcess_*.m");

% move compare script to the end
idx = contains({FILENAMEs.name}, "FigureProcess_Compare");
temp = FILENAMEs(idx);
FILENAMEs(idx) = [];
FILENAMEs = [FILENAMEs; temp];

% move bahavior script to the top
idx = contains({FILENAMEs.name}, "FigureProcess_Bahavior");
temp = FILENAMEs(idx);
FILENAMEs(idx) = [];
FILENAMEs = [temp; FILENAMEs];

% move pre script to the top
idx = contains({FILENAMEs.name}, "FigureProcess_Pre");
temp = FILENAMEs(idx);
FILENAMEs(idx) = [];
FILENAMEs = [temp; FILENAMEs];

FILENAMEs = arrayfun(@(x) fullfile(x.folder, x.name), FILENAMEs, "UniformOutput", false);
script = cellcat(1, join(cellfun(@(x) ['run(''', x, ''');'], FILENAMEs, "UniformOutput", false), newline));

eval(script);