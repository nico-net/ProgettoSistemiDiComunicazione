function [rxFlag, message] = helperReceiverModule(GeneralParam, OFDMParams, dataParams)
%Modulo per la ricezione
    addpath '/home/nicola-gallucci/Nicola/Matlab/ProgettoSistemi/plutoTest/provaModulazione/DISPOSITIVO1/ReceiverCodifica'
    rxFlag = 0;
    message = '';
    ii = 0;
    while ii<GeneralParam.numRip && ~rxFlag
        [rxFlag, message] = receiverCode(GeneralParam, OFDMParams, dataParams);
        ii = ii + 1;
    end
end