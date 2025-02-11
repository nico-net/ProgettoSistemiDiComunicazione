function [radio, spectrumAnalyze, constDiag] = helperGetRadioRxObj(ofdmRx)
%helperGetRadioTxObj(OFDMTX) restituisce l'oggetto del sistema radio RADIO,
%   basato sul dispositivo radio scelto e sui parametri radio come Gain,
%   CentreFrequency, MasterClockRate e fattore di interpolazione dalla
%   struttura dei parametri radio OFDMTX. La funzione restituisce inoltre
%   gli oggetti systemObject per la rappresentazione della costellazione e
%   per l'analizzatore di spettro, per visualizzare i dati.

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
    'Title',            'Received Signal DISPOSITIVO 2', ...
    'SpectrumType',     'Power', ...
    'FrequencySpan',    'Full', ...
    'SampleRate',       ofdmRx.SampleRate, ...
    'ShowLegend',       true, ...
    'Position',         [100 100 800 500], ...
    'ChannelNames',     {'Received'});

end