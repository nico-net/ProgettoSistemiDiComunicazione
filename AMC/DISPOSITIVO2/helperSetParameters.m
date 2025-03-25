function [OFDMParams,dataParams, GeneralParam] = helperSetParameters()
%HELPERSETPARAMETERS  Questa funzione setta i parametri comuni per la trasmissione e la
% ricezione delle due pluto.
%OUTPUT:
%   OFDMParams:    parametri della configurazione OFDM
%   dataParams:     parametri specifici di trasmissione
%   GeneralParam:   parametri generali
    
    load SVMModel.mat SVMModel
    %% VARIE
    GeneralParam.carrier_frequency        = 2.4e9;  % Carrier (+1kHz per correzione CFO)
    GeneralParam.gainTx                   = -10;  % TX radio gain
    GeneralParam.gainRx                   = 60;  % RX radio gain
    GeneralParam.threshold                = 5e-1;  %Soglia per decidere se il messaggio ricevuto è corrett
    GeneralParam.model                    = SVMModel;  %Modello di classificazione
    
    %% Parametri OFDM:
    OFDMParams.FFTLength              = 128;   % FFT length
    OFDMParams.CPLength               = 32;    % Cyclic prefix length
    OFDMParams.NumSubcarriers         = 72;    % Number of sub-carriers in the band
    OFDMParams.Subcarrierspacing      = 3e3;  % Sub-carrier spacing 
    OFDMParams.PilotSubcarrierSpacing = 9;     % Pilot sub-carrier spacing
    OFDMParams.channelBW              = 3e5;   % Bandwidth of the channel 
    
    %% Parametri Dati
    % Modulazioni accettate: QPSK(4), 16-QAM(16), 64-QAM (64)
    dataParams.modOrder       = 16;   % Data modulation order
    % Code rate accettati: 1/2, 2/3, 3/4
    dataParams.coderate       = "2/3";   % Code rate
    dataParams.numSymPerFrame = 25;   % Number of data symbols per frame
    dataParams.numFrames      = 500;   % Number of frames to receive
    dataParams.numFramesFB    = 300;  %Number of frames to transmit for feedback
    dataParams.enableScopes   = true;   % Switch to enable or disable the visibility of scopes
    dataParams.verbosity      = true;   % Switch to enable or disable the data diagnostic output
    dataParams.printData      = true;
end

