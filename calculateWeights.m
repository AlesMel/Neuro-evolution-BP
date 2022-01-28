function [W1, W2, W3, B1, B2] = calculateWeights(pop, params, hiddenLayer)
    % transformation of a chromozome to a matrices of weights

    for i = 1:length(hiddenLayer(1))  % 1 -> 20, 21 - > 40, ... -> 
        s1 = (i - 1) * params(1) + 1;
        s2 = s1 + params(1) - 1;
        W1(i, :) = pop(s1:s2); % where does the first weight begin
    end
    
    s02=s2;
    
    for r=1:length(hiddenLayer(2))
        s1 = s02+(r-1)*hiddenLayer(2)+1;
        s2 = s1+hiddenLayer(2)-1;
        W2(r,:) = pop(s1:s2);
    end
    
    s02=s2;
    
    for r=1:1
        s1 = s02+(r-1)*hiddenLayer(2)+1;
        s2 = s1+hiddenLayer(2)-1;
        W3(r,:) = pop(s1:s2);
    end

    B1 = pop((s2+1):(s2+hiddenLayer(1)))';  % bias of the 1. layer
    B2 = pop((s2+hiddenLayer(1)+1):(s2+hiddenLayer(1)+hiddenLayer(2)))';  % bias of the 2. layer

end