function [sysParam,txParam,payload] = helperOFDMSetParamsSDR(OFDMParam,dataParam)
%helperOFDMSetParamsSDR(OFDMParam,dataParam) Genera i parametri di simulazione.
%   Questa funzione genera parametri specifici per il trasmettitore e comuni 
%   per il trasmettitore/ricevitore per la simulazione OFDM, basati sulle 
%   impostazioni dei parametri utente di alto livello passati alla funzione helper, 
%   specificamente utilizzati nel SDR. I parametri di codifica possono 
%   essere modificati qui, soggetti ad alcune limitazioni riportate di seguito. 
%   Questa funzione genera anche un payload della dimensione del blocco di trasporto calcolato.
%
%   [sysParam,txParam,payload] = helperOFDMSetParameters(userParam)
%   OFDMParam - struttura dei parametri relativi all'OFDM
%   dataParam - struttura dei parametri relativi ai dati
%   sysParam  - struttura dei parametri di sistema comuni al trasmettitore e ricevitore
%   txParam   - struttura dei parametri del trasmettitore
%   payload   - payload dei dati noti generato per la dimensione del trBlk
% Copyright 2023-2024 The MathWorks, Inc.

% Set shared tx/rx parameter structure
sysParam = struct();

% Set transmit-specific parameter structure
txParam = struct();

txParam.modOrder        = dataParam.modOrder;    

sysParam.isSDR = true;
sysParam.numFrames      = dataParam.numFrames;

sysParam.numSymPerFrame = dataParam.numSymPerFrame; 


% Transmission grid parameters
sysParam.ssIdx = 1;                         % Symbol 1 is the sync symbol
sysParam.rsIdx = 2;                     % Symbol 2 is the reference symbol
sysParam.headerIdx = 3;                     % Symbol 3 is the header symbol

% Simulation options
sysParam.enableCFO = true;
sysParam.enableCPE = true;
sysParam.enableScopes = dataParam.enableScopes;
sysParam.verbosity = dataParam.verbosity;

% Derived parameters from simulation settings
% The remaining parameters are derived from user selections. Checks are
% made to ensure that interdependent parameters are compatible with each
% other.

sysParam.FFTLen         = OFDMParam.FFTLength;      % FFT length
sysParam.CPLen          = OFDMParam.CPLength;       % cyclic prefix length
sysParam.usedSubCarr    = OFDMParam.NumSubcarriers;  % number of active subcarriers
sysParam.BW             = OFDMParam.channelBW;          % total allocated bandwidth
sysParam.scs            = OFDMParam.Subcarrierspacing;         % subcarrier spacing (Hz)
sysParam.pilotSpacing   = OFDMParam.PilotSubcarrierSpacing; 
sysParam.modOrder       = dataParam.modOrder;
numSubCar            = sysParam.usedSubCarr; % Number of subcarriers per symbol
sysParam.pilotIdx    = ((sysParam.FFTLen-sysParam.usedSubCarr)/2) + ...
    (1:sysParam.pilotSpacing:sysParam.usedSubCarr).';

% Check if a pilot subcarrier falls on the DC subcarrier; if so, then shift
% up the rest of the pilots by a subcarrier
dcIdx = (sysParam.FFTLen/2)+1;
if any(sysParam.pilotIdx == dcIdx)
    sysParam.pilotIdx(floor(length(sysParam.pilotIdx)/2)+1:end) = 1 + ...
        sysParam.pilotIdx(floor(length(sysParam.pilotIdx)/2)+1:end);
end

% Error checks
pilotsPerSym = numSubCar/sysParam.pilotSpacing;
if floor(pilotsPerSym) ~= pilotsPerSym
    error('Number of subcarriers must be evenly divisible by the pilot spacing.');
end
sysParam.pilotsPerSym = pilotsPerSym;


if sysParam.numFrames < ceil(144/sysParam.numSymPerFrame)
    error('Number of frames must allow at least 144 symbols to be transmitted for AFC.');
end

numDataOFDMSymbols = sysParam.numSymPerFrame - ...
    length(sysParam.ssIdx)  - length(sysParam.rsIdx) - ...
    length(sysParam.headerIdx);             % Number of data OFDM symbols
if numDataOFDMSymbols < 1
    error('Number of symbols per frame must be greater than the number of sync, header, and reference symbols.');
end

% Calculate transport block size (trBlkSize) using parameters
bitsPerModSym = log2(txParam.modOrder);     % Bits per modulated symbol
numSubCar = sysParam.usedSubCarr;           % Number of subcarriers per symbol
pilotsPerSym = numSubCar / sysParam.pilotSpacing; % Number of pilots per symbol

% Calcolo della dimensione del blocco non codificato
uncodedPayloadSize = (numSubCar - pilotsPerSym) * numDataOFDMSymbols * bitsPerModSym;

% Aggiorna i parametri di sistema per supportare il blocco non codificato
sysParam.trBlkPadSize = 0;                  % Nessun padding per il blocco non codificato
sysParam.trBlkSize = uncodedPayloadSize;    % La dimensione del blocco è direttamente quella non codificata
sysParam.txWaveformSize = ((sysParam.FFTLen +sysParam.CPLen)*sysParam.numSymPerFrame);
sysParam.timingAdvance = sysParam.txWaveformSize;
sysParam.modOrder = dataParam.modOrder;

% Generate payload message
sysParam.NumBitsPerCharacter = 7;
payloadMessage = 'Hello World! ';
messageLength = length(payloadMessage);
numPayloads = ceil(sysParam.trBlkSize/(messageLength*sysParam.NumBitsPerCharacter)); 
message = repmat(payloadMessage,1,numPayloads);
trBlk = reshape(int2bit(double(message),sysParam.NumBitsPerCharacter),1,[]);
payload = trBlk(1:sysParam.trBlkSize);
end