%% DISPOSITIVO 2
clear; clc;
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

% -------------------------------------------
%% RICEZIONE E TRASMISSIONE
while endureCommunication
    ripetizioniRicezione = 0;
    fprintf('In attesa di ricezione\n');
     while ripetizioniRicezione <=4
        [rxFlag, params, estCFO] = helperReceiverModule(GeneralParam, OFDMParams, dataParams);
        
        if ~rxFlag && ripetizioniRicezione < 4
            %Aggiornamento del numero di ricezioni fallite
            ripetizioniRicezione = ripetizioniRicezione+1;

            %Se ci sono troppi fail nel CRC dell'header allora c'è un problema con
            %il CFO, quindi somma alla carrier il CFO stimato.
            GeneralParam.carrier_frequency = GeneralParam.carrier_frequency - estCFO;
            fprintf(['\nLa comunicazione non è avvenuta o è troppo disturbata. ' ...
                'Riprovo la ricezione\n']);
            pause(3);
        
        elseif ~rxFlag && ripetizioniRicezione == 4
            % se per 3 volte il RX non si connette o riceve dati troppo
            % rumorosi, termina la comunicazione
            endureCommunication = 0;
            ripetizioniRicezione = ripetizioniRicezione+1;
            
        elseif rxFlag
            GeneralParam.carrier_frequency = 865e6;
            fprintf('Passo in trasmissione\n');
            %Nuovo messaggio da inviare
            GeneralParam.message = params;
        
            %Il ricevitore cambia i propri parametri di ricezione perché si
            %aspetta che il TX riceva il feedback. In caso contrario, riconosce che i parametri
            %sono differenti e salva i parametri che gli invia il TX nel
            %header.
            [dataParams.modOrder, dataParams.coderate] = helperChooseModCode(params); 
        
            %Attesa di 3s per sincronizzarsi con il TX
            pause((ripetizioniRicezione - 3) * (-4));
            helperTrasmissionModule(GeneralParam,OFDMParams, dataParams);
            ripetizioniRicezione = 5;
        end
    end
end
fprintf('Comunicazione terminata\nNon è stato ricevuto nulla!\n');
% -------------------------------------------