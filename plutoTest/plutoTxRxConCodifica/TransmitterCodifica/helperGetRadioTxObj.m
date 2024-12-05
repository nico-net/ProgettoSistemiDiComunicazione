function [radio, spectrumAnalyze] = helperGetRadioTxObj(ofdmTx)
%helperGetRadioTxObj(OFDMTX) returns the radio system object RADIO, based
%   on the chosen radio device and radio parameters such as Gain,
%   CenterFrequency, MasterClockRate, and Interpolation factor from the
%   radioParameter structure OFDMTX. The function also returns the spectrumAnalyzer
%   systemobject SPECTRUMANALYZE inorder to view the transmitted waveform

% Copyright 2023-2024 The MathWorks, Inc.

radio = sdrtx('Pluto');
radio.BasebandSampleRate = ofdmTx.SampleRate;
radio.CenterFrequency = ofdmTx.CenterFrequency;
radio.Gain  = ofdmTx.Gain;

% Initialize the spectrumAnalyzer System object to visualize the spectrum
% of the received OFDM signal
% Set the SampleRate as the OFDM sample rate and adjust the scope position
spectrumAnalyze = spectrumAnalyzer( ...
    'Name',             'Signal Spectrum', ...
    'Title',            'Transmitted Signal', ...
    'SpectrumType',     'Power', ...
    'FrequencySpan',    'Full', ...
    'SampleRate',       ofdmTx.SampleRate, ...
    'ShowLegend',       true, ...
    'Position',         [100 100 800 500], ...
    'ChannelNames',     {'Transmitted'});
end