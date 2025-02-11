function syncSignal = helperOFDMSyncSignal()
%helperOFDMSyncSignal Genera il segnale di sincronizzazione
%   Questa funzione restituisce un vettore di lunghezza 62 con valori 
%   complessi, che rappresenta il segnale di sincronizzazione nel dominio 
%   della frequenza.
%
%   Per impostazione predefinita, questa funzione utilizza una sequenza 
%   Zadoff-Chu di lunghezza 62 con indice di radice 25. La sequenza 
%   Zadoff-Chu è un segnale a ampiezza costante finché la lunghezza è un 
%   numero primo, quindi la sequenza viene generata con lunghezza 63 e poi 
%   adattata a una lunghezza di 62.
%
%   Questa sequenza può essere definita dall'utente secondo necessità 
%   (ad esempio una sequenza massima di lunghezza), purché la lunghezza 
%   sia 62 per adattarsi alla simulazione OFDM.
%
%   syncSignal = helperOFDMSyncSignal() 
%   syncSignal - segnale di sincronizzazione nel dominio della frequenza


% Copyright 2023 The MathWorks, Inc.

zcRootIndex = 25;
seqLen      = 62;
nPart1      = 0:((seqLen/2)-1);
nPart2      = (seqLen/2):(seqLen-1);

ZC = zadoffChuSeq(zcRootIndex, seqLen+1);
syncSignal = [ZC(nPart1+1); ZC(nPart2+2)];

% Output check
if length(syncSignal) ~= 62
    error('Sync signal must be of length 62.');
end

end
