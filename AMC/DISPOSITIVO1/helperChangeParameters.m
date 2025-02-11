function [codeRateEx, modOrderEx] = helperChangeParameters(message)
%HELPERCHANGEPARAMETERS La funzione cambia i parametri di trasmissione
%(modulazione e code rate) dopo la ricezione del feedback
%INPUT
%   message:    Messaggio di ingresso con i parametri in formato binario
%OUTPUT
%   codeRateEx:     code rate riconosciuto
%   modOrderEx:     modulation order riconosciuta

    %Estrae la sequenza di parametri dal messaggio
    substring = find_most_frequent_substring(message,4);
    disp(substring);

    %Estrae i 2 codici dalla sottostringa
    modOrder = string(extractBetween(substring, 1, 2));
    coderate = string(extractBetween(substring, strlength(substring)-1, strlength(substring)));

    %Risale alla modulazione e al code rate da usare nella trasmissione
    [codeRateEx, modOrderEx] = helperChooseCodeMod(modOrder, coderate);
end