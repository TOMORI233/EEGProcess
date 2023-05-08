function res = fitBehavior(ratioData, ICIs)
    [xData, yData] = prepareCurveData(ICIs, ratioData);
    n = 0;

    while n < 20
        ft = fittype('1/(1+exp(-b*(x-c)))', 'independent', 'x', 'dependent', 'y');
        fitresult = fit(xData, yData, ft);
        x = linspace(ICIs(1), ICIs(end), 1000);
        b = fitresult.b;
        c = fitresult.c;
        y = 1 ./ (1 + exp(-b * (x - c)));
        res = [x; y];
        n = n + 1;

        if y(end) - y(1) > 0.5 && y(1) < 0.3 && y(end) > 0.5
            break;
        end

    end

    return;
end