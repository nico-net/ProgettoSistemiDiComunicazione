function [camped,toff,foff] = helperOFDMRxSearch(rxIn,sysParam)
%helperOFDMRxSearch Sequenziatore di ricerca del ricevitore.
%   Questa funzione helper cerca il segnale di sincronizzazione della
%   stazione base per allineare il tempo del ricevitore al tempo del trasmettitore.
%   Dopo la rilevazione con successo del segnale di sincronizzazione, viene eseguita
%   la stima dell'offset di frequenza sui primi cinque frame per allineare
%   la frequenza centrale del ricevitore alla frequenza del trasmettitore.
%
%   Una volta completato questo processo, il ricevitore viene dichiarato "camped" 
%   e pronto per il trattamento dei frame di dati.
%
%   [camped,toff,foff] = helperOFDMRxSearch(rxIn,sysParam)
%   rxIn - waveform in ingresso nel dominio del tempo
%   sysParam - struttura dei parametri di sistema
%   camped - valore booleano che indica se il ricevitore ha rilevato il segnale
%   di sincronizzazione e stimato l'offset di frequenza
%   toff - offset temporale calcolato dalla posizione del segnale di sincronizzazione
%   nel buffer del segnale
%   foff - offset di frequenza calcolato dai primi 144 simboli
%   successivi alla rilevazione del segnale di sincronizzazione
%
% Copyright 2022-2023 The MathWorks, Inc.

persistent syncDetected;
if isempty(syncDetected)
    syncDetected = false;
end

% Create a countdown frame timer to wait for the frequency offset
% estimation algorithm to converge
persistent campedDelay
if isempty(campedDelay)
    % The frequency offset algorithm requires 144 symbols to average before
    % the first valid frequency offset estimate. Wait a minimum number of
    % frames before declaring camped state.
    campedDelay = ceil(144/sysParam.numSymPerFrame); 
end

toff = [];  % by default, return an empty timing offset value to indicate
            % no sync symbol found or searched
camped = false;
foff = 0;

% Form the sync signal
FFTLength = sysParam.FFTLen;
syncPad   = (FFTLength - 62)/2;
syncNulls = [1:syncPad (FFTLength/2)+1 FFTLength-syncPad+2:FFTLength]';
syncSignal = ofdmmod(helperOFDMSyncSignal(),FFTLength,0,syncNulls);

if ~syncDetected
    % Perform timing synchronization
    toff = timingEstimate(rxIn,syncSignal,Threshold = 0.6);

    if ~isempty(toff)
        syncDetected = true;
        toff = toff - sysParam.CPLen;
        fprintf('\nSync symbol found.\n');
        if sysParam.enableCFO
            fprintf('Estimating carrier frequency offset ...');
        else
            camped = true; % go straight to camped if CFO not enabled
            fprintf('Receiver camped.\n');
        end
    else
        syncDetected = false;
        fprintf('.');
    end
else
    % Estimate frequency offset after finding sync symbol
    if campedDelay > 0 && sysParam.enableCFO
        % Run the frequency offset estimator and start the averaging to
        % converge to the final estimate
        foff = helperOFDMFrequencyOffset(rxIn,sysParam);
        fprintf('.');
        campedDelay = campedDelay - 1;
    else
        fprintf('\nReceiver camped.\n');
        camped = true;
    end
end

end