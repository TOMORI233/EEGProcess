function x = generateRandTimeSeq(durTotal, N, randRange)
%     durTotal = 10; % sec
%     N = 20; % sec
%     randRange = 0.3:0.05:0.7; % sec
    x = zeros(N, 1);

    for i = 1:N
        x(i) = randRange(randperm(length(randRange), 1));
    end
    
    while sum(x) ~= durTotal
        for i = 1:N
            x(i) = randRange(randperm(length(randRange), 1));
        end
    end

    return;
end