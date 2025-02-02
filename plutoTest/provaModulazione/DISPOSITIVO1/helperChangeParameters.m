function [dataParams] = helperChangeParameters(message, dataParams)
%HELPERCHANGEPARAMETERS La funzione cambia i parametri di trasmissione
%(modulazione e code rate) dopo la ricezione del feedback

    substring = find_most_frequent_substring(message,4);
    modOrder = substring(1:2);
    codeRate = substring(3:4);
    dataParams = helperChooseCodeMod(dataParams,modOrder, codeRate);
end
