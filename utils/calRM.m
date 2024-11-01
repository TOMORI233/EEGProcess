function RM = calRM(trialsData, window, windowRM, rmfcn)
    RM = cellfun(@(x) rmfcn(x), cutData(trialsData, window, windowRM), "UniformOutput", false);
    return;
end