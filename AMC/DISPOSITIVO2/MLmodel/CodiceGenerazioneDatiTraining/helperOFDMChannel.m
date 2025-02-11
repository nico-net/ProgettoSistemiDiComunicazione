function rxOut = helperOFDMChannel(txIn,chanParam,sysParam, BWstruct)
% helperOFDMChannel() Genera le imperfezioni del canale.
%   Questa funzione genera imperfezioni del canale e le applica
%   al segnale di ingresso.
%   rxOut = helperOFDMChannel(txIn,chanParam,sysParam)
%   txIn - segnale di ingresso nel dominio del tempo
%   chanParam - struttura dei parametri delle imperfezioni del canale
%   sysParam - struttura dei parametri del sistema
%   rxOut - segnale di uscita nel dominio del tempo
%
%   I parametri del canale specificano il livello delle imperfezioni:
%
%   Scostamento Doppler normalizzato - frequenza Doppler moltiplicata per 
%   la durata del simbolo
%   Ritardi e guadagni dei percorsi - Vettore dei ritardi di percorso e 
%   guadagni medi
%   SNR - in dB
%   Scostamento di frequenza portante normalizzato (ppm) - scostamento di 
%   frequenza tra trasmettitore e ricevitore diviso per la frequenza di 
%   campionamento. Sebbene l'elaborazione venga eseguita in banda base, si 
%   assume che lo scostamento di frequenza della portante venga mantenuto 
%   durante la conversione verso la continua (DC).

% Copyright 2022 The MathWorks, Inc.
symLen = (sysParam.FFTLen+sysParam.CPLen);


% Create a persistent channel filter object for channel fading
persistent rayChan;
persistent visualizationCalled;
if isempty(rayChan)
    Ts = 1/(sysParam.scs*sysParam.FFTLen);  % sample period
    T = symLen*Ts;                          % symbol duration (s)
    fmax = chanParam.doppler/T;
    rayChan = comm.RayleighChannel( ...
        SampleRate=1/Ts, ...
        PathDelays=chanParam.pathDelay, ...
        AveragePathGains=chanParam.pathGain, ...
        MaximumDopplerShift=fmax, ...
        Visualization=sysParam.chanVisual);
     visualizationCalled = false;
end

persistent pfo;
if isempty(pfo)
    pfo = comm.PhaseFrequencyOffset(...
        SampleRate=1e6, ...    % Phase-frequency offset is specified in PPM
        FrequencyOffsetSource="Input port");
end

% Rayleigh fading channel
if sysParam.enableFading
    fadingChanOut = rayChan(txIn);
else
    fadingChanOut = txIn;
end

% Call visualization only the first time
% if ~visualizationCalled
%     helperOFDMChannelVisualization(rayChan, BWstruct);
%     visualizationCalled = true; % Mark as called
% end

% AWGN
txScaleFactor = sysParam.usedSubCarr/(sysParam.FFTLen^2);
signalPowerDbW = 10*log10(txScaleFactor);
rxChanOut = awgn(fadingChanOut,chanParam.SNR,signalPowerDbW);

% Carrier frequency offset
rxOut = pfo(rxChanOut,chanParam.foff);

end

