function helperTrasmissionModule(GeneralParam,OFDMParams, dataParams)
% funzione per trasmissione
addpath './TransmitterCodifica'
    [radio, txWaveform, sysParam, tunderrun] = transmissionCode(GeneralParam, OFDMParams,dataParams);
    helperRadioTx(txWaveform,sysParam, radio, tunderrun);
    % Clean up the radio System object
        release(radio);
    clear helperRadioTx transmissionCode
end