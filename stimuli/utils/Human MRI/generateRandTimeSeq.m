function x = generateRandTimeSeq(durTotal, N, randRange)
%     durTotal = 10; % sec
%     N = 10; % sec
%     randRange = 0.5:0.05:1.5; % sec
    x = zeros(N, 1);

    for i = 1:10
        x(i) = randRange(randperm(length(randRange), 1));
    end
    
    while sum(x) ~= durTotal
        for i = 1:10
            x(i) = randRange(randperm(length(randRange), 1));
        end
    end

    return;
end