% Questo programma aggiunge le label al file con i dati di training per il
% modello SVM. La comunicazione è ottima (classe 2) se il SNR è alto e il
% BER sufficientemente basso. Lo stato è discreto (classe 1) se si hanno
% valori intermedi di BER  e SNR, altrimenti è di classe 0.

% Leggere il file CSV
data = readtable('results2.csv'); % Sostituisci 'dati.csv' con il nome del tuo file

% Creare una nuova colonna
classe = zeros(height(data), 1); % Inizializza la colonna

% Applicare le condizioni
for i = 1:height(data)
    if data.SNR(i) >= 17 && data.BER(i) < 2e-2
        classe(i) = 2;
    elseif ((data.SNR(i) >= 7 && data.SNR(i) < 17) && (data.BER(i) < 8e-2)) || (data.SNR(i)>=17 && data.BER(i)>2e-2 && data.BER(i)<8e-2)
        classe(i) = 1;
    else
        classe(i) = 0;
    end
end

% Aggiungere la colonna alla tabella
data.Classe = classe;

% Salvare il nuovo file CSV
writetable(data, 'dati_classificati.csv');


% Contare le occorrenze di ciascuna classe
num_0 = sum(classe == 0);
num_1 = sum(classe == 1);
num_2 = sum(classe == 2);

% Stampare i risultati
fprintf('Numero di righe con Classe 0: %d\n', num_0);
fprintf('Numero di righe con Classe 1: %d\n', num_1);
fprintf('Numero di righe con Classe 2: %d\n', num_2);