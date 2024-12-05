function [isConnected, feedbackMessage] = helperRxCode(sysParam, dataParams, OFDMParams)
errorRate = comm.ErrorRate();
toverflow = 0; % Receiver overflow count
rxObj = helperOFDMRxInit(sysParam);
BER = zeros(1,dataParams.numFrames);
isConnected = 0;
feedbackMessage = '';
for frameNum = 1:dataParams.numFrames
    sysParam.frameNum = frameNum;
    [rxWaveform, ~, overflow] = radio();

    toverflow = toverflow + overflow;

    % Run the receiver front-end only when there is no overflow
    if ~overflow
        rxIn = helperOFDMRxFrontEnd(rxWaveform,sysParam,rxObj);

        % Run the receiver processing
        [rxDataBits,isConnected,toff,rxDiagnostics] = helperOFDMRx(rxIn,sysParam,rxObj);
        sysParam.timingAdvance = toff;

        % Collect bit and frame error statistics
        if isConnected
            % Continuously update the bit error rate using the |comm.ErrorRate|
            % System object
            
            berVals = errorRate(...
                transportBlk((1:sysParam.trBlkSize)).', ...
                rxDataBits);
            BER(frameNum) = berVals(1);
            if dataParams.printData
                % As each character in the data is encoded by 7 bits, decode the received data up to last multiples of 7
                numBitsToDecode = length(rxDataBits) - mod(length(rxDataBits),7);
                recData = char(bit2int(reshape(rxDataBits(1:numBitsToDecode),7,[]),7));
                fprintf('Received data in frame %d: %s',frameNum,recData);
                if rxDiagnostics.headerCRCErrFlag == 0 && rxDiagnostics.dataCRCErrorFlag == 0
                    feedbackMessage = recData;
                end
            end
        end
        if dataParams.enableScopes
            spectrumAnalyze(rxWaveform);
        end

    end
end

if isConnected
    % Display the mean BER value across all frames
    fprintf('Feedback ricevuto\ BER medio = %d',mean(BER))
else
    fprintf('Non sincronizzato con il Rx\n');
end

