temIMG = imread("EEGTopo.png");
eegLayout = temIMG(1:3:end, 1:3:end, :);

save('layout.mat', 'eegLayout');
