function [modOrder, codeRate] = helperChooseModCode(params)
%HELPERCHOOSEMODCODE Summary of this function goes here
%   Detailed explanation goes here
switch params
    case '0000'
         modOrder = 4;  codeRate = "1/2";
    case '0101'
         modOrder = 16; codeRate = "2/3";
    case '1010'
         modOrder = 64;  codeRate = "3/4";
end
end

