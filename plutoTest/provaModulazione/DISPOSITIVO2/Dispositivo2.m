%% DISPOSITIVO 2

% -------------------------------------------
%% PROTOCOLLO DI COMUNICAZIONE
% * Ricezione del messaggio inviato da dispositivo 1
% * Classificazione della comunicazione e cambio di code rate e modulation order
% * Invio dei nuovi parametri di trasmissione
% * Se viene ricevuto un keep alive, invia gli ultimi  inviati.

% -------------------------------------------
%% SETUP INIZIALE
[OFDMParams,dataParams, GeneralParam] = helperSetParameters();
endureCommunication = 1;

% Conta il numero di volte in cui il RX non si connette con il TX
ripetizioniRicezione = 0;

% -------------------------------------------
%% RICEZIONE E TRASMISSIONE
while endureCommunication

    fprintf('In attesa di ricezione\n');
    [rxFlag, params] = helperReceiverModule(GeneralParam, OFDMParams, dataParams);
    while ripetizioniRicezione <3
        if ~rxFlag && ripetizioniRicezione < 3
            %Aggiornamento del numero di ricezioni fallite
            ripetizioniRicezione = ripetizioniRicezione+1;
        
        elseif ripetizioniRicezione == 3
            % se per 3 volte il RX non si connette o riceve dati troppo
            % rumorosi, termina la comunicazione
            endureCommunication = 0;
        else
            ripetizioniRicezione = 0;
            fprintf('Passo in trasmissione\n');
            %Nuovo messaggio da inviare
            GeneralParam.message = params;
        
            %Il ricevitore cambia i propri parametri di ricezione perché si
            %aspetta che il TX riceva il feedback. In caso contrario, riconosce che i parametri
            %sono differenti e salva i parametri che gli invia il TX nel
            %header.
            [dataParams.modOrder, dataParams.coderate] = helperChooseModCode(params); 
        
            %Tolgo 1kHz per trasmettere correttamente
            GeneralParam.carrier_frequency = GeneralParam.carrier_frequency - 0.001;
        
            %Attesa di 3s per sincronizzarsi con il TX
            pause(5);
            helperTrasmissionModule(GeneralParam,OFDMParams, dataParams);
            pause(5);
             % Per contrastare il CFO, aggiungo 1kHz alla carrier del ricevitore
            GeneralParam.carrier_frequency = GeneralParam.carrier_frequency + 0.001;
        end
    end
end
fprintf('Comunicazione terminata\nNon è stato ricevuto nulla!\n');
% -------------------------------------------