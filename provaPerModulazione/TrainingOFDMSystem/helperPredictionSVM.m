function class = helperPredictionSVM(SNR, BER, SVMModel)
    xmax = [25, 0.5];
    xmin = [0, 0];
    X = [SNR, BER];
    X_scaled = (X - xmin) ./ (xmax - xmin);
    class = predict(SVMModel, X_scaled);
end