function rules = rulesConfig(TABLEPATH)
    narginchk(0, 1);

    if nargin < 1
        TABLEPATH = fullfile(getRootDirPath(fullfile(fileparts(mfilename("fullpath"))), 1), "rules", "rules.xlsx");
    end

    try
        tb = readtable(TABLEPATH);
    catch
        disp("Configuration file is missing or invalid. Please reselect");
        [file, path] = uigetfile("*.xlsx");
        tb = readtable(fullfile(path, file));
    end

    rules = table2struct(tb);
    return;
end