function [txWaveform,grid,diagnostics] = helperOFDMTx(txParamConfig,sysParam,txObj)
%helperOFDMTx Genera la forma d'onda del trasmettitore OFDM
%   Genera la forma d'onda del trasmettitore OFDM con sincronizzazione, 
%   riferimento, header, piloti e segnali dati. Questa funzione restituisce 
%   txWaveform, txGrid e diagnostica utilizzando i parametri del trasmettitore txParamConfig.
%
%   [txWaveform,grid,diagnostics] = helperOFDMTx(txParamConfig,sysParam,txObj)
%   txParamConfig - Specificato come struttura o array di strutture con 
%   i seguenti attributi:
%   modOrder      - Specificare 2, 4, 16, 64, 256 o 1024 
%   codeRateIndex - Specificare 0, 1, 2 o 3 per i code rate '1/2', '2/3',
%                   '3/4' e '5/6' rispettivamente. 
%   txDataBits    - Specificare valori binari in un vettore riga o colonna di 
%                   lunghezza trBlkSize. Il valore predefinito è un vettore colonna 
%                   contenente valori binari generati casualmente di lunghezza trBlkSize.
%
%   Calcolo della dimensione del blocco di trasporto (trBlkSize):
%   numSubCar - Numero di sottoportanti dati per simbolo
%   pilotsPerSym - Numero di piloti per simbolo
%   numDataOFDMSymbols - Numero di simboli OFDM dati per frame
%   bitsPerModSym - Numero di bit per simbolo modulato
%   codeRate - Code rate dopo la punteggiatura
%   dataConvK - Lunghezza del vincolo dell'encoder convoluzionale
%   dataCRCLen - Lunghezza del CRC
%   trBlkSize = ((numSubCar - pilotsPerSym) * 
%              numDataOFDMSymbols * bitsPerModSym * codeRate) - 
%              (dataConvK-1) - dataCRCLen
%
%   txWaveform  - Forma d'onda del trasmettitore, restituita come un vettore colonna 
%               di lunghezza ((fftLen+cpLen)*numSymPerFrame), dove:
%               fftLen - Lunghezza FFT
%               cpLen - Lunghezza del prefisso ciclico
%               numSymPerFrame - Numero di simboli OFDM per frame
%
%   grid        - Griglia, restituita come una matrice di dimensioni
%               numSubCar-by-numSymPerFrame
%
%   diagnostics - Diagnostica, restituita come una struttura o un array di strutture
%   basata su txParamConfig. La diagnostica ha i seguenti attributi:
%   headerBits - Bit di intestazione come vettore colonna di dimensione 22, che include:
%                Numero di bit per rappresentare l'indice di lunghezza FFT     =  3
%                Numero di bit per rappresentare il tipo di modulazione        =  2
%                Numero di bit per rappresentare l'indice del code rate        =  2
%                Numero di bit di riserva                                      = 15
%   dataBits   - Bit effettivi trasmessi
%                dataBits è un vettore binario riga o colonna di lunghezza 
%                trBlkSize. La forma (riga o colonna) dipende dalla dimensione di 
%                txParamConfig.dataBits. La dimensione predefinita è un vettore 
%                colonna di lunghezza trBlkSize.
%   ofdmModOut - Uscita modulata OFDM come vettore colonna di lunghezza
%                (fftLen+cpLen)*numSymPerFrame.
% Copyright 2023 The MathWorks, Inc.

ssIdx = sysParam.ssIdx;         % sync symbol index
rsIdx = sysParam.rsIdx;         % reference symbol index
headerIdx = sysParam.headerIdx; % header symbol index
numCommonChannels = length(ssIdx) + length(rsIdx) + length(headerIdx);

% Generate OFDM modulator output for each input configuration structure
fftLen = sysParam.FFTLen;   % FFT length
cpLen  = sysParam.CPLen;    % CP length
numSubCar = sysParam.usedSubCarr; % Number of subcarriers per OFDM symbol
numSymPerFrame = sysParam.numSymPerFrame; % Number of OFDM symbols per frame

% Initialize transmitter grid
grid = zeros(numSubCar,numSymPerFrame);

% Derive actual parameters from inputs
[modType,bitsPerModSym] = ...
    getParameters(txParamConfig.modOrder);

%% Synchronization signal generation
syncSignal = helperOFDMSyncSignal();
syncSignalInd = (numSubCar/2) - 31 + (1:62);

% Load synchronization signal on the grid
grid(syncSignalInd,ssIdx) = syncSignal;

%% Reference signal generation
refSignal = helperOFDMRefSignal(numSubCar);
refSignalInd = 1:length(refSignal);

% Load reference signals on the grid
grid(refSignalInd,rsIdx(1)) = refSignal;

%% Header generation
% Generate header bits
% Map FFT length
nbitsFFTLenIndex = 3;
switch fftLen
    case 64                               % 0 -> 64
        FFTLenIndexBits = dec2bin(0,nbitsFFTLenIndex) == '1';
    case 128                              % 1 -> 128
        FFTLenIndexBits = dec2bin(1,nbitsFFTLenIndex) == '1';
    case 256                              % 2 -> 256
        FFTLenIndexBits = dec2bin(2,nbitsFFTLenIndex) == '1';
    case 512                              % 3 -> 512
        FFTLenIndexBits = dec2bin(3,nbitsFFTLenIndex) == '1';
    case 1024                             % 4 -> 1024
        FFTLenIndexBits = dec2bin(4,nbitsFFTLenIndex) == '1';
    case 2048                             % 5 -> 2048
        FFTLenIndexBits = dec2bin(5,nbitsFFTLenIndex) == '1';
    case 4096                             % 6 -> 4096
        FFTLenIndexBits = dec2bin(6,nbitsFFTLenIndex) == '1';
end

% Map modulation order
nbitsModTypeIndex = 3;
switch modType
    case 'BPSK'                                % 0 -> BPSK
        modTypeIndexBits = dec2bin(0,nbitsModTypeIndex) == '1';
    case 'QPSK'                                % 1 -> QPSK
        modTypeIndexBits = dec2bin(1,nbitsModTypeIndex) == '1';
    case '16QAM'                               % 2 -> 16-QAM
        modTypeIndexBits = dec2bin(2,nbitsModTypeIndex) == '1';
    case '64QAM'                               % 3 -> 64-QAM
        modTypeIndexBits = dec2bin(3,nbitsModTypeIndex) == '1';
    case '256QAM'                              % 4 -> 256-QAM
        modTypeIndexBits = dec2bin(4,nbitsModTypeIndex) == '1';
    case '1024QAM'                             % 5 -> 1024-QAM
        modTypeIndexBits = dec2bin(5,nbitsModTypeIndex) == '1';
end

% Map code rate index
% nbitsCodeRateIndex = 2;
% switch txParamConfig.codeRateIndex
%     case 0
%         codeRateIndexBits = dec2bin(0,nbitsCodeRateIndex) == '1';
%     case 1
%         codeRateIndexBits = dec2bin(1,nbitsCodeRateIndex) == '1';
%     case 2
%         codeRateIndexBits = dec2bin(2,nbitsCodeRateIndex) == '1';
%     case 3
%         codeRateIndexBits = dec2bin(3,nbitsCodeRateIndex) == '1';
% end
headerBits = [FFTLenIndexBits, modTypeIndexBits];
diagnostics.headerBits = headerBits.';
headerSymInd = (numSubCar/2) - 36 + (1:72);
% Controlla il numero di sottoportanti disponibili
numHeaderSubcarriers = length(headerSymInd); % Deve essere 72

% Ripeti o ridimensiona i bit per adattarli ai sottoportanti disponibili
if length(headerBits) < numHeaderSubcarriers
    % Se i bit sono meno, aggiungi padding
    headerBits = [headerBits, zeros(1, numHeaderSubcarriers - length(headerBits))];
elseif length(headerBits) > numHeaderSubcarriers
    % Se i bit sono troppi, troncali
    headerBits = headerBits(1:numHeaderSubcarriers);
end

% Modula l'header in BPSK
headerSym = pskmod(headerBits', 2, InputType="bit");

% Carica il segnale di header nella griglia OFDM

grid(headerSymInd, headerIdx) = headerSym;

%% Pilot generation
% Number of data/pilots OFDM symbols per frame
numDataOFDMSymbols = numSymPerFrame - numCommonChannels;
pilot    = helperOFDMPilotSignal(sysParam.pilotsPerSym);    % Pilot signal values
pilot    = repmat(pilot,1,numDataOFDMSymbols);              % Pilot symbols per frame
pilotGap = sysParam.pilotSpacing;                           % Pilot signal repetition gap in OFDM symbol
pilotInd = (1:pilotGap:numSubCar).';

%% Data generation
% Initialize convolutional encoder parameters
% dataConvK = sysParam.dataConvK;
% dataConvCode = sysParam.dataConvCode;

% Calculate transport block size
trBlkSize = sysParam.trBlkSize;
if (~isfield(txParamConfig,{'txDataBits'})) || ...
        isempty(txParamConfig.txDataBits)
    % Generate random bits if txDataBits is not a field
    txParamConfig.txDataBits = randi([0 1],trBlkSize,1);
else
    % Pad appropriate bits if txDataBits is less than required bits
    if length(txParamConfig.txDataBits) < trBlkSize
        if isrow(txParamConfig.txDataBits)
            txParamConfig.txDataBits = ...
                [txParamConfig.txDataBits zeros(1,trBlkSize-length(txParamConfig.txDataBits))];
        else
            txParamConfig.txDataBits = ...
                [txParamConfig.txDataBits ; zeros((trBlkSize-length(txParamConfig.txDataBits)),1)];
        end
    end
end
diagnostics.dataBits = txParamConfig.txDataBits(1:trBlkSize);

% Retrieve data to form a transport block
dataBits = txParamConfig.txDataBits;
% if isrow(dataBits)
%     dataBits = dataBits.';
% end
% 
% % Append CRC bits to data bits
% % crcData = crcGenerate(dataBits, txObj.crcDataGen);
% 
% % Additively scramble using scramble polynomial
% % scrOut = xor(crcData,txObj.pnSeq(sysParam.initState));
% 
% % Perform convolutional coding
% % dataEnc = convenc([scrOut;zeros(dataConvK-1,1)], ...
% %     poly2trellis(dataConvK,dataConvCode),puncVec); % Terminated mode
% % dataEnc = [dataEnc; zeros(sysParam.trBlkPadSize,1)]; % append pad to factorize payload length
% % dataEnc = reshape(dataEnc,[],numDataOFDMSymbols); % form columns of symbols
% 
% % Perform interleaving and symbol modulation
% modData   = zeros(numel(dataBits)/(numDataOFDMSymbols*bitsPerModSym),numDataOFDMSymbols);
% for i = 1:numDataOFDMSymbols
%     % Interleave each symbol
%     %intrlvOut = OFDMInterleave(dataEnc(:,i),sysParam.dataIntrlvNColumns);
% 
%     % Modulate the symbol
%     modData(:,i) = qammod(intrlvOut,txParamConfig.modOrder,...
%         UnitAveragePower=true,InputType="bit");
% end
% modDataInd = 1:numSubCar;
% Assicurati che i dati siano in formato colonna
if isrow(dataBits)
    dataBits = dataBits.';
end

% Calcolo dei parametri di modulazione
if mod(numel(dataBits), bitsPerModSym) ~= 0
    error("Il numero di bit trasmessi deve essere divisibile per il numero di bit per simbolo QAM.");
end

% Esegui la modulazione direttamente senza interleaving o codifica
modData = qammod(dataBits, txParamConfig.modOrder, ...
    UnitAveragePower=true, InputType="bit");

% Organizza i simboli modulati in base al numero di simboli OFDM
modData = reshape(modData, [], numDataOFDMSymbols);

% Assegna l'indice dei sottocarrier
modDataInd = 1:numSubCar;

% Remove the pilot indices from modData indices
modDataInd(pilotInd) = [];

% Load data and pilots on the grid
grid(pilotInd,(headerIdx+1:numSymPerFrame)) = pilot;
grid(modDataInd,(headerIdx+1:numSymPerFrame)) = modData;
   
%% OFDM modulation
dcIdx = (fftLen/2)+1;

% Generate sync symbol
nullLen = (fftLen - 62)/2;
syncNullInd = [1:nullLen dcIdx fftLen-nullLen+2:fftLen].';
ofdmSyncOut = ofdmmod(syncSignal,fftLen,cpLen,syncNullInd);

% Generate reference symbol
nullInd = [1:((fftLen-numSubCar)/2) dcIdx ((fftLen+numSubCar)/2)+1+1:fftLen].';
ofdmRefOut  = ofdmmod(refSignal,fftLen,cpLen,nullInd);

% Generate header symbol
nullLen = (fftLen - 72)/2;
headerNullInd = [1:nullLen dcIdx fftLen-nullLen+2:fftLen].';
ofdmHeaderOut = ofdmmod(headerSym,fftLen,cpLen,headerNullInd);

% Generate data symbols with embedded pilot subcarriers
ofdmDataOut = ofdmmod(modData,fftLen,cpLen,nullInd,sysParam.pilotIdx,pilot);
ofdmModOut = [ofdmSyncOut; ofdmRefOut; ofdmHeaderOut; ofdmDataOut];

% Filter OFDM modulator output
txWaveform = txObj.txFilter(ofdmModOut);

% Collect diagnostic information
diagnostics.ofdmModOut = txWaveform.';

end

function [modType,bitsPerModSym] = getParameters(modOrder)
% Select modulation type and bits per modulated symbol
switch modOrder
    case 2
        modType = 'BPSK';
        bitsPerModSym  = 1;
    case 4
        modType = 'QPSK';
        bitsPerModSym  = 2;
    case 16
        modType = '16QAM';
        bitsPerModSym  = 4;
    case 64
        modType = '64QAM';
        bitsPerModSym  = 6;
    case 256
        modType = '256QAM';
        bitsPerModSym  = 8;
    case 1024
        modType = '1024QAM';
        bitsPerModSym  = 10;
    otherwise
        modType = 'QPSK';
        bitsPerModSym  = 2;
        fprintf('\n Invalid modulation order. By default, QPSK is applied. \n');
end
end

function intrlvOut = OFDMInterleave(in,dataIntrlvLen)

lenIn = size(in,1);
numIntRows = ceil(lenIn/dataIntrlvLen);
numInPad = (dataIntrlvLen*numIntRows) - lenIn;  % number of padded entries needed to make the input data length factorable
numFullCols = dataIntrlvLen - numInPad;
inPad = [in ; zeros(numInPad,1)];               % pad the input data so it is factorable
temp = reshape(inPad,dataIntrlvLen,[]).';       % form interleave matrix
temp1 = reshape(temp(:,1:numFullCols),[],1);    % extract out the full rows
if numInPad ~= 0
    temp2 = reshape(temp(1:numIntRows-1,numFullCols+1:end),[],1); % extract out the partially-filled rows
else
    temp2 = [];
end
intrlvOut = [temp1 ; temp2]; % concatenate the two rows

end
