%% DISPOSITIVO 1

% -------------------------------------------
%% PROTOCOLLO DI COMUNICAZIONE DI DISPOSITIVO 1 

% * Trasmissione di numFrames simboli per numRip volte
% * Si mette in attesa di ricezione per waitTime secondi
% * Ricomincia la trasmissione
% * Se non riceve riscontro per numAtteseMax volte, il dispositivo inivia un 
% 'Keep Alive'. Se non riceve risposta, termina la trasmissione


% -------------------------------------------
%% SETUP INIZIALE
[OFDMParams,dataParams, GeneralParam] = helperSetParameters();
% Conta la serie di ricezioni del feedback fallite
attese = 0;
% Termina la trasmissione se 0
endureTransmission = 1;
%Conta il numero di ricezioni fallite
ripetizioniRicezione = 0;

% -------------------------------------------

%% TRASMISSIONE

while endureTransmission
    %Settaggio del messaggio da inviare (è modificabile!)
    GeneralParam.message = 'Hello world! ';
    helperTrasmissionModule(GeneralParam, OFDMParams, dataParams);

% -------------------------------------------
%% ATTESA RICEZIONE
    if attese ~= GeneralParam.numAtteseMax
        fprintf('Passo in ricezione\n');
        % Per contrastare il CFO, aggiungo 1kHz alla carrier 
        GeneralParam.carrier_frequency = GeneralParam.carrier_frequency + 0.001;

        [rxFlag, message] = helperReceiverModule(GeneralParam, OFDMParams, dataParams);

        if ~rxFlag && ripetizioniRicezione<3
            %Aggiornamento del numero di ricezioni fallite
            ripetizioniRicezione = ripetizioniRicezione+1;
            pause(0.5);

        elseif ripetizioniRicezione == 3
            % se per 3 volte il TX non si connette o riceve dati troppo
            % rumorosi, aumenta il numero di attese
            attese = attese + 1;
        else 
            %aggiornamento dei parametri di trasmissione
            [dataParams.coderate, dataParams.modOrder] = helperChangeParameters(message);
            fprintf('Feedback ricevuto\n Nuovi parametri:\n Mod: %d\n  CodeRate = %s\n',dataParams.modOrder, dataParams.coderate);
        end

% -------------------------------------------
%% KEEP ALIVE

    else
        %Invio del messaggio di Keep Alive
        GeneralParam.message = 'Keep Alive';
        helperTrasmissionModule(GeneralParam, OFDMParams, dataParams);
        pause(2);
        [rxFlag, messageReceived] = helperReceiverModule(GeneralParam, OFDMParams, dataParams);
        if ~rxFlag
            %Fine della trasmissione. KA non ricevuto
            endureTransmission = 0;
        else
            %Keep alive ricevuto. Si settano i nuovi parametri di
            %trasmissione
            dataParams = helperChangeParameters(messageReceived);
            fprintf('Risposta al KA\n Mod: %d\n  CodeRate = %s\n',dataParams.modOrder, dataParams.coderate);
        end
    end
    %Tolgo 1kHz per trasmettere correttamente
    GeneralParam.carrier_frequency = GeneralParam.carrier_frequency - 0.001;
    pause(2);
end
fprintf('Trasmissione conclusa\nKeep Alive non ricevuto!\n');

% -------------------------------------------