function [rxFlag, message] = receiverCode(GeneralParam, OFDMParams, dataParams)
%% *OFDM RICEVITORE DISPOSITIVO 1*

%% INIZIALIZZA I PARAMETRI DI RICEZIONE
centerFrequency = GeneralParam.carrier_frequency;
gain = GeneralParam.gainRx;
[sysParam,~] = helperOFDMSetParamsSDR(OFDMParams,dataParams);
sampleRate                = sysParam.scs*sysParam.FFTLen;

ofdmRx = helperGetRadioParams(sysParam,sampleRate,centerFrequency,gain);
[radio,spectrumAnalyze,constDiag] = helperGetRadioRxObj(ofdmRx);
%% ESEGUI IL LOOP DEL RICEVITORE

clear helperOFDMRx helperOFDMRxFrontEnd helperOFDMRxSearch helperOFDMFrequencyOffset;
close all;


toverflow = 0; % Contatore dell'overflow
rxObj = helperOFDMRxInit(sysParam);

message_vect = strings(dataParams.numFramesFB,1);
for frameNum = 1:dataParams.numFramesFB
    sysParam.frameNum = frameNum;
    [rxWaveform, ~, overflow] = radio();

    toverflow = toverflow + overflow;

    % Runna il front-end del ricevitore solo se non c'è overflow
    if ~overflow
        rxIn = helperOFDMRxFrontEnd(rxWaveform,sysParam,rxObj);

        [rxDataBits,isConnected,toff,rxDiagnostics] = helperOFDMRx(rxIn,sysParam,rxObj);
        sysParam.timingAdvance = toff;

        if isConnected
            if dataParams.printData
                % As each character in the data is encoded by 7 bits, decode the received data up to last multiples of 7
                numBitsToDecode = length(rxDataBits) - mod(length(rxDataBits),7);
                recData = char(bit2int(reshape(rxDataBits(1:numBitsToDecode),7,[]),7));
                fprintf('Received data in frame %d: %s',frameNum,recData);
                message_vect(frameNum) =  recData;
            end
        else
        end

        if isConnected && dataParams.enableScopes
            constDiag(complex(rxDiagnostics.rxConstellationHeader(:)), ...
                 complex(rxDiagnostics.rxConstellationData(:)));
        end

        if dataParams.enableScopes
            spectrumAnalyze(rxWaveform);
        end
    end
end
%% GESTISCI IL MESSAGGIO

% Accetta il messaggio solo se le due stazioni si sono connesse
if isConnected
    message = message_vect(end);
    rxFlag = 1;
else
    rxFlag = 0;
    message = '';
end
release(radio);