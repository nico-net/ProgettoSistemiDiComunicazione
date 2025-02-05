function [rxFlag, message] = receiverCode(GeneralParam, OFDMParams, dataParams)
%% *OFDM Receiver DISPOSITIVO 1*

%% Initialize Receiver Parameters
centerFrequency = GeneralParam.carrier_frequency;
gain = GeneralParam.gainRx;
[sysParam,~] = helperOFDMSetParamsSDR(OFDMParams,dataParams);
sampleRate                = sysParam.scs*sysParam.FFTLen;  % Sample rate of signal

ofdmRx = helperGetRadioParams(sysParam,sampleRate,centerFrequency,gain);
[radio,spectrumAnalyze,constDiag] = helperGetRadioRxObj(ofdmRx);
%% Execute Receiver Loop

% Clear all the function data as they contain some persistent variables
clear helperOFDMRx helperOFDMRxFrontEnd helperOFDMRxSearch helperOFDMFrequencyOffset;
close all;

%errorRate = comm.ErrorRate();
toverflow = 0; % Receiver overflow count
rxObj = helperOFDMRxInit(sysParam);
%BER = zeros(1,dataParams.numFramesFB);
message_vect = strings(dataParams.numFramesFB,1);
for frameNum = 1:dataParams.numFramesFB
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
            % % Continuously update the bit error rate using the |comm.ErrorRate|
            % % System object
            % berVals = errorRate(...
            %     transportBlk((1:sysParam.trBlkSize)).', ...
            %     rxDataBits);
            % BER(frameNum) = berVals(1);
            if dataParams.printData
                % As each character in the data is encoded by 7 bits, decode the received data up to last multiples of 7
                numBitsToDecode = length(rxDataBits) - mod(length(rxDataBits),7);
                recData = char(bit2int(reshape(rxDataBits(1:numBitsToDecode),7,[]),7));
                fprintf('Received data in frame %d: %s',frameNum,recData);
                message_vect(frameNum) =  recData;
            end
        else
            %BER(frameNum) = 0.5;
        end

        if isConnected && dataParams.enableScopes
            constDiag(complex(rxDiagnostics.rxConstellationHeader(:)), ...
                 complex(rxDiagnostics.rxConstellationData(:)));
        end

        if dataParams.enableScopes
            spectrumAnalyze(rxWaveform);
        end
    end
    % fprintf('\nBER = %d \n',BER(frameNum));
end
if isConnected
    message = message_vect(end);
    rxFlag = 1;
else
    rxFlag = 0;
    message = '';
end
release(radio);