function rxObj = helperOFDMRxInit(sysParam)
%helperOFDMRxInit Inizializza il ricevitore
%   Questa funzione helper viene chiamata una sola volta e imposta vari oggetti
%   del ricevitore per l'uso nel trattamento per-frame dei blocchi di trasporto.
%
%   rxObj = helperOFDMRxInit(sysParam)
%   sysParam - struttura dei parametri di sistema
%   rxObj - struttura dei parametri del ricevitore e degli handle degli oggetti
%
% Copyright 2023 The MathWorks, Inc.

% Create an rx filter object for baseband filtering
rxFilterCoef = helperOFDMFrontEndFilter(sysParam);
rxObj.rxFilter = dsp.FIRFilter('Numerator',rxFilterCoef);

rxObj.pfo = comm.PhaseFrequencyOffset(...
    SampleRate = sysParam.scs*sysParam.FFTLen, ...
    FrequencyOffsetSource="Input port");

end