function class = helperPredictionSVM(SNR, BER, SVMModel)
%HELPERPREDICTIONSVM    La funzione classifica il canale utilizzando un
%modello di machine learning pre-trained SVM. Si considerano come SNRmax e
%SNRmin rispettivamente 22 e 0, sulla base dei risultati empirici. Il BER
%spazia da 0 a 0.5. Il modello SVM restituisce in uscita 3 possibili stati
%della comunicazione:
% 0 --> canale pessimo
% 1 --> canale discreto
% 2 --> canale ottimo
% Si consideri che lo stato 2 è molto più raro perché necessita di valori
% di SNR e BER rispettivamente molto alti e molto bassi.

    Xmax = repmat([22,0.5],length(SNR),1);
    Xmin = repmat([0,0],length(SNR),1);
    X = [SNR, BER];

    % Se il SNR ricevuto eccede il massimo, lo si pone uguale al
    % massimo
    if X(1)>Xmax(1)
        X(1) = Xmax(1);
    end

    % Scaling minMax
    X_scaled = (X - Xmin) ./ (Xmax - Xmin);
    
    %Previsione fatta dal modello SVM
    class = predict(SVMModel, X_scaled);
end