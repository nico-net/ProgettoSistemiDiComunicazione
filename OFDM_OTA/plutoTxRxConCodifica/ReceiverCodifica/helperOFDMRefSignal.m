function refSignal = helperOFDMRefSignal(numSubCarr)
%helperOFDMRefSignal Genera il segnale di riferimento.
%   Questa funzione genera un segnale di riferimento (refSignal) per il numero
%   dato di sottocarrier attivi (numSubCarr). Questo segnale di riferimento è
%   conosciuto sia dal trasmettitore che dal ricevitore.
%
%   Per impostazione predefinita, questa funzione utilizza una sequenza binaria
%   pseudo-casuale modulata BPSK, ripetuta secondo necessità per riempire i sottocarrier desiderati.
%   La sequenza è progettata per essere centrata attorno alla frequenza zero (DC).
%   La sequenza per la lunghezza FFT più piccola viene utilizzata anche per le altre lunghezze FFT maggiori
%   all'interno di quei sottocarrier, in modo che i ricevitori che supportano solo la lunghezza FFT minima
%   possano usare il segnale di riferimento per demodulare l'intestazione (che viene trasmessa
%   alla lunghezza FFT minima per supportare tutti i ricevitori indipendentemente dalla larghezza di banda supportata).
%   La sequenza può essere inferiore alla lunghezza FFT per adattarsi ai sottocarrier nulli all'interno del simbolo OFDM.
%
%   Questa sequenza può essere definita dall'utente secondo necessità.
%
%   refSignal = helperOFDMRefSignal(numSubCarr)
%   numSubCarr - numero di sottocarrier per simbolo
%   refSignal - segnale di riferimento nel dominio delle frequenze
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
