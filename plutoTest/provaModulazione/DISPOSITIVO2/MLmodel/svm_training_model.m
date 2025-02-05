clear;

function X_scaled = minmax_scale(X)
    % MINMAX_SCALE Normalizza i dati utilizzando la scala min-max.
    %   X_scaled = minmax_scale(X) normalizza ogni feature di X nell'intervallo [0, 1].
    
    X_min = min(X);
    X_max = max(X);
    X_scaled = (X - X_min) ./ (X_max - X_min);
end

% Carica i dati (assumendo che siano in un file CSV)
data = readtable('dati_classificati.csv');

% Estrai le features e il target
features = {'SNR', 'BER'};
X = data(:, features);
y = data.Classe;

% Normalizza i dati

X_scaled = minmax_scale(X);

% Suddividi i dati in training e test set
cv = cvpartition(size(X_scaled,1),'HoldOut',0.2);
idx = cv.test;
X_train = X_scaled(~idx,:);
X_test = X_scaled(idx,:);
y_train = y(~idx);
y_test = y(idx);

% Crea e addestra il modello SVM
SVMModel = fitcecoc(X_train, y_train, ...
                    'Learners', templateSVM('KernelFunction', 'rbf', 'BoxConstraint', 100, 'KernelScale','auto'), ...
                    'Coding', 'onevsone');

% Effettua le predizioni
y_pred = predict(SVMModel, X_test);

% Valuta le performance
acc = sum(y_pred == y_test)/numel(y_test);
disp(['Accuracy: ', num2str(acc)]);


X_test = [25, 1.4e-6; 
          0, 0.5;
          7, 3e-3;
          17, 3e-4;
          3, 0.1];  % Più campioni
x_test = minmax_scale(X_test)
labels = predict(SVMModel, x_test);
disp(labels);


