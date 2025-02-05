function ofdmRadioParams = helperGetRadioParams(sysParams,sampleRate,centerFrequency,gain)
%helperGetRadioParams(SYSPARAM, RADIODEVICE, SAMPLERATE, CENTERFREQUENCY, GAIN) definisce un set di
%   parametri richiesti per l'inizializzazione dell'oggetto radio OFDMTX. I
%   parametri vengono derivati in base al dispositivo radio scelto RADIODEVICE,
%   alla frequenza di campionamento SAMPLERATE e ad altri parametri di sistema SYSPARAM.
%   Questa funzione cerca il dispositivo radio selezionato dall'utente e, se un dispositivo
%   di questo tipo è connesso al computer host, recupera l'indirizzo IP, derivando
%   la Master Clock Rate e il fattore di decimazione/interpolazione basato sulla frequenza
%   di campionamento fornita.


% Copyright 2023-2024 The MathWorks, Inc.
ofdmRadioParams.CenterFrequency = centerFrequency;
ofdmRadioParams.Gain            = gain;
ofdmRadioParams.SampleRate      = sampleRate;                % Sample rate of transmitted signal
ofdmRadioParams.NumFrames       = sysParams.numFrames;       % Number of frames for transmission/reception
ofdmRadioParams.txWaveformSize  = sysParams.txWaveformSize;  % Size of the transmitted waveform
ofdmRadioParams.modOrder        = sysParams.modOrder;

end

