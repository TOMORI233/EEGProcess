function rules = rulesConfig_20220628()
% passive
controlCodes = [];
regCodes = [151, 152];
regICIs = [4.06, 4.02];
regInts = [0, 0];
irregCodes = [153, 154];
irregICIs = [4.06, 4.02];
irregInts = [0, 0];

rules(1).rules = struct("regCodes", regCodes, "regICIs", regICIs, "regInts", regInts, ...
                               "irregCodes", irregCodes, "irregICIs", irregICIs, "irregInts", irregInts, ...
                               "controlCodes", controlCodes);
rules(1).protocol = "Passive";
rules(1).codeRange = {[150, 200], [200, 250]};

% active
controlCodes = [101, 104];
regCodes = [101, 102, 103];
regICIs = [4, 4.02, 4.06];
regInts = [0.2, 0.2, 0.2];
irregCodes = [104, 105];
irregICIs = [4, 4.06];
irregInts = [0.2, 0.2];

rules(2).rules = struct("regCodes", regCodes, "regICIs", regICIs, "regInts", regInts, ...
                               "irregCodes", irregCodes, "irregICIs", irregICIs, "irregInts", irregInts, ...
                               "controlCodes", controlCodes);
rules(2).protocol = "Active";
rules(2).codeRange = {[50, 100], [100, 150]};