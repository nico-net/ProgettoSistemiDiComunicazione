function [radio, txWaveform, sysParam, tunderrun] = transmissionCode(GeneralParam, OFDMParams, dataParams)
    %% Initialize Transmitter Parameters
    centerFrequency = GeneralParam.carrier_frequency;
    gain = GeneralParam.gainTx;
    [sysParam, txParam, trBlk] = helperOFDMSetParamsSDR(OFDMParams, dataParams, GeneralParam.message);
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
    [txOut, txGrid, txDiagnostics] = helperOFDMTx(txParam, sysParam, txObj);
    
    % Display the grid if verbosity flag is enabled
    if dataParams.verbosity
        helperOFDMPlotResourceGrid(txGrid, sysParam);
    end
    
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
        spectrumAnalyze(txOut);
    end
    
   
end
