function res = fitBehavior(ratioData, ICIs)
    [xData, yData] = prepareCurveData(ICIs, ratioData);

    y = 0;
    n = 0;

    while y(end) - y(1) < 0.05 && n < 10
        ft = fittype('a/(1+exp(-b*(x-c)))', 'independent', 'x', 'dependent', 'y');
        fitresult = fit(xData, yData, ft);
        x = linspace(ICIs(1), ICIs(end), 1000);
        a = fitresult.a;
        b = fitresult.b;
        c = fitresult.c;
        y = a ./ (1 + exp(-b * (x - c)));
        res = [x; y];
        n = n + 1;
    end

    return;
end