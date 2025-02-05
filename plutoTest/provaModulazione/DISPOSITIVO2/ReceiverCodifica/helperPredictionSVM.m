function class = helperPredictionSVM(SNR, BER, SVMModel)
    Xmax = repmat([22,0.5],length(SNR),1);
    Xmin = repmat([0,0],length(SNR),1);
    X = [SNR, BER];
    if X(1)>Xmax(1)
        X(1) = Xmax(1);
    end
    X_scaled = (X - Xmin) ./ (Xmax - Xmin);
    class = predict(SVMModel, X_scaled);
end