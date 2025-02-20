function ofdmRadioParams = helperGetRadioParams(sysParams,sampleRate,centerFrequency,gain)
%helperGetRadioParams(SYSPARAM,RADIODEVICE,SAMPLERATE,CENTERFREQUENCY,GAIN) 
%   Definisce un insieme di parametri richiesti per OFDMTX, necessari per 
%   l'inizializzazione dell'oggetto di sistema radio. I parametri vengono 
%   derivati in base al dispositivo radio scelto dall'utente RADIODEVICE, 
%   alla frequenza di campionamento SAMPLERATE e ad altri parametri di sistema SYSPARAM. 
%   Questa funzione cerca il dispositivo radio selezionato dall'utente e, se 
%   è connesso al computer host, recupera l'indirizzo IP e calcola la Master Clock Rate 
%   e il fattore di decimazione/interpolazione basandosi sulla frequenza di campionamento.

% Copyright 2023-2024 The MathWorks, Inc.
ofdmRadioParams.CenterFrequency = centerFrequency;
ofdmRadioParams.Gain            = gain;
ofdmRadioParams.SampleRate      = sampleRate;                % Sample rate of transmitted signal
ofdmRadioParams.NumFrames       = sysParams.numFrames;       % Number of frames for transmission/reception
ofdmRadioParams.txWaveformSize  = sysParams.txWaveformSize;  % Size of the transmitted waveform
ofdmRadioParams.modOrder        = sysParams.modOrder;
end

