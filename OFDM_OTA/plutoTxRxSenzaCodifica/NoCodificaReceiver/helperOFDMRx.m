function [rxDataBits,isConnected,toff,diagnostics] = helperOFDMRx(rxWaveform,sysParam,rxObj)
%helperOFDMRx Elabora il segnale OFDM.
%   Esegue la stima e la correzione dello sfasamento in frequenza portante, 
%   la sincronizzazione di frame, la demodulazione OFDM, la stima del canale, 
%   l'uguagliamento del canale, la correzione dello sfasamento di fase e la 
%   decodifica dei bit trasmessi.
%
%   [rxDataBits,isConnected,toff,diagnostics] = helperOFDMRx(rxWaveform,sysParam,rxObj)
%   rxWaveform - segnale di ingresso nel dominio del tempo
%   sysParam - struttura dei parametri di sistema
%   rxObj - struttura dei parametri e stati del ricevitore
%   rxDataBits  - Bit informativi decodificati
%   isConnected - Indica se il ricevitore è in stato connesso
%   toff - Offset temporale stimato dal ricevitore
%   diagnostics - Struttura contenente:
%    estCfo                - Valori dello sfasamento in frequenza portante stimato 
%                            per l'intero frame
%    estChannel            - Valori del canale stimato per l'intero frame
%    timeOffset            - Valori dell'offset temporale
%    rxConstellationHeader - Simboli della costellazione demodulati dell'header
%    rxConstellationData   - Simboli della costellazione demodulati dei dati trasmessi
%    softLLR               - Valori LLR (informazione soft) dei dati demodulati
%    decodedCodeRateIndex  - Indice del code rate decodificato dall'header
%    decodedModRate        - Ordine di modulazione decodificato dall'header
%    headerCRCErrorFlag    - Indica lo stato CRC dell'header (0-pass, 1-fail)
%    dataCRCErrorFlag      - Indica lo stato CRC dei dati (0-pass, 1-fail)

%   Copyright 2023-2024 The MathWorks, Inc.

persistent camped;
if isempty(camped)
    camped = false;
end

persistent rxInternalDiags;
if isempty(rxInternalDiags)
    rxInternalDiags = struct( ...
        'estCFO',[],...
        'estChannel',[]);
end

if ~camped
    isConnected = false;
    rxDataBits = [];
    % Search for sync symbol
    [camped,ta,foff] = helperOFDMRxSearch(rxWaveform,sysParam);
    if ~camped
        diagnostics.estCFO = foff;
    else
        diagnostics.estCFO = [];
    end
    
    diagnostics.estChannel = [];
    
    % If ta is not empty, sync symbol was found. Adjust buffer timing so that
    % the sample buffer starts at the sync symbol
    if ~isempty(ta)
        % Sync symbol found
        toff = ta + 1;
    else
        toff = sysParam.timingAdvance;
    end
else
    % Receiver is camped on the base station
    isConnected = true;
    toff = sysParam.timingAdvance;

    if sysParam.verbosity > 0
        fprintf('Detected and processing frame %d\n', sysParam.frameNum);
        fprintf('------------------------------------------\n');
    else
        fprintf('.');
        if floor(sysParam.frameNum/80) == sysParam.frameNum/80
            fprintf('\n');
        end
    end

    % Run frame processing
    [rxDataBits,diagnostics] = rxFrame(rxWaveform,sysParam,rxObj);
end

% Collect diagnostics
oldCFO = rxInternalDiags.estCFO;
oldEstChannel = rxInternalDiags.estChannel;
rxInternalDiags = diagnostics;
if sysParam.frameNum < 40
    rxInternalDiags.estCFO = [oldCFO; diagnostics.estCFO];
    rxInternalDiags.estChannel = [oldEstChannel; diagnostics.estChannel];
end

diagnostics = rxInternalDiags;

end

function [rxDataBits,diagnostics] = rxFrame(rxWaveform,sysParam,rxObj)

% Define reference signal, pilot signal, and parameters
ssIdx           = sysParam.ssIdx;        % sync symbol index
rsIdx           = sysParam.rsIdx;        % reference symbol index
headerIdx       = sysParam.headerIdx;    % header symbol index
FFTLength       = sysParam.FFTLen;
CPLength        = sysParam.CPLen;
usedSubCarr     = sysParam.usedSubCarr;
pilotSpacing    = sysParam.pilotSpacing;
pilotsPerSym    = sysParam.pilotsPerSym;
channelEstRefSymbols = helperOFDMRefSignal(usedSubCarr);
pilotSignal     = helperOFDMPilotSignal(pilotsPerSym);
numSymPerFrame  = sysParam.numSymPerFrame;
verbosity       = sysParam.verbosity;

frameLength     = (FFTLength + CPLength)*numSymPerFrame; % total number of samples in one frame
numSampPerSym   = FFTLength + CPLength;
shortFrameLength = frameLength - numSampPerSym; % total samples in a frame without the sync symbol
nullIdx = [1:((FFTLength-usedSubCarr)/2) ...
    (FFTLength/2)+1 ...
    ((FFTLength+usedSubCarr)/2)+2:FFTLength]';
dataIdx = setdiff(1:usedSubCarr,1:pilotSpacing:usedSubCarr);
cpFraction = 0.55;
symbOffset = ceil(cpFraction*CPLength);
syncSigLen = numSampPerSym;

% Perform frequency offset estimation and correction
if sysParam.enableCFO
    if verbosity > 0
        fprintf('Estimating carrier frequency offset ... \n');
    end
    freqOffset = helperOFDMFrequencyOffset(rxWaveform,sysParam);
    rxObj.freqOffset = freqOffset;
    if verbosity > 0
        fprintf('Estimated carrier frequency offset is %d Hz.\n', ...
            freqOffset(end) * sysParam.scs);
    end
    if verbosity > 0
        fprintf('Correcting frequency offset across all samples\n');
    end
    cfoCorrectedData = rxObj.pfo( ...
        rxWaveform,-freqOffset(1:length(rxWaveform))*sysParam.scs);
else
    freqOffset = zeros(length(rxWaveform),1);
    cfoCorrectedData = rxWaveform;
end

% Define output parameters
softLLRs        = [];
dataConstData   = zeros(usedSubCarr-pilotsPerSym,...
    numSymPerFrame-length(ssIdx)-length(rsIdx)-length(headerIdx));

%% Perform OFDM demodulation, header decoding, and data decoding per frame

% Extract out the header and data samples
dataHeaderFrame = cfoCorrectedData(syncSigLen+(1:shortFrameLength));

% Extract out the reference symbol samples and demod
refSamples = cfoCorrectedData(syncSigLen+(1:numSampPerSym));
demodulatedRS = ofdmdemod(refSamples,FFTLength,CPLength,symbOffset,nullIdx);

% Extract out the next reference symbol samples and demod
refSamples = cfoCorrectedData(frameLength+syncSigLen+(1:numSampPerSym));
demodulatedNextRS = ofdmdemod(refSamples,FFTLength,CPLength,symbOffset,nullIdx);

% Perform channel estimation over all subcarriers and symbols in the
% frame
estChannel = helperOFDMChannelEstimation...
     (demodulatedRS,demodulatedNextRS,channelEstRefSymbols,sysParam);

% Extract out the header symbol samples and demod
refSamples = cfoCorrectedData( ...
    ((headerIdx-length(ssIdx))*numSampPerSym + (1:numSampPerSym)));
demodulatedHeader = ...
    ofdmdemod(refSamples,FFTLength,CPLength,symbOffset,nullIdx);
eqHeaderData = ofdmEqualize(demodulatedHeader,estChannel(:,headerIdx-1));
headerInd = (usedSubCarr/2)-36+(1:72);
headerData = eqHeaderData(headerInd);

% Extract out and demodulate the data and pilot subcarriers
[demodulatedData,pilots] = ...
    ofdmdemod(dataHeaderFrame,FFTLength,CPLength,symbOffset,nullIdx,sysParam.pilotIdx);

% Perform channel equalization over entire data frame
estDataChanFrame = reshape(estChannel(dataIdx,2:end), ...
    [length(dataIdx)*(numSymPerFrame-length(ssIdx)-length(rsIdx)-length(headerIdx)) 1]);
equalizedData = ofdmEqualize(...
    demodulatedData(:,headerIdx:end),estDataChanFrame);

% Equalize the pilots as well
equalizedPilots = ofdmEqualize(pilots(:,headerIdx:end), ...
    reshape(estChannel((1:pilotSpacing:usedSubCarr),2:end),[],1));

% Extract header and data subcarriers
userData = equalizedData;

% Recover header information and display decoded modulation, code rate
% and FFT Length
[headerBits] = ...
    OFDMHeaderRecovery(headerData);
[modOrder, ~, fftLength,...
    modName] = OFDMHeaderUnpack(headerBits,sysParam);
% if isfield(sysParam,'isSDR')
%     % if modOrder ~= sysParam.modOrder
%     %     error('The modulation scheme detected (%s), does not match the modulation scheme mentioned in the data parameters. This results in invalid buffer sizes at the receiver and data decoding is not possible',modName);
%     % end
%     % if str2num(codeRate) ~= sysParam.codeRate
%     %     error('The codeRate detected (%s), does not match the codeRate mentioned in the data parameters. This results in invalid buffer sizes at the receiver and data decoding is not possible',codeRate);
%     % end
% end
    if verbosity > 0
        fprintf('Modulation: %s  and FFT Length=%d\n',...
            modName, fftLength);
    end

    % Perform common phase error (CPE) estimation on pilots and
    % compensate
    if sysParam.enableCPE
        % Calculate CPE estimate via averaged least-squares estimates from
        % the pilots
        cpeEst = sum(equalizedPilots.*pilotSignal)/length(pilotSignal);

        % Perform CPE correction
        % Normalize estimate to obtain just the phase error. The correction
        % is then applied to all the data subcarriers
        numSyms = size(userData,2);
        dataConstData = zeros(size(userData));
        
        for symIdx = 1:numSyms
            CPECorrection = (1/sqrt(abs(cpeEst(symIdx))))*conj(cpeEst(symIdx));
            dataEqualized = (userData(:,symIdx)) * CPECorrection;
            dataConstData(:,symIdx) = dataEqualized;
        end
    else
        dataConstData = userData;
    end

    % Recover data bits from data subcarriers
    [llrOutput,decodedDataBits] =...
        OFDMDataRecovery(squeeze(dataConstData),...
        modOrder);
    softLLRs = llrOutput(:);
    if verbosity > 0
        fprintf('Data decoding completed\n');
        fprintf('------------------------------------------\n')
        
    end

rxDataBits = double(decodedDataBits); % convert from logical type to double

% Assign output parameters
diagnostics = struct( ...
    'estCFO',freqOffset,...
    'estChannel',estChannel,...
    'rxConstellationHeader',headerData,...
    'rxConstellationData',dataConstData,...
    'softLLR',softLLRs,...
    'decodedModOrder',modOrder);

end


function [modOrder,fftLenIndex,fftLength,modType] = OFDMHeaderUnpack(inBits,sysParam)
%OFDMHeaderUnpack Unpacks bit information from header
% [modOrder, codeRateIndex, fftLenIndex,fftLength, modType, codeRate] = 
% OFDMHeaderUnpack(inBits)
% inBits - input header bits
% modOrder - modulation order
% codeRateIndex - code rate index
% fftLenIndex - FFT length index
% fftLength - FFT length
% modType - modulation type
% codeRate - code rate
% unpacks input header bits (inBits) into modulation order (modOrder),
% code rate index (codeRateIndex),FFT length index (fftLenIndex),
% FFT length (fftLength), modulation type (modType) and code rate
% (codeRate).
% First 3 bits of header represent FFT Length index
fftLenIndex = bit2int(inBits(1:3),3);

% Next 3 bits represent modulation index value
modIndex = bit2int(inBits(4:6),3);


% Modulation order
if modIndex == 5
    modOrder = 1024;
elseif modIndex == 4
    modOrder = 256;
elseif modIndex == 3
    modOrder = 64;
elseif modIndex == 2
    modOrder = 16;
elseif modIndex == 1
    modOrder = 4;
else
    modOrder = 2;
end

%siccome non è presente alcuna correzione dei bit errati (CRC), impongo
%che la modulazione sia quella che ci si aspetta
if modOrder ~= sysParam.modOrder
    fprintf('Errore nella modulazione. Cambio per evitare il blocco\n');
    modOrder = sysParam.modOrder;
end
% FFT Length value
switch fftLenIndex
    case 0
        fftLength = 64;
    case 2
        fftLength = 256;
    case 3
        fftLength = 512;
    case 4
        fftLength = 1024;
    case 5
        fftLength = 2048;
    case 6
        fftLength = 4096;
    otherwise
        fftLength = 128; % make default 128-length FFT
end

% Modulation Type
switch modOrder
    case 4
        modType = 'QPSK';
    case 16
        modType = '16QAM';
    case 64
        modType = '64QAM';
    case 256
        modType = '256QAM';
    case 1024
        modType = '1024QAM';
    otherwise
        modType = 'BPSK'; % make default BPSK
end


end

function [headerBits] = OFDMHeaderRecovery(headSymb)
%OFDMHeaderRecovery Demodulates and decodes header information
% [headerBits,errFlag] = OFDMHeaderRecovery(headSymb,sysParam)
% takes header data symbols as input and outputs decoded and demodulated
% header information. This function also outputs the CRC Error flag.
% headSymb        - Demodulated constellation header symbols.
% sysParam        - system parameters structure
% headerBits      - Decoded header bits.
% errFlag         - CRC error flag, true if CRC failed

% persistent crcDet;
% if isempty(crcDet)
%     crcDet = crcConfig(...
%         'Polynomial',sysParam.headerCRCPoly, ...
%         'InitialConditions',0, ...
%         'FinalXOR',0);
% end
% 
% traceBackDepth = 30;
% deintrlvLen    = sysParam.headerIntrlvNColumns;

% Demodulazione PSK
headerLLRs = pskdemod(headSymb(:), 2, ...
    OutputType="approxllr");

% Conversione LLR in bit
headerBits = headerLLRs < 0;  % I bit sono 0 quando LLR < 0, 1 quando LLR > 0


% % Deinterleave
% deintrlvOut = reshape(reshape(softBits,[],deintrlvLen).',[],1);
% 
% % Viterbi decoding
% vitOut = vitdec((deintrlvOut(:)),...
%     poly2trellis(sysParam.headerConvK,sysParam.headerConvCode), ...
%     traceBackDepth,'term','unquant');
% 
% % CRC check
% [headerBits,errFlag] = crcDetect(vitOut(1:(end-(sysParam.headerConvK-1))),crcDet);

end

function [softLLRs,outBits] = OFDMDataRecovery(dataIn,modOrd)
%OFDMDataRecovery Recovers data bits
% [softLLRs,outBits,errFlag] = OFDMDataRecovery(dataIn,modOrd,codeIn,sysParam)
% performs symbol demodulation, deinterleaving, decoding, depuncturing,
% descrambling and checks CRC status. This function gives demodulated soft
% LLR information, decoded bits and CRC error flag as outputs.
% dataIn   - input data subcarriers
% modOrd   - modulation order
% codeIn   - code rate index
% sysParam - system parameters structure
% softLLRs - Soft LLR output of OFDM symbol demodulator
% outBits  - decoded bit output of Viterbi decoder
% errFlag  - CRC err flag, outputs 1 for CRC fail and 0 CRC pass.

NData = size(dataIn,2);
modIndex = log2(modOrd);
softLLRs = zeros(length(dataIn)*modIndex, NData);

% Demodulate
for ii = 1:NData
    softLLRs(:,ii) = qamdemod(dataIn(:,ii), modOrd, ...
        OutputType="approxllr", ...
        UnitAveragePower=true);
end

% Output
outBits = softLLRs(:) <0;  % The final output bits after demodulation
end
