function deintrlvOut = OFDMDeinterleave(softLLRs,deintrlvLen)

lenIn = size(softLLRs,1);
numIntCols = ceil(lenIn/deintrlvLen);
numInPad = (deintrlvLen*numIntCols) - lenIn; % number of padded entries needed to make the input data length factorable
numFullRows = deintrlvLen - numInPad;
temp1 = reshape(softLLRs(1:numFullRows*numIntCols), ...
    numIntCols,numFullRows).'; % form full rows
if numInPad ~= 0
    temp2 = reshape(softLLRs(numFullRows*numIntCols+1:end), ...
        numIntCols-1,[]).'; % form partially-filled rows
    temp2 = [temp2 zeros(numInPad,1)];
else
    temp2 = [];
end
temp = [temp1; temp2]; % concatenate the two matrices
tempout = temp(:);
deintrlvOut = tempout(1:end-numInPad);

end




function [outBits, errFlag]=provaF(dataIn, sysParam)

persistent pnSeq;
if isempty(pnSeq)
    pnSeq = comm.PNSequence(Polynomial='x^-7 + x^-3 + 1',...
        InitialConditionsSource="Input port",...
        MaskSource="Input port",...
        VariableSizeOutput=true,...
        MaximumOutputSize=[4570 + 32 + ...
            7 1]);
end

% Create a persistent CRC object
persistent crcDet;
if isempty(crcDet)
    crcDet = crcConfig(...
        'Polynomial',sysParam.CRCPoly,...
        'InitialConditions',0,...
        'FinalXOR',0);
end

dataConvK      = 7;
dataConvCode   = [171,133]; 
traceBackDepth = 45; 
puncVec        = [1,1,0,1];

NData = size(dataIn,2);
len   = size(dataIn,1);
modIndex = log2(sysParam.modOrder);
softLLRs = zeros(len*modIndex,NData);
deintrlvOut = zeros(size(softLLRs));
%dataIn = dataIn*4./norm(dataIn);
% Demodulate and deinterleave
for ii = 1:NData
    % Demodulate
    softLLRs(:,ii) = qamdemod(dataIn(:,ii),sysParam.modOrder,...
        UnitAveragePower=true,...
        OutputType="approxllr");

    % Deinterleave
    deintrlvOut(:,ii) = OFDMDeinterleave(softLLRs(:,ii), ...
        sysParam.dataIntrlvNColumns);

end

% Convolutional decoding
vitDecIn = deintrlvOut(:);
%vitDecIn = softLLRs(:);
% figure;
% stem(dataEnc,'r');
% hold on
% stem(vitDecIn, 'b');
% hold off;
% title('data Demodulated');
%differentIndices = find(vitDecIn ~= dataEnc);
%disp(all(vitDecIn == dataEnc));
%disp(differentIndices);
vitOut = vitdec((vitDecIn(1:end-sysParam.trBlkPadSize)), ...
    poly2trellis(dataConvK,dataConvCode), ...
    traceBackDepth,'term','unquant',puncVec);
vitOut2 = vitOut(1:end-(dataConvK-1));

% Descrambling
dataScrOut = xor(vitOut2, ...
               pnSeq(sysParam.initState,sysParam.scrMask,numel(vitOut2)));

% Output CRC
[outBits,errFlag] = crcDetect(dataScrOut,crcDet);
end

close all
load matlab.mat
load matlab2.mat
load matlab3.mat
load matlabscr.mat
load matlabenc.mat
load matlabbits.mat
dataEnc = reshape(dataEnc, [], 1);
[outBits, ErrFlag] = provaF(modData, sysParam);
figure;
stem(outBits,'r');
hold on
stem(dataBits, 'b');
hold off;
disp(all(dataBits == outBits));


% bits = double(rand(6192,1)>0.5);
% modData = qammod(bits,sysParam.modOrder,...
%         UnitAveragePower=true,InputType="bit");
% softLLRs = qamdemod(modData,sysParam.modOrder, UnitAveragePower=true, ...
%     OutputType = 'bit');
% figure;
% stem(bits,'r');
% hold on
% stem(softLLRs, 'b');
% hold off;
% disp(all(bits == softLLRs));



% pnSeq = [];
% if isempty(pnSeq)
%     pnSeq = comm.PNSequence(Polynomial='x^-7 + x^-3 + 1',...
%         InitialConditionsSource="Input port",...
%         MaskSource="Input port",...
%         VariableSizeOutput=true,...
%         MaximumOutputSize=[4570 + 32 + ...
%             7 1]);
% end
% 
% crcDet = [];
% if isempty(crcDet)
%     crcDet = crcConfig(...
%         'Polynomial',sysParam.CRCPoly,...
%         'InitialConditions',0,...
%         'FinalXOR',0);
% end
% 
% 
% dataEnc = reshape(dataEnc, [], 1);
% vitOut = vitdec((dataEnc(1:end-sysParam.trBlkPadSize)), ...
%     poly2trellis(sysParam.dataConvK,sysParam.dataConvCode), ...
%     sysParam.tracebackDepth,'term','hard',sysParam.puncVec);
% vitOut2 = vitOut(1:end-(sysParam.dataConvK-1));
% dataScrOut = xor(vitOut2, ...
%                pnSeq(sysParam.initState,sysParam.scrMask,numel(vitOut2)));
% [outBits,errFlag] = crcDetect(dataScrOut,crcDet);

% figure;
% stem(dataBits, 'r')
% hold on
% stem(outBits, 'b');
% hold off
% fprintf('oh: ');
% disp(all(dataBits == outBits));