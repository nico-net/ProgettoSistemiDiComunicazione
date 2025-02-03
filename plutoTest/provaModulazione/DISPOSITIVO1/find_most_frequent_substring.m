function most_frequent_substring = find_most_frequent_substring(input_str, word_length)
    % Convertire la stringa in char array se necessario
    if isstring(input_str)
        input_str = char(input_str);
    end

    % Mappa per contare le occorrenze delle sottostringhe
    substr_count = containers.Map('KeyType', 'char', 'ValueType', 'double');
    n = strlength(input_str);

    % Estrarre solo le sottostringhe con passo di word_length
    for i = 1:word_length:n
        if i + word_length - 1 <= n  % Assicuriamoci di non uscire dai limiti
            sub_str = input_str(i:i + word_length - 1);
            if isKey(substr_count, sub_str)
                substr_count(sub_str) = substr_count(sub_str) + 1;
            else
                substr_count(sub_str) = 1;
            end
        end
    end

    % Trovare la sottostringa più frequente
    max_count = 0;
    most_frequent_substring = "";

    keys_list = keys(substr_count);
    for i = 1:length(keys_list)
        key = keys_list{i};
        if substr_count(key) > max_count
            max_count = substr_count(key);
            most_frequent_substring = string(key); % Converti in stringa
        end
    end
end
