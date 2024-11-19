function outputStruct = stringToStruct(inputString, fieldNames)
    % INPUT:
    % inputString - stringa con valori separati da ";"
    % fieldNames  - cell array con i nomi dei campi della struct
    %
    % OUTPUT:
    % outputStruct - struct risultante con i campi specificati

    % Dividi la stringa nei valori separati da ";"
    values = split(strip(inputString), ';');
    
    % Inizializza la struct
    outputStruct = struct();
    
    % Verifica che il numero di fieldNames e valori corrisponda
    if numel(values) ~= numel(fieldNames)
        error('Il numero di valori non corrisponde al numero di campi.');
    end
    
    % Popola la struct con i valori convertiti
    for i = 1:numel(fieldNames)
        fieldName = fieldNames{i};
        valueStr = strtrim(values{i});
        
        % Tenta di convertire il valore in numerico o array
        if contains(valueStr, '[') || contains(valueStr, ']') % Array numerico
            value = str2num(valueStr); %#ok<ST2NM> 
        elseif isnumeric(str2double(valueStr)) && ~isnan(str2double(valueStr)) % Numero scalare
            value = str2double(valueStr);
        elseif strcmpi(valueStr, 'true') || strcmpi(valueStr, 'false') % Logico
            value = strcmpi(valueStr, 'true');
        else % Lascia come stringa
            value = valueStr;
        end
        
        % Aggiungi il campo alla struct
        outputStruct.(fieldName) = value;
    end
end
