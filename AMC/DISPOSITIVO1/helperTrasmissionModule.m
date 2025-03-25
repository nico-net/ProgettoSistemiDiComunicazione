function helperTrasmissionModule(GeneralParam,OFDMParams, dataParams)
%HELPERTRASMISSIONMODULE    Funzione per la trasmissione del segnale
%INPUT
%   GeneralParam:  Parametri generali per la trasmissione
%   OFDMParams:    Parametri per l'OFDM
%   dataParams:    Parametri specifici per la trasmissione

addpath './TX_Disp1'
    [radio, txWaveform, sysParam, tunderrun] = transmissionCode(GeneralParam, OFDMParams,dataParams);
    helperRadioTx(txWaveform,sysParam, radio, tunderrun);
    % Libera il System Object
        release(radio);
    clear helperRadioTx transmissionCode
end