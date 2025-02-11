function refSignal = helperOFDMRefSignal(numSubCarr)
%helperOFDMRefSignal Genera il segnale di riferimento.
%   Questa funzione genera un segnale di riferimento (refSignal) per un dato 
%   numero di sottoportanti attivi (numSubCarr). Questo segnale di riferimento 
%   è noto sia al trasmettitore che al ricevitore.
%
%   Per impostazione predefinita, questa funzione utilizza una sequenza binaria 
%   pseudo-casuale modulata in BPSK, ripetuta se necessario per riempire le 
%   sottoportanti desiderate. La sequenza è progettata per essere centrata intorno 
%   alla portante DC. La sequenza per la lunghezza FFT minima viene utilizzata anche 
%   per altre lunghezze FFT più grandi all'interno di quelle sottoportanti, in modo 
%   che i ricevitori che supportano solo la lunghezza FFT minima possano utilizzare 
%   il segnale di riferimento per demodulare l'header (che viene trasmesso alla 
%   lunghezza FFT minima per supportare tutti i ricevitori indipendentemente dalla 
%   larghezza di banda supportata). La sequenza può essere più corta della lunghezza 
%   FFT per adattarsi ai sottoportanti nulli all'interno del simbolo OFDM.
%
%   Questa sequenza può essere definita dall'utente secondo necessità.
%
%   refSignal = helperOFDMRefSignal(numSubCarr)
%   numSubCarr - numero di sottoportanti per simbolo
%   refSignal  - segnale di riferimento nel dominio della frequenza


% Copyright 2023 The MathWorks, Inc.

seq1 = [1; 1;-1;-1; ...
    1; 1;-1; 1; ...
    -1; 1; 1; 1; ...
    1; 1; 1;-1; ...
    -1; 1; 1;-1; ...
    1;-1; 1; 1; ...
    1; 1;];
seq2 = [1; ...
    -1;-1; 1; 1; ...
    -1; 1;-1; 1; ...
    -1;-1;-1;-1; ...
    -1; 1; 1;-1; ...
    -1; 1;-1; 1; ...
    -1; 1; 1; 1; 1];
seq = [seq1 ; seq2];

rep = floor(numSubCarr / length(seq));
endSeqLen = (numSubCarr - (rep * length(seq)))/2;
refSignal = [seq(end-(endSeqLen-1):end); repmat(seq,rep,1); seq(1:endSeqLen)];

% Output check
if length(refSignal) > numSubCarr
    error('Reference signal length too long for FFT.');
end

end
