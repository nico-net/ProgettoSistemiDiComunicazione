function [OFDMParams,dataParams, GeneralParam] = helperSetParameters()
    % Questa funzione setta i parametri comuni per la trasmissione e la
    % ricezione delle due pluto.
    %% VARIE
    GeneralParam.carrier_frequency        = 865e6;  % Carrier
    GeneralParam.gainTx                   = -20;  % TX radio gain
    GeneralParam.gainRx                   = 40;  % RX radio gain
    GeneralParam.numRip                   = 4;   % Numero ripetizioni trasmissione
    GeneralParam.waitTime                 = 10;  % Attesa in secondi per la ricezione di un ACK
    GeneralParam.numAtteseMax             = 3;   % Numero di attese massimo prima di invio KeepAlive
    GeneralParam.message                  = 'Hello World! ';  % Messaggio da inviare
    
    %% Parametri OFDM:
    OFDMParams.FFTLength              = 128;   % FFT length
    OFDMParams.CPLength               = 32;    % Cyclic prefix length
    OFDMParams.NumSubcarriers         = 72;    % Number of sub-carriers in the band
    OFDMParams.Subcarrierspacing      = 3e3;  % Sub-carrier spacing of 30 KHz
    OFDMParams.PilotSubcarrierSpacing = 9;     % Pilot sub-carrier spacing
    OFDMParams.channelBW              = 3e5;   % Bandwidth of the channel 3 MHz
    
    %% Parametri Dati
    % Modulazioni accettate: QPSK(4), 16-QAM(16), 64-QAM (64)
    dataParams.modOrder       = 64;   % Data modulation order
    % Code rate accettati: 1/2, 2/3, 3/4
    dataParams.coderate       = "3/4";   % Code ra te
    dataParams.numSymPerFrame = 25;   % Number of data symbols per frame 20 for setup1
    dataParams.numFrames      = 30;   % Number of frames to transmit
    dataParams.enableScopes   = true;                    % Switch to enable or disable the visibility of scopes
    dataParams.verbosity      = true;                    % Switch to enable or disable the data diagnostic output

end

