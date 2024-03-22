ccc;

%% 
colors = cellfun(@(x) x / 255, {[200 200 200], [0 0 0], [0 0 255], [255 128 0], [255 0 0]}, "UniformOutput", false);

%% 
resolution = 1/1e4;
mu = 1;
X = (-0.05:resolution:0.05) + mu;
sigma = mu./[2, 100, 200, 400];
Y = arrayfun(@(x) normpdf(X, mu, x)', sigma, "UniformOutput", false);
res = cat(2, X', Y{:});
colors = colors(1:length(Y));

figure;
mSubplot(1, 1, 1);
hold(gca, "on");
cellfun(@(a, b, c) plot(X, a, "Color", c, "LineWidth", 2, "DisplayName", b), ...
        Y, ...
        arrayfun(@(x) strrep(rats(x), ' ', ''), sigma, "UniformOutput", false), ...
        colors);
set(gca, "XLimitMethod", "tight");
legend;