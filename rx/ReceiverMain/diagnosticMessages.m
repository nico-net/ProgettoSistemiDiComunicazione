function message = diagnosticMessages(diagnostics)
% Ottieni i valori dei campi della struct
fields = fieldnames(diagnostics);

% Inizializza il messaggio vuoto
message = "";

% Scorri i campi e aggiungi i valori al messaggio
for i = 1:numel(fields)
    fieldValue = diagnostics.(fields{i});
    
    % Converti il valore del campo in stringa
    if isnumeric(fieldValue) || islogical(fieldValue)
        valueStr = mat2str(fieldValue); % Per numeri e array
    elseif ischar(fieldValue)
        valueStr = fieldValue; % Per stringhe
    else
        valueStr = 'Unsupported Type'; % Per altri tipi (ad es. struct o cell)
    end
    
    % Aggiungi al messaggio con punto e virgola
    message = message + valueStr + "; ";
end

% Rimuovi l'ultimo "; " superfluo
message = strip(message, "; ");

% Visualizza il messaggio
disp(message);

end