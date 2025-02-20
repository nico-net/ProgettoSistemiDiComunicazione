function [rxFlag, params, estCFO] = helperReceiverModule(GeneralParam, OFDMParams, dataParams)
%HELPERRECEIVERMODULE   Modulo per la ricezione

    close all;
    addpath './RX_Disp2'
    SVMModel = GeneralParam.model;
    params = '';
    [rxFlag, class, estCFO] = receiverCode(GeneralParam, OFDMParams, dataParams, SVMModel);
    
    %Se la ricezione è affidabile, si setta la stringa di trasmissione
    if rxFlag
        params = helperChooseParams(class);
        fprintf('Classificazione canale: %d\n Stringa di trasmissione = %s\n', ...
            class, params);
    end
    pause(3);
end