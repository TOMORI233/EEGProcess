function rulesDefault = rulesConfig()
% active section 1
controlTypes = [];

regTypes = [];
regICIs = [];
irregTypes = [];
irregICIs = [];

rulesDefault(1).rules = struct("regTypes", regTypes, "regICIs", regICIs, ...
                               "irregTypes", irregTypes, "irregICIs", irregICIs, ...
                               "controlTypes", controlTypes);
rulesDefault(1).protocol = "Active Section 1";

% active section 2
controlTypes = [101, 104];

regTypes = [101, 102, 103];
regICIs = [4, 4.02, 4.06];
regInts = [0.2, 0.2, 0.2];
irregTypes = [104, 105];
irregICIs = [4, 4.06];
irregInts = [0.2, 0.2, 0.2];

rulesDefault(2).rules = struct("regTypes", regTypes, "regICIs", regICIs, "regInts", regInts, ...
                               "irregTypes", irregTypes, "irregICIs", irregICIs, "irregInts", irregInts, ...
                               "controlTypes", controlTypes);
rulesDefault(2).protocol = "Active Section 2";

% passive
controlTypes = [];

regTypes = [151, 152];
regICIs = [4.06, 4.02];
irregTypes = [153, 154];
irregICIs = [4.06, 4.02];

rulesDefault(3).rules = struct("regTypes", regTypes, "regICIs", regICIs, ...
                               "irregTypes", irregTypes, "irregICIs", irregICIs, ...
                               "controlTypes", controlTypes);
rulesDefault(3).protocol = "Passive";

% decoding
regTypes = 201:207;
regICIs = 2:8;
irregTypes = 208:214;
irregICIs = 2:8;
rulesDefault(4).rules = struct("regTypes", regTypes, "regICIs", regICIs, ...
                               "irregTypes", irregTypes, "irregICIs", irregICIs);
rulesDefault(4).protocol = "Decoding";