function [radio, txWaveform, sysParam, tunderrun] = transmissionCode(GeneralParam, OFDMParams, dataParams)
%% OFDM TRANSMITTER DISPOSITIVO 1

    %% INIZIALLIZA I PARAMETRI DI TRASMISSIONE
    
    centerFrequency = GeneralParam.carrier_frequency;
    gain = GeneralParam.gainTx;
    message_sent = GeneralParam.message;
    [sysParam, txParam, trBlk] = helperOFDMSetParamsSDR(OFDMParams, dataParams, message_sent);
    sampleRate = sysParam.scs * sysParam.FFTLen; 
    ofdmTx = helperGetRadioParams(sysParam, sampleRate, centerFrequency, gain);
    [radio, spectrumAnalyze] = helperGetRadioTxObj(ofdmTx);
    
    %% GENERA LA WAVEFORM

    txObj = helperOFDMTxInit(sysParam);
    tunderrun = 0; 
    
    txParam.txDataBits = trBlk;
    [txOut, ~, txDiagnostics] = helperOFDMTx(txParam, sysParam, txObj);
    
    txOutSize = length(txOut);
    if txOutSize < 48000
        frameCnt = ceil(48000 / txOutSize);
        txWaveform = zeros(txOutSize * frameCnt, 1);
        for i = 1:frameCnt
            txWaveform(txOutSize * (i - 1) + 1 : i * txOutSize) = txOut;
        end
    else
        txWaveform = txOut;
    end
    
    if dataParams.enableScopes
        spectrumAnalyze(txOut);
    end
end
