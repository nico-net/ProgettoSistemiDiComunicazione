function ofdmRadioParams = helperGetRadioParams(sysParams,sampleRate,centerFrequency,gain)
%helperGetRadioParams(SYSPARAM,RADIODEVICE,SAMPLERATE,CENTERFREQUENCY,GAIN) defines a set of
% required parameters OFDMTX, for the radio system object initialization. The
% parameters are derived based on the user chosen radio device RADIODEVICE,
% sample rate SAMPLERATE and other system parameters SYSPARAM. This
% function searches for the radio device as selected by the user and if one
% such device is connected to the host computer, it fetches the IP address,
% and derives the Master Clock Rate and decimation/interpolation factor
% based on the given sample rate. 


ofdmRadioParams.CenterFrequency = centerFrequency;
ofdmRadioParams.Gain            = gain;
ofdmRadioParams.SampleRate      = sampleRate;                % Sample rate of transmitted signal
ofdmRadioParams.NumFrames       = sysParams.numFrames;       % Number of frames for transmission/reception
ofdmRadioParams.txWaveformSize  = sysParams.txWaveformSize;  % Size of the transmitted waveform
ofdmRadioParams.modOrder        = sysParams.modOrder;
ofdmRadioParams.MasterClockRate = masterClockRate;
ofdmRadioParams.InterpDecim = masterClockRate/sampleRate;


end


