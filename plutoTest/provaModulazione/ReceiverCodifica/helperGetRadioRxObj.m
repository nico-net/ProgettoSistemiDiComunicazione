function [radio, spectrumAnalyze, constDiag] = helperGetRadioRxObj(ofdmRx)
%helperGetRadioTxObj(OFDMTX) returns the radio system object RADIO, based
%   on the chosen radio device and radio parameters such as Gain,
%   CentreFrequency, MasterClockRate, and Interpolation factor from the
%   radioParameter structure OFDMTX. The function additionally gives the
%   constellation diagram and spectrumAnalyzer system objects as output for
%   data visualizations

% Copyright 2023-2024 The MathWorks, Inc.


radio = sdrrx('Pluto','RadioID','usb:0');
radio.BasebandSampleRate = ofdmRx.SampleRate;
radio.CenterFrequency = ofdmRx.CenterFrequency;
radio.SamplesPerFrame = ofdmRx.txWaveformSize;
radio.OutputDataType = "double";
radio.GainSource = "Manual";
radio.Gain = ofdmRx.Gain;
radio.EnableBurstMode = true;
radio.NumFramesInBurst = ofdmRx.NumFrames+1;

% To visualize the constellation plot of the OFDM demodulated signal, you create
% a comm.ConstellationDiagram System object and set the ReferenceConstellation property
% to the generated reference constellations for header and data
% Set up constellation diagram object
refConstHeader = qammod(0:1,2,UnitAveragePower=true); % header is always BPSK
refConstData   = qammod(0:ofdmRx.modOrder-1,ofdmRx.modOrder,UnitAveragePower=true);
constDiag = comm.ConstellationDiagram(2, ...
    "ChannelNames",{'Header','Data'}, ...
    "ReferenceConstellation",{refConstHeader,refConstData}, ...
    "ShowLegend",true, ...
    "EnableMeasurements",true);

% Additionally, initialize the spectrumAnalyzer System object in-order to
% visualize the received waveform.
spectrumAnalyze = spectrumAnalyzer( ...
    'Name',             'Signal Spectrum', ...
    'Title',            'Received Signal', ...
    'SpectrumType',     'Power', ...
    'FrequencySpan',    'Full', ...
    'SampleRate',       ofdmRx.SampleRate, ...
    'ShowLegend',       true, ...
    'Position',         [100 100 800 500], ...
    'ChannelNames',     {'Received'});

end