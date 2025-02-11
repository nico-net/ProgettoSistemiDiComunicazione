function  helperRadioTx(txWaveform,sysParam, radio, tunderrun)
 %% Transmit Over Radio
    for frameNum = 1:sysParam.numFrames + 1
        underrun = radio(txWaveform);
        tunderrun = tunderrun + underrun; % Total underruns
    end
    
    
end