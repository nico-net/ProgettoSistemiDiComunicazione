function [rxFlag, message] = helperReceiverModule(GeneralParam, OFDMParams, dataParams)
%HELPERRECEIVERMODULE   Modulo per la ricezione
    
    addpath './ReceiverCodifica'
    % Si utilizza una modulazione e un code rate robusti per assicurare la
    % ricezione del feedback
    dataParams.modOrder = 2;
    dataParams.coderate = '1/2';
    [rxFlag, message] = receiverCode(GeneralParam, OFDMParams, dataParams);
end