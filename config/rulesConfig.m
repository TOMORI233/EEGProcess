function rules = rulesConfig(TABLEPATH)
    narginchk(0, 1);

    if nargin < 1
        TABLEPATH = "D:\Education\Lab\Projects\EEG\ClickTrian Behavior 3\sounds\rules.xlsx";
    end

    try
        tb = readtable(TABLEPATH);
    catch
        disp("Configuration file is not found or invalid. Please reselect");
        [file, path] = uigetfile("*.xlsx");
        tb = readtable(fullfile(path, file));
    end

    rules = table2struct(tb);
    return;
end