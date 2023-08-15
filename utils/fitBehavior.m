function res = fitBehavior(Y, X)
    [xData, yData] = prepareCurveData(X, Y);
    n = 0;

    while n < 20
        ft = fittype('1/(1+exp(-b*(x-c)))', 'independent', 'x', 'dependent', 'y');
        fitresult = fit(xData, yData, ft);
        x = linspace(X(1), X(end), 1000);
        b = fitresult.b;
        c = fitresult.c;
        y = 1 ./ (1 + exp(-b * (x - c)));
        res = [x; y];
        n = n + 1;

        if y(end) - y(1) > 0.4 && y(1) < 0.2 && y(end) > 0.6
            break;
        end

    end

    return;
end