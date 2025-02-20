function firCoeff = helperOFDMFrontEndFilter(sysParam)
%helperOFDMFrontEndFilter() Genera il filtro del front-end del trasmettitore/ricevitore.
%
%   firCoeff = helperOFDMFrontEndFilter(sysParam)
%   sysParam - struttura dei parametri di sistema
%   firCoeff - coefficienti del filtro FIR per la larghezza di banda specificata
% Copyright 2023 The MathWorks, Inc.

BW = sysParam.BW;                  % Bandwidth (in Hz) of OFDM signal
fs = sysParam.scs*sysParam.FFTLen; % Sample rate of OFDM signal

%% FIR Filtering 
% Equiripple Lowpass filter designed using the |firpm| function.
% All frequency values are in Hz.
Fpass = BW/2;               % Passband frequency
Fstop = fs/2;               % Stopband frequency
Dpass = 0.00033136495965;   % Passband ripple
Dstop = 0.05;               % Stopband ripple
dens  = 20;                 % Density factor

% Calculate the order from the parameters using the |firpmord| function.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the |firpm| function.
firCoeff  = firpm(N, Fo, Ao, W, {dens});

end

