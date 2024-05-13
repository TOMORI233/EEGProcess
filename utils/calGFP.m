function gfp = calGFP(trialsData)

    switch class(trialsData)
        case "cell"
            gfp = cellfun(@(x) sqrt(sum((x - mean(x, 1)) .^ 2, 1) / size(x, 1)), trialsData, "UniformOutput", false);
        case "double"
            gfp = sqrt(sum((trialsData - mean(trialsData, 1)) .^ 2, 1) / size(trialsData, 1));
        otherwise
            error("Invalid data type");
    end

    return;
end