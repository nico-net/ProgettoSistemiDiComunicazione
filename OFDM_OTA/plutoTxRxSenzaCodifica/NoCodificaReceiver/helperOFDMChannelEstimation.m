function channelEst = helperOFDMChannelEstimation(refSymOld,refSymCurr,chanEstRefSymbols,sysParam)
%helperOFDMChannelEstimation Stima il canale usando simboli di riferimento.
%   Questa funzione restituisce la stima del canale di un frame di dati
%   interpolando linearmente due segnali di riferimento attraverso frame
%   consecutivi.
%
%   channelEst = helperOFDMChannelEstimation(refSymOld,refSymCurr,chanEstRefSymbols,sysParam)
%   refSymOld - simboli di riferimento dal frame precedente
%   refSymCurr - simboli di riferimento dal frame corrente
%   chanEstRefSymbols - simboli di riferimento utilizzati per stimare il canale
%   sysParam - struttura dei parametri di sistema
%   channelEst - Stima del canale risultante dal frame di simboli OFDM
% Copyright 2023 The MathWorks, Inc.

ssIdx = sysParam.ssIdx;         % sync symbol index
rsIdx = sysParam.rsIdx;         % reference symbol index

nDataSubCarr = sysParam.usedSubCarr;
nDataSym = sysParam.numSymPerFrame - length(ssIdx) - length(rsIdx);
RSSpacing = 2; % will be able to create reference symbol with interleaved data in v2

chanEstLast    = zeros(length(refSymOld),1);
chanEstCurrent = zeros(length(refSymOld),1);

% Compute least-squares channel estimates at reference symbols
ii=1:RSSpacing:nDataSubCarr;
chanEstLast(ii)    = refSymOld(ii).*conj(chanEstRefSymbols(ii));
chanEstCurrent(ii) = refSymCurr(ii).*conj(chanEstRefSymbols(ii));

% Interpolate estimates over frequency
for ii=1:RSSpacing:nDataSubCarr-RSSpacing
    chanEstLast(ii+1:ii+RSSpacing-1) = chanEstLast(ii) + (1:RSSpacing-1).'*...
        (chanEstLast(ii+RSSpacing) - chanEstLast(ii))/RSSpacing;
    chanEstCurrent(ii+1:ii+RSSpacing-1) = chanEstCurrent(ii) + (1:RSSpacing-1).'*...
        (chanEstCurrent(ii+RSSpacing) - chanEstCurrent(ii))/RSSpacing;
end
% The last end of the frequency bins just use the last pilot's channel
% estimate since there's nothing to interpolate between
chanEstLast(nDataSubCarr-(RSSpacing-1-1):nDataSubCarr) = ...
    chanEstLast(nDataSubCarr-RSSpacing-1)*ones(RSSpacing-1,1);
chanEstCurrent(nDataSubCarr-(RSSpacing-1-1):nDataSubCarr) = ...
    chanEstCurrent(nDataSubCarr-RSSpacing-1)*ones(RSSpacing-1,1);

% Interpolate estimates over time
channelEst = chanEstLast + (1:nDataSym).*...
    (chanEstCurrent - chanEstLast)/(nDataSym+length(ssIdx)+length(rsIdx));

end
