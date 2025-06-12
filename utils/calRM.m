function RM = calRM(trialsData, window, windowRM, rmfcn)
    switch class(trialsData)
        case "cell"
            RM = cellfun(@(x) rmfcn(x), cutData(trialsData, window, windowRM), "UniformOutput", false);
        case "double"
            RM = rmfcn(cutData(trialsData, window, windowRM));
        case "single"
            RM = rmfcn(cutData(trialsData, window, windowRM));
    end
    return;
end