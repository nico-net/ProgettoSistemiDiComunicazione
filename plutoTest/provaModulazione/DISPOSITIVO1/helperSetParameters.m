function [OFDMParams,dataParams, GeneralParam] = helperSetParameters()
    % HELPERSETPARAMETERS Questa funzione setta i parametri comuni per la trasmissione e la
    % ricezione delle due AdalmPluto.

    %% VARIE
    GeneralParam.carrier_frequency        = 865e6;  % Carrier
    GeneralParam.gainTx                   = -10;  % TX radio gain
    GeneralParam.gainRx                   = 50;  % RX radio gain
    GeneralParam.numRipRx                 = 5;   % Numero ripetizioni ascolto
    GeneralParam.waitTime                 = 5;  % Attesa in secondi per la ricezione di un ACK
    GeneralParam.numAtteseMax             = 2;   % Numero di attese massimo prima di invio KeepAlive
    GeneralParam.message                  = 'Hello World! ';  % Messaggio da inviare
    GeneralParam.threshold                = 1e-4;  %Soglia per decidere se il messaggio ricevuto è corretto
    
    %% Parametri OFDM:
    OFDMParams.FFTLength              = 128;   % Lunghezza FFT
    OFDMParams.CPLength               = 32;    % Lunghezza del prefisso ciclico
    OFDMParams.NumSubcarriers         = 72;    % Numero di sottoportanti nella banda
    OFDMParams.Subcarrierspacing      = 3e3;   % Spaziatura tra sottoportanti
    OFDMParams.PilotSubcarrierSpacing = 9;     % Spaziatura tra sottoportanti pilota
    OFDMParams.channelBW              = 3e5;   % Larghezza di banda del canale
    
    %% Parametri Dati
    % Modulazioni accettate: QPSK(4), 16-QAM(16), 64-QAM (64)
    dataParams.modOrder       = 64;       % Ordine di modulazione dei dati
    % Code rate accettati: 1/2, 2/3, 3/4
    dataParams.coderate       = "3/4";   % Code rate
    dataParams.numSymPerFrame = 25;   % Numero di simboli dati per frame
    dataParams.numFrames      = 500;   % Numero di frame da trasmettere
    dataParams.numFramesFB    = 300;   % Numero di frame da ricevere
    dataParams.enableScopes   = true;   % Interruttore per abilitare o disabilitare la visibilità degli scope
    dataParams.verbosity      = true;   % Interruttore per abilitare o disabilitare l'output diagnostico dei dati
    dataParams.printData      = true;   
end

