clc; clear; close all;


% Definire i valori di Eb/N0 in dB
EbN0_dB = -5:1:30;  % Gamma di valori in dB
EbN0_linear = 10.^(EbN0_dB / 10);  % Convertire da dB a valore lineare

Rb2 = log2(2)*(128 * 3e3); % tra parentesi Rs, symbol rate BPSK
Rb4 = log2(4)*(128 * 3e3); % tra parentesi Rs, symbol rate QPSK
Rb16 = log2(16)*(128 * 3e3); % tra parentesi Rs, symbol rate 16-QAM
Rb64 = log2(64)*(128 * 3e3); % tra parentesi Rs, symbol rate 64-QAM

B = 3e6;

eff2 = log2(1 + (Rb2/B)*(EbN0_linear));
eff4 = log2(1 + (Rb4/B)*(EbN0_linear));
eff16 = log2(1 + (Rb16/B)*(EbN0_linear));
eff64 = log2(1 + (Rb64/B)*(EbN0_linear));

% Calcolare l'efficienza spettrale teorica di Shannon
spectral_efficiency = log2(1 + EbN0_linear);  


% Creare il grafico
figure;
plot(EbN0_dB, spectral_efficiency, 'b-','LineWidth', 2); % Curva di Shannon
hold on;
plot(EbN0_dB, eff2,'r', 'LineWidth', 2); 
hold on;
plot(EbN0_dB, eff4,'g', 'LineWidth', 2);
hold on;
plot(EbN0_dB, eff16, 'c', 'LineWidth', 2);
hold on;
plot(EbN0_dB, eff64, 'm', 'LineWidth', 2);
hold on;

% Etichette degli assi
xlabel('E_b/N_0 (dB)');
ylabel('Efficienza spettrale (bit/s/Hz)');
title('Efficienza spettrale vs E_b/N_0');

% Aggiungere griglia e legenda
grid on;
legend('Limite di Shannon', 'BPSK','QPSK','16-QAM','64-QAM','Location', 'NorthWest');
hold off;
