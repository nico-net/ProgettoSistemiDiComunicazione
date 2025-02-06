function [modOrder, codeRate] = helperChooseModCode(params)

%HELPERCHOOSEMODCODE Questa funzione serve a risalire alla coppia code rate
%e modulation order dal messaggio ricevuto
%INPUT
%   params:     stringa di ingresso
%OUTPUT
%   modOrder:   modulation order
%   codeRate:   code rate

switch params
    case '0000'
         modOrder = 4;  codeRate = "1/2";
    case '0101'
         modOrder = 16; codeRate = "2/3";
    case '1010'
         modOrder = 64;  codeRate = "3/4";
end
end

