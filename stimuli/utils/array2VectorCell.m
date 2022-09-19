function res = array2VectorCell(data)
    [m n] = size(data);
    for i = 1:m
        res{i,1} = data(i,:);
    end
end