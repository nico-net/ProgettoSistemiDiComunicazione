function [rxFlag, class] = receiverCode(GeneralParam, OFDMParams, dataParams, SVMModel)
%% *OFDM RICEVITORE DISPOSITIVO 2*

%% INIZIALIZZA I PARAMETRI DEL RICEVITORE
centerFrequency = GeneralParam.carrier_frequency;
gain = GeneralParam.gainRx;
[sysParam,~,transportBlk] = helperOFDMSetParamsSDR(OFDMParams,dataParams);
sampleRate                       = sysParam.scs*sysParam.FFTLen;               

ofdmRx = helperGetRadioParams(sysParam,sampleRate,centerFrequency,gain);
[radio,spectrumAnalyze,constDiag] = helperGetRadioRxObj(ofdmRx);
%% ESEGUI IL LOOP DEL RICEVITORE


clear helperOFDMRx helperOFDMRxFrontEnd helperOFDMRxSearch helperOFDMFrequencyOffset;
close all;

errorRate = comm.ErrorRate();
toverflow = 0;
rxObj = helperOFDMRxInit(sysParam);
BER = zeros(1,dataParams.numFrames);
SNR_vect = zeros(1, dataParams.numFrames);

for frameNum = 1:dataParams.numFrames
    sysParam.frameNum = frameNum;
    [rxWaveform, ~, overflow] = radio();

    toverflow = toverflow + overflow;

    % Runna il front-end del ricevitore solo se non c'è overflow
    if ~overflow
        rxIn = helperOFDMRxFrontEnd(rxWaveform,sysParam,rxObj);

        % Esegui il processo del ricevitore
        [rxDataBits,isConnected,toff,rxDiagnostics] = helperOFDMRx(rxIn,sysParam,rxObj);
        sysParam.timingAdvance = toff;

        if isConnected
            berVals = errorRate(...
                transportBlk((1:sysParam.trBlkSize)).', ...
                rxDataBits);
            BER(frameNum) = berVals(1);
            SNR_vect(frameNum) = helperSNRestimate(spectrumAnalyze);
            if dataParams.printData
                % As each character in the data is encoded by 7 bits, decode the received data up to last multiples of 7
                numBitsToDecode = length(rxDataBits) - mod(length(rxDataBits),7);
                recData = char(bit2int(reshape(rxDataBits(1:numBitsToDecode),7,[]),7));
                fprintf('Received data in frame %d: %s',frameNum,recData);
               
            end
        else
            BER(frameNum) = 0.5;
        end

        if isConnected && dataParams.enableScopes
            constDiag(complex(rxDiagnostics.rxConstellationHeader(:)), ...
                 complex(rxDiagnostics.rxConstellationData(:)));
        end

        if dataParams.enableScopes
            spectrumAnalyze(rxWaveform);
        end
    end
    fprintf('\nBER = %d \n',BER(frameNum));   
end

SNR_vect = SNR_vect(SNR_vect>0);
minBer = BER(BER<GeneralParam.threshold);

%Se la lunghezza del vettore contenente i BER inferiori alla threshold
%scelta è maggiore del 25% dei campioni totali, si reputa la ricezione
%affidabile e si passa alla classificazione del canale.
if length(minBer) >= (dataParams.numFrames)/4
    rxFlag = 1;
    berMax = max(minBer);
    fprintf('BerMax = %d\n', berMax);
    SNRmean = mean(SNR_vect);
    class = helperPredictionSVM(SNRmean, berMax, SVMModel);
    disp(class);
else
    rxFlag = 0;
    class = 0;
end
release(radio);