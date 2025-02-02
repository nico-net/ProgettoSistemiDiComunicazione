function dataParams = helperChooseCodeMod(dataParams,modOrder, codeRate)
%HELPERCHOOSECODEMOD La funzione sceglie code rate e modulazione sulla base
%dei bit ricevuti

switch modOrder
    case '00'
        dataParams.modOrder = 4;
    case '01'
        dataParams.modOrder = 16;
    case '10'
        dataParams.modOrder = 64;
end

switch codeRate
    case '00'
        dataParams.codeRate = '1/2';
    case '01'
        dataParams.codeRate = '2/3';
    case '10'
        dataParams.codeRate = '3/4';
end

end