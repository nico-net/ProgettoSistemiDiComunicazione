function rxOut = helperOFDMRxFrontEnd(rxIn,sysParam,rxObj)
%helperOFDMRxFrontEnd Elaborazione del front-end del ricevitore
%   Questa funzione helper gestisce la gestione del buffer dei campioni e il filtraggio del front-end.
%   Simula un tipico componente del front-end del ricevitore.
%
%   Componenti opzionali come AGC e convertitori A/D possono anche essere aggiunti
%   a questa funzione helper per simulazioni più dettagliate.
%
%   rxOut = helperOFDMRxFrontEnd(rxIn,sysParam,rxObj)
%   rxIn - waveform in ingresso nel dominio del tempo
%   sysParam - struttura dei parametri di sistema
%   rxObj - struttura degli stati e parametri del ricevitore

% Copyright 2023 The MathWorks, Inc.

symLen = (sysParam.FFTLen+sysParam.CPLen);
frameLen = symLen * sysParam.numSymPerFrame;

% Create a persistent signal buffer to simulate the asynchronousity between
% the transmitter and receiver signal timing
persistent signalBuffer;
if isempty(signalBuffer)
    signalBuffer = zeros(2*frameLen+2*symLen,1);
end

% Perform filtering
rxFiltered = rxObj.rxFilter(rxIn);

% Enter signal into buffer and perform timing adjustment
signalBuffer = [signalBuffer(frameLen+(1:frameLen)); rxFiltered; zeros(symLen*2,1)];
timingAdvance = sysParam.timingAdvance;
rxOut = signalBuffer(timingAdvance+(1:frameLen+2*symLen)); % output one frame plus the sync and ref symbol of the next frame

end