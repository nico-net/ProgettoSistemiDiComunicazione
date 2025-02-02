function [rxFlag, params] = helperReceiverModule(GeneralParam, OFDMParams, dataParams)
%Modulo per la ricezione
    close all
    addpath '/home/nicola-gallucci/Nicola/Matlab/ProgettoSistemi/plutoTest/provaModulazione/DISPOSITIVO2/ReceiverCodifica'
    load svm_model.mat SVMModel
    rxFlag = 0;
    params = '';
    ii = 0;
    while ~rxFlag && ii<GeneralParam.numRip
        [rxFlag, class] = receiverCode(GeneralParam, OFDMParams, dataParams, SVMModel);
        ii = ii + 1;
        pause(GeneralParam.waitTime);
    end

    if rxFlag
        params = helperChooseParams(class);
        disp(params);
    end
end