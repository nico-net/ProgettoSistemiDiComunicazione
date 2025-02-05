function [rxFlag, message] = helperReceiverModule(GeneralParam, OFDMParams, dataParams)
%HELPERRECEIVERMODULE   Modulo per la ricezione
%INPUT
%   GeneralParam:  Parametri generali per la trasmissione
%   OFDMParams:    Parametri per l'OFDM
%   dataParams:    Parametri specifici per la trasmissione
%OUTPUT
%   rxFlag:     Flag per assicurare la ricezione
%   message:    Messaggio ricevuto
    
    addpath './ReceiverCodifica'
    % Si utilizza una modulazione e un code rate robusti per assicurare la
    % ricezione del feedback
    dataParams.modOrder = 2;
    dataParams.coderate = '1/2';
    [rxFlag, message] = receiverCode(GeneralParam, OFDMParams, dataParams);
end