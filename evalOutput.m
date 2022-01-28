function [out] = evalOutput(W1, W2, W3, B1, B2, input, maxRange)
        
    input = input / maxRange;

    A1 = (W1*input) + B1;
    O1 = tanh(A1 * 1);
    A2 = (W2*O1) + B2;
    O2 = tanh(A2 * 1);
    out = W3 * O2;
    out = out * (2*pi); % shifted output to output angle in radians

end