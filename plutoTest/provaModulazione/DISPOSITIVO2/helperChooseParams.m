function params = helperChooseParams(class)
%HELPERCHOOSEPARAMS La funzione crea la stringa da inviare come feedback
%sulla base della classificazione del canale
%INPUT
%   class:  classificazione
%OUTPUT
%   params:     stringa da trasmettere
switch class
    case 0
        % modOrder = 4  codeRate = 1/2
        params = '0000';
    case 1
        % modOrder = 16  codeRate = 2/3
        params = '0101';
    case 2
        % modOrder = 64  codeRate = 3/4
        params = '1010';
end
end

