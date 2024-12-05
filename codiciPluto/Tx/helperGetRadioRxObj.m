function [radioRx, spectrumAnalyze] = helperGetRadioRxObj(ofdmRx)
%helperGetRadioTxObj(OFDMTX) returns the radio system object RADIO, based
%   on the chosen radio device and radio parameters such as Gain,
%   CentreFrequency, MasterClockRate, and Interpolation factor from the
%   radioParameter structure OFDMTX. The function additionally gives the
%   constellation diagram and spectrumAnalyzer system objects as output for
%   data visualizations

radioRx = sdrrx('Pluto');
radioRx.BasebandSampleRate = ofdmRx.SampleRate;
radioRx.CenterFrequency = ofdmRx.CenterFrequency;
radioRx.SamplesPerFrame = ofdmRx.txWaveformSize;
radioRx.OutputDataType = "double";
radioRx.GainSource = "Manual";
radioRx.Gain = ofdmRx.Gain;
radioRx.EnableBurstMode = true;
radioRx.NumFramesInBurst = ofdmRx.NumFrames+1;

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