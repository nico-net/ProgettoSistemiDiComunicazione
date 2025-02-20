function helperTrasmissionModule(GeneralParam,OFDMParams, dataParams)
%HELPERTRANSMISSIONMODULE  Modulo per la trasmissione

    addpath './TX_Disp2'

     % Siccome il feedback deve arrivare a destinazione, lo trasmetto
     % con una modulazione e un code rate robusti.
    dataParams.modOrder = 2;
    dataParams.coderate = '1/2';

    [radio, txWaveform, sysParam, tunderrun] = transmissionCode(GeneralParam, OFDMParams,dataParams);
    helperRadioTx(txWaveform,sysParam, radio, tunderrun);
    pause(2);
    
    % Libera il System Object
    release(radio);
    clear helperRadioTx transmissionCode
end