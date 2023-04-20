function optsDefault = preprocessConfig()
    optsDefault.rules = rulesConfig();
    optsDefault.fhp = 0.5;
    optsDefault.flp = 40;
    optsDefault.DATEStr = []; % To specify a rules_[DATE].xlsx file for this DATE
    return;
end