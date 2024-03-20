ccc;

resolution = 1/1e4;
mu = 1;
X = (-0.05:resolution:0.05) + mu;
sigma = mu./[2, 100, 200, 400];
Y = arrayfun(@(x) normpdf(X, mu, x)', sigma, "UniformOutput", false);
res = cat(2, X', Y{:});

figure;
mSubplot(1, 1, 1);
hold(gca, "on");
cellfun(@(x) plot(X, x), Y);