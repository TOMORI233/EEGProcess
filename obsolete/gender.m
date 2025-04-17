ccc;

temp = dir("..\DATA\MAT DATA\pre");
temp = temp(3:end);
subjectIDs = {temp.name}';

tb = readtable("F:\EEG\Neuroscan\DATA\被试信息.xlsx", "Sheet", "Sheet1");

for index = 1:length(subjectIDs)
    genders{index, 1} = tb.Var4(strcmp(tb.Var2, subjectIDs{index}));
end

genders = cellfun(@(x) replaceVal(x, 1, @(x) strcmp(x, '男')), genders, "UniformOutput", false);
genders = cellfun(@(x) replaceVal(x, 2, @(x) strcmp(x, '女')), genders, "UniformOutput", false);
genders = cell2mat(genders);

save("gender.mat", "genders", "subjectIDs");