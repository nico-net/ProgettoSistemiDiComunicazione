function helperTrasmissionModule(GeneralParam,OFDMParams, dataParams)
% funzione per trasmissione
addpath '/home/nicola-gallucci/Nicola/Matlab/ProgettoSistemi/plutoTest/provaModulazione/DISPOSITIVO2/TransmitterCodifica'
    [radio, txWaveform, sysParam, tunderrun] = transmissionCode(GeneralParam, OFDMParams,dataParams);
    for ii = 1:GeneralParam.numRip
        helperRadioTx(txWaveform,sysParam, radio, tunderrun);
        pause(2);
    end
    % Clean up the radio System object
        release(radio);
end