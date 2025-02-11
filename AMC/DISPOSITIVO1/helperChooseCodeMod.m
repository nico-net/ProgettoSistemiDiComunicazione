function [codeRateExit, modOrderExit] = helperChooseCodeMod(modOrder, codeRate)
%HELPERCHOOSECODEMOD La funzione sceglie code rate e modulazione sulla base
%dei bit ricevuti
%INPUT
%   modOrder = Bit per la modulazione
%   codeRate = Bit per il code rate
%OUTPUT
%   modOrderExit = ordine della modulazione associata
%   codeRateExit = ordine del code rate associato

switch modOrder
    case '00'
        modOrderExit = 4;
    case '01'
        modOrderExit = 16;
    case '10'
        modOrderExit = 64;
    otherwise
        error('Nessun modulation order trovato\n');
end

switch codeRate
    case '00'
        codeRateExit = "1/2";
    case '01'
        codeRateExit = "2/3";
    case '10'
        codeRateExit = "3/4";
    otherwise
        error('Nessun code rate trovato\n');
end
end