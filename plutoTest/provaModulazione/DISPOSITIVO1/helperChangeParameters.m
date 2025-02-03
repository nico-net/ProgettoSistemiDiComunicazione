function [codeRateEx, modOrderEx] = helperChangeParameters(message)
%HELPERCHANGEPARAMETERS La funzione cambia i parametri di trasmissione
%(modulazione e code rate) dopo la ricezione del feedback

    substring = find_most_frequent_substring(message,4);
    disp(substring);
    modOrder = string(extractBetween(substring, 1, 2));
    coderate = string(extractBetween(substring, strlength(substring)-1, strlength(substring)));
    [codeRateEx, modOrderEx] = helperChooseCodeMod(modOrder, coderate);
end