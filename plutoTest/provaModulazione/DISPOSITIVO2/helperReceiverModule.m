function [rxFlag, params] = helperReceiverModule(GeneralParam, OFDMParams, dataParams)
%HELPERRECEIVERMODULE   Modulo per la ricezione
    close all;
    addpath './ReceiverCodifica'
    SVMModel = GeneralParam.model;
    params = '';
    [rxFlag, class] = receiverCode(GeneralParam, OFDMParams, dataParams, SVMModel);
    pause(1);
   
    if rxFlag
        params = helperChooseParams(class);
        fprintf('Classificazione canale: %d\nParams = %s\n', class, params);
    end
end