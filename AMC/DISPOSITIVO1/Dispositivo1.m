%% DISPOSITIVO 1
clear all; clc; close all;
% -------------------------------------------
%% PROTOCOLLO DI COMUNICAZIONE DI DISPOSITIVO 1 

% * Trasmissione di numFrames simboli per numRip volte
% * Si mette in attesa di ricezione per waitTime secondi
% * Ricomincia la trasmissione
% * Se non riceve riscontro per numAtteseMax volte, il dispositivo termina
%   trasmissione

% -------------------------------------------
%% SETUP INIZIALE
[OFDMParams,dataParams, GeneralParam] = helperSetParameters();
% Conta la serie di ricezioni del feedback fallite
attese = 0;
% Termina la trasmissione se 0
endureTransmission = 1;
%Conta il numero di ricezioni fallite
%ripetizioniRicezione = 0;

% -------------------------------------------

%% TRASMISSIONE

while endureTransmission
    fprintf('Sono in trasmissione\n');
    %plotting dell'ordine della costellazione e del code rate
    helperPlotter(str2num(dataParams.coderate), dataParams.modOrder)

    %Settaggio del messaggio da inviare (è modificabile, ma bisogna modifi-
    % care anche la stringa ricevuta in DISPOSITIVO 2!)
    GeneralParam.message = 'Hello world!';
    helperTrasmissionModule(GeneralParam, OFDMParams, dataParams);

% -------------------------------------------
%% ATTESA RICEZIONE
    if attese ~= GeneralParam.numAtteseMax
        fprintf('Passo in ricezione\n');
        % Per contrastare il CFO, aggiungo 1kHz alla carrier 
        %GeneralParam.carrier_frequency = GeneralParam.carrier_frequency + 0.001;
        ripetizioniRicezione=0;
    while ripetizioniRicezione<=3
        [rxFlag, message] = helperReceiverModule(GeneralParam, OFDMParams, dataParams);

        if ~rxFlag && ripetizioniRicezione<3
            %Aggiornamento del numero di ricezioni fallite
            ripetizioniRicezione = ripetizioniRicezione+1;
            fprintf('Non ho ricevuto niente. Riprovo\n');
            pause(3);

        elseif ripetizioniRicezione == 3
            % se per 3 volte il TX non si connette o riceve dati troppo
            % rumorosi, aumenta il numero di attese
            attese = attese + 1;
            ripetizioniRicezione = ripetizioniRicezione+1;
        else 
            %aggiornamento dei parametri di trasmissione
            [dataParams.coderate, dataParams.modOrder] = helperChangeParameters(message);
            ripetizioniRicezione=4;
            fprintf('Feedback ricevuto\n Nuovi parametri:\n Mod: %d\n  CodeRate = %s\n',dataParams.modOrder, dataParams.coderate);
        end
    end
    else
        endureTransmission = 0;
    end
    %Tolgo 1kHz per trasmettere correttamente
    %GeneralParam.carrier_frequency = GeneralParam.carrier_frequency - 0.001;
    pause(8);
end
fprintf('Trasmissione conclusa\n Feedback non ricevuto per %d volte\n', ...
    GeneralParam.numAtteseMax);

% -------------------------------------------