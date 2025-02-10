%% Creazione dataset per addestrare SqueezeNet a classificare interferenze su OFDM
clear; clc;

%% Parametri sistema OFDM
sysParam.BW = 300e3;       % Banda 300 kHz
sysParam.scs = 3e3;        % Spacing subcarrier
sysParam.FFTLen = 128;     % Lunghezza FFT
sysParam.CPLen = sysParam.FFTLen / 4; % Lunghezza prefisso ciclico

BW = sysParam.BW;                  % Banda (in Hz) del segnale OFDM
fs = sysParam.scs * sysParam.FFTLen; % Frequenza di campionamento del segnale OFDM

%% Filtraggio FIR
Fpass = BW/2;               % Frequenza di banda passante
Fstop = fs/2;               % Frequenza di stopband
Dpass = 0.00033136495965;   % Ripple della banda passante
Dstop = 0.05;               % Ripple della banda di stop
dens  = 20;                 % Fattore di densità

[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(fs/2), [1 0], [Dpass, Dstop]);
firCoeff  = firpm(N, Fo, Ao, W, {dens});

%% Definizione delle modulazioni e codifiche
modTypes = {'BPSK', 'QPSK', '16QAM', '64QAM'};
codeRates = [1/2, 2/3, 3/4];
numSamples = 1000; % Numero di campioni per classe

%% Creazione cartelle dataset
outDir = 'dataset_OFDM';
classes = {'Normale', 'Multipath', 'Interferenza_NBI', 'Interferenza_BBI', 'Interferenza_Impulsiva', 'Jamming'};
mkdir(outDir);
for c = classes, mkdir(fullfile(outDir, c{1})); end

for i = 1:numSamples
    % Generiamo un segnale OFDM pulito
    modOrder = randsample([2, 4, 16, 64], 1); % Sceglie una modulazione casuale
    data = randi([0 modOrder-1], sysParam.FFTLen, 1);
    dataBinary = de2bi(data, log2(modOrder), 'left-msb');
    dataBinary = dataBinary(:);
    codedData = convenc(dataBinary, poly2trellis(7, [133 171]));
    codedSymbols = bi2de(reshape(codedData, [], log2(modOrder)), 'left-msb');
    modulatedData = qammod(codedSymbols, modOrder, 'UnitAveragePower', true);
    
    % Indici sottoportanti
    pilotIdx = 10:10:sysParam.FFTLen-10; % Piloti distribuiti meglio
    nullIdx = [1, sysParam.FFTLen/2, sysParam.FFTLen]; % Null carrier stabili
    dataIdx = setdiff(1:sysParam.FFTLen, [pilotIdx, nullIdx]); % Assicura coerenza
    pilotSymbols = ones(1,length(pilotIdx)); % Piloti costanti

    % Creazione frame OFDM con dati, piloti e null carrier
    txOFDM = ofdmmod(modulatedData, sysParam.FFTLen, sysParam.CPLen, nullIdx(:), pilotIdx, pilotSymbols);
    
    % Filtraggio FIR
    txOFDM = filter(firCoeff, 1, txOFDM);
    
    % Normalizzazione potenza
    txOFDM = txOFDM / rms(txOFDM);
    
    % Generiamo disturbi
    rxSignals = struct();
    rxSignals.Normale = txOFDM;
    
    % Multipath (3 percorsi con ritardi casuali)
    multipathChan = comm.RayleighChannel('SampleRate', fs, 'PathDelays', [0 1e-5 3e-5], 'AveragePathGains', [0 -3 -6]);
    rxSignals.Multipath = multipathChan(txOFDM);
    
    % Interferenza a banda stretta (NBI) - Tono sinusoidale
    nbi = 0.3 * exp(1j*2*pi*50e3*(0:length(txOFDM)-1)'/fs);
    rxSignals.Interferenza_NBI = txOFDM + nbi;
    
    % Interferenza a banda larga (BBI) - Altro segnale OFDM
    modBBI = randsample([2, 4, 16, 64], 1);
    dataBBI = randi([0 modBBI-1], sysParam.FFTLen, 1);
    modulatedBBI = qammod(dataBBI, modBBI, 'UnitAveragePower', true);
    txOFDM_BBI = ofdmmod(modulatedBBI, sysParam.FFTLen, sysParam.CPLen, nullIdx(:), [], []);
    rxSignals.Interferenza_BBI = txOFDM + 0.5 * txOFDM_BBI;
    
    % Interferenza impulsiva
    impulseNoise = zeros(size(txOFDM));
    impulseIdx = randi(length(txOFDM), 20, 1);
    impulseNoise(impulseIdx) = 5 * (randn(size(impulseIdx)) + 1j*randn(size(impulseIdx)));
    rxSignals.Interferenza_Impulsiva = txOFDM + impulseNoise;
    
    % Jamming (rumore bianco ad alta potenza)
    noise = 2 * (randn(size(txOFDM)) + 1j*randn(size(txOFDM)));
    rxSignals.Jamming = txOFDM + noise;
    
    % Creazione spettrogrammi e salvataggio
    for field = fields(rxSignals)'
        signal = rxSignals.(field{1});
        spectrogram(signal, 64, 32, 128, fs, 'yaxis');
        colormap('jet');
        axis off;
        saveas(gcf, fullfile(outDir, field{1}, sprintf('%d.png', i)));
        close;
    end
end

fprintf('Dataset generato con successo!\n');

%% Training di SqueezeNet
imds = imageDatastore(outDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
[imdsTrain, imdsTest] = splitEachLabel(imds, 0.8, 'randomized');

net = squeezenet;
inputSize = net.Layers(1).InputSize;
imdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain);
imdsTest = augmentedImageDatastore(inputSize(1:2), imdsTest);

layersTransfer = net.Layers(1:end-3);
numClasses = numel(classes);
newLayers = [fullyConnectedLayer(numClasses, 'Name', 'fc', 'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10);
             softmaxLayer('Name', 'softmax');
             classificationLayer('Name', 'output')];

lgraph = layerGraph(layersTransfer);
lgraph = addLayers(lgraph, newLayers);
lgraph = connectLayers(lgraph, 'drop7', 'fc');

options = trainingOptions('adam', 'MaxEpochs', 10, 'MiniBatchSize', 32, 'InitialLearnRate', 1e-4, 'Verbose', true, 'Plots', 'training-progress');

netTransfer = trainNetwork(imdsTrain, lgraph, options);
save('squeezeNet_OFDM.mat', 'netTransfer');
fprintf('Training completato e rete salvata!\n');
