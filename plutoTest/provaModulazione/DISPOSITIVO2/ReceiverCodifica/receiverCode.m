function [rxFlag, class, estCFO] = receiverCode(GeneralParam, OFDMParams, dataParams, SVMModel)
%% *RICEVITORE OFDM DISPOSITIVO 2*

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
BER = ones(1,dataParams.numFrames);
SNR_vect = zeros(1, dataParams.numFrames);
numHeaderCRCfail = 0;

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
            if rxDiagnostics.headerCRCErrorFlag 
                numHeaderCRCfail = numHeaderCRCfail + 1;
                BER(frameNum) = 0.5;
            else
                berVals = errorRate(...
                    transportBlk((1:sysParam.trBlkSize)).', ...
                    rxDataBits);
                BER(frameNum) = berVals(1);
                SNR_vect(frameNum) = helperSNRestimate(spectrumAnalyze);
                if dataParams.printData && mod(frameNum, 20) == 0
                    % As each character in the data is encoded by 7 bits, decode the received data up to last multiples of 7
                    numBitsToDecode = length(rxDataBits) - mod(length(rxDataBits),7);
                    recData = char(bit2int(reshape(rxDataBits(1:numBitsToDecode),7,[]),7));
                    fprintf('Received data in frame %d: %s\n',frameNum,recData);
                    fprintf('SNR estimated: %d\n', SNR_vect(frameNum));
                end
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
    if mod(frameNum, 20) == 0
        fprintf('\nBER = %d \n',BER(frameNum));
    end
    if numHeaderCRCfail == 150
        break;
    end
end

SNR_vect = SNR_vect(SNR_vect>0);
minBer = BER(BER<GeneralParam.threshold);

%Se la lunghezza del vettore contenente i BER inferiori alla threshold
%scelta è maggiore del 25% dei campioni totali, si reputa la ricezione
%affidabile e si passa alla classificazione del canale.
estCFO = 0;
if length(minBer) >= (dataParams.numFrames)/4
    rxFlag = 1;
    berMax = max(minBer);
    fprintf('Ber medio = %d, BerMax = %d\n', mean(minBer),berMax);
    SNRmean = mean(SNR_vect);
    class = helperPredictionSVM(SNRmean, berMax, SVMModel);
    fprintf(['Classe stimata: %d\n' ...
        'SNR medio: %d\n'], class, SNRmean);
    estCFO = 0;
else
    rxFlag = 0;
    class = 0;
    if numHeaderCRCfail == 50
        %Calcolo il CFO stimato solo nel caso di almeno 50 headerCRCfail.
        estCFO = -rxDiagnostics.estCFO(end) * sysParam.scs;
    end
end
release(radio);