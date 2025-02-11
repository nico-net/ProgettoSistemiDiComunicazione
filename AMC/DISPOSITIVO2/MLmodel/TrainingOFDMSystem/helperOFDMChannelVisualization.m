%% VISUALIZZAZIONE RISPOSTA IN FREQUENZA CANALE DI RAYLEIGH

function helperOFDMChannelVisualization(rayChan, BWstruct)
nFreqPoints = 1024; 

% Genera un segnale impulso per analizzare la risposta in frequenza
impulseSignal = [1; zeros(nFreqPoints-1, 1)];

% Passa l'impulso attraverso il canale Rayleigh
freqResponse = rayChan(impulseSignal);

% Calcola la trasformata di Fourier
freqAxis= linspace(- 0.5 , 0.5, BWstruct.FFTLen);
freqAxis = freqAxis.*BWstruct.BW;
freqMag = abs(fftshift(fft(freqResponse)));  % Magnitudine della risposta

% Visualizza la risposta in frequenza
figure;
plot(freqAxis, 10*log10(freqMag));
title('Risposta in frequenza del canale Rayleigh');
xlabel('Frequenza (Hz)');
ylabel('Magnitudine (dB)');
grid on;

% Salva la figura come immagine
saveas(gcf, 'rayleigh_channel_frequency_response.png');
disp('La risposta in frequenza è stata salvata come immagine.');