function foffset = helperOFDMFrequencyOffset(rxWaveform,sysParam)
%helperOFDMFrequencyOffset Stima l'offset di frequenza utilizzando il prefisso ciclico.
%   Questa funzione stima l'offset di frequenza medio (foffset) utilizzando
%   la forma d'onda ricevuta nel dominio del tempo. La porzione di prefisso ciclico
%   della forma d'onda ricevuta viene correlata con la parte finale del simbolo
%   per stimare l'offset di frequenza. Questa correlazione viene mediata su sei
%   simboli e l'angolo di correlazione massimo viene trovato e memorizzato in un
%   buffer. Vengono mediati 24 angoli per ottenere la stima finale dell'offset di frequenza (CFO).

%   foffset = helperOFDMFrequencyOffset(rxWaveform,sysParam) 
%   rxWaveform - forma d'onda di ingresso nel dominio del tempo
%   sysParam - struttura dei parametri di sistema
%   foffset - offset di frequenza normalizzato alla frequenza del simbolo.
%   Un valore di 1.0 equivale alla spaziatura tra i sottoportanti.

% Copyright 2023 The MathWorks, Inc.

nFFT     = sysParam.FFTLen; 
cpLength = sysParam.CPLen;
symbLen  = nFFT + cpLength;
buffLen  = length(rxWaveform);

numSymPerFrame = sysParam.numSymPerFrame;
numSampPerFrame = numSymPerFrame*symbLen;

% For per-frame processing, maintain last samples in an averaging buffer
persistent sampleAvgBuffer;
if isempty(sampleAvgBuffer)
    numFrames = floor(buffLen/numSampPerFrame);
    numAvgCols = ceil((150+numFrames)/6); % (24+1)*6 symbol minimum for averaging
    sampleAvgBuffer = zeros(6*numAvgCols*symbLen,1);
end

corrIn = [sampleAvgBuffer(numSampPerFrame+1:end); rxWaveform];
sampleAvgBuffer = corrIn;

% Form two correlator inputs, the second delayed from
% the first by nFFT.
arm1 = corrIn(1:end);
arm2 = [zeros(nFFT,1); corrIn(1:end-nFFT)];

% Conjugate multiply the inputs and integrate over the cyclic
% prefix length.
cpcorrunfilt = arm1.*conj(arm2);

cpcorrunfilt1 = cpcorrunfilt;
cpcorrunfilt2 = [zeros(cpLength,1); cpcorrunfilt(1:end-cpLength)];

cpCorr = cpcorrunfilt1-cpcorrunfilt2;
cpCorrFinal = cumsum(cpCorr)/cpLength;

% Perform Moving average filter of length 6
data = zeros(length(cpCorrFinal),6);
for ii = 1:6
    data(:,ii) = [zeros((ii-1)*symbLen,1); cpCorrFinal(1:end-(ii-1)*symbLen)];
end

avgCorr = sum(data,2)/6;

ObjMagOp   = abs(avgCorr);
ObjAngleOp = angle(avgCorr);
magOutput  = ObjMagOp;

% Divide the output angle by 2 to normalize
angleOutput = ObjAngleOp/(2*pi);

% Consider a window of 6 OFDM symbols
samplesfor6symbols = 6*symbLen;
maxOPNum = floor(length(magOutput)/samplesfor6symbols);

magOpReshape = reshape(magOutput(1:samplesfor6symbols*maxOPNum),samplesfor6symbols,maxOPNum);
angleOpReshape = reshape(angleOutput(1:samplesfor6symbols*maxOPNum),samplesfor6symbols,maxOPNum);

% Find max angle for every 6 OFDM symbols
maxMagOp = zeros(maxOPNum,1);
maxAngOp = zeros(maxOPNum,1);
for ii=1:maxOPNum
    [maxMagOp(ii),loc] = max(magOpReshape(:,ii));
    maxAngOp(ii) = angleOpReshape(loc,ii);
end

% Perform moving average filter of length 24
maxAngOpFinal = maxAngOp-[zeros(24,1); maxAngOp(1:end-24)];
foff = cumsum(maxAngOpFinal)/24;

% Repeat the values for every 6 OFDM symbols
cfoVal = ones(samplesfor6symbols,1)*[0;foff].';
cfoValFlat = cfoVal(:);

foffset = cfoValFlat(end-buffLen+1:end);

end
