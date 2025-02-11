function [radio, spectrumAnalyze] = helperGetRadioTxObj(ofdmTx)
%helperGetRadioTxObj(OFDMTX) Restituisce l'oggetto di sistema radio RADIO, 
%   basandosi sul dispositivo radio scelto e sui parametri radio come Gain, 
%   CenterFrequency, MasterClockRate e Interpolation Factor dal parametro di sistema 
%   OFDMTX. La funzione restituisce anche l'oggetto di sistema spectrumAnalyzer 
%   SPECTRUMANALYZER per visualizzare lo spettro dell'onda trasmessa.

% Copyright 2023-2024 The MathWorks, Inc.

radio = sdrtx('Pluto', 'RadioID','usb:0');
radio.BasebandSampleRate = ofdmTx.SampleRate;
radio.CenterFrequency = ofdmTx.CenterFrequency;
radio.Gain  = ofdmTx.Gain;

% Initialize the spectrumAnalyzer System object to visualize the spectrum
% of the received OFDM signal
% Set the SampleRate as the OFDM sample rate and adjust the scope position
spectrumAnalyze = spectrumAnalyzer( ...
    'Name',             'Signal Spectrum', ...
    'Title',            'Transmitted Signal DISPOSITIVO 2', ...
    'SpectrumType',     'Power', ...
    'FrequencySpan',    'Full', ...
    'SampleRate',       ofdmTx.SampleRate, ...
    'ShowLegend',       true, ...
    'Position',         [100 100 800 500], ...
    'ChannelNames',     {'Transmitted'});
end