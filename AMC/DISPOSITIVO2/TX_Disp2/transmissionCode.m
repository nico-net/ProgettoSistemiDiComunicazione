function [radio, txWaveform, sysParam, tunderrun] = transmissionCode(GeneralParam, OFDMParams, dataParams)
%% OFDM TRANSMITTER DISPOSITIVO 1

    %% Initialize Transmitter Parameters
    centerFrequency = GeneralParam.carrier_frequency;
    gain = GeneralParam.gainTx;
    message_sent = GeneralParam.message;
    [sysParam, txParam, trBlk] = helperOFDMSetParamsSDR(OFDMParams, dataParams, message_sent);
    sampleRate = sysParam.scs * sysParam.FFTLen; % Sample rate of signal
    ofdmTx = helperGetRadioParams(sysParam, sampleRate, centerFrequency, gain);
    
    % Get the radio transmitter and spectrum analyzer system object
    [radio, spectrumAnalyze] = helperGetRadioTxObj(ofdmTx);
    
    %% Generate Transmitter Waveform
    % Initialize transmitter
    txObj = helperOFDMTxInit(sysParam);
    tunderrun = 0; % Initialize count for underruns
    
    % Store data bits for BER calculations
    txParam.txDataBits = trBlk;
    [txOut, ~, txDiagnostics] = helperOFDMTx(txParam, sysParam, txObj);
    
    % Repeat the data in a buffer for PLUTO radio to reduce underruns
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
        pause(1);
        spectrumAnalyze(txOut);
    end
    
   
end
