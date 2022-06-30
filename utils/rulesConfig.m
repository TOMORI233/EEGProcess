function rulesDefault = rulesConfig()
basicRegICIs = [4, 4.01, 4.02, 4.03, 4.06];

% passive
controlCodes = [31, 36, 61, 66];
regCodes = [31:35, 61:65, 151:157];
regICIs = [basicRegICIs, basicRegICIs, 2:8];
regInts = [zeros(1, 5), 0.5 * ones(1, 5), zeros(1, 7)];
irregCodes = [36, 37, 66, 67, 158:164];
irregICIs = [4, 4.06, 4, 4.06, 2:8];
irregInts = [0, 0, 0.5, 0.5, zeros(1, 7)];

rulesDefault(1).rules = struct("regCodes", regCodes, "regICIs", regICIs, "regInts", regInts, ...
                               "irregCodes", irregCodes, "irregICIs", irregICIs, "irregInts", irregInts, ...
                               "controlCodes", controlCodes);
rulesDefault(1).protocol = "Passive";
rulesDefault(1).codeRange = {[30, 60], [60, 90], [150, 200]};

% active
controlCodes = [91, 96, 121, 126];
regCodes = [91:95, 121:125];
regICIs = [basicRegICIs, basicRegICIs];
regInts = [zeros(1, 5), 0.5 * ones(1, 5)];
irregCodes = [96, 97, 126, 127];
irregICIs = [4, 4.06, 4, 4.06];
irregInts = [0, 0, 0.5, 0.5];

rulesDefault(2).rules = struct("regCodes", regCodes, "regICIs", regICIs, "regInts", regInts, ...
                               "irregCodes", irregCodes, "irregICIs", irregICIs, "irregInts", irregInts, ...
                               "controlCodes", controlCodes);
rulesDefault(2).protocol = "Active";
rulesDefault(2).codeRange = {[90, 120], [120, 150]};