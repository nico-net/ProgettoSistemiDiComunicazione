function codeStruct = helperOFDMGetTables(codeRateIndex)
%helperOFDMGetTables Restituisce i parametri comuni tx/rx.
%   Questo helper viene chiamato dalle funzioni di trasmettitore e ricevitore
%   per restituire un insieme comune di parametri di sistema dall'indice 
%   del puntatore. Indicizza l'indice di larghezza di banda desiderato per 
%   restituire la lunghezza FFT, la lunghezza del prefisso ciclico (CP), 
%   la spaziatura delle sottoportanti (velocità simbolica) e il numero di 
%   sottoportanti dati per simbolo OFDM.


% Select puncture vector and punctured code rate. The traceback depth of
% the Viterbi decoder roughly follows a rule of thumb of 2x-3x the factor
% (constraint length - 1) / (1 - codeRate)
codeStruct = struct( ...
     'puncVec',[], ...
     'codeRate',[], ...
     'codeRateK',[], ...
     'tracebackDepth',[]);
switch codeRateIndex
    case 1
        codeStruct.puncVec = [1 1 0 1];
        codeStruct.codeRate = 2/3;
        codeStruct.codeRateK = 3;
        codeStruct.tracebackDepth = 45;
    case 2
        codeStruct.puncVec = [1 1 1 0 0 1];
        codeStruct.codeRate = 3/4;
        codeStruct.codeRateK = 4;
        codeStruct.tracebackDepth = 60;
    case 3
        codeStruct.puncVec = [1 1 1 0 0 1 1 0 0 1];
        codeStruct.codeRate = 5/6;
        codeStruct.codeRateK = 6;
        codeStruct.tracebackDepth = 90;
    otherwise
        % Default to index 0
        codeStruct.puncVec = [1 1];
        codeStruct.codeRate = 1/2;
        codeStruct.codeRateK = 2;
        codeStruct.tracebackDepth = 30;
end

end


