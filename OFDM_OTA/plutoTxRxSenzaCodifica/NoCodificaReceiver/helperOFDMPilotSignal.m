function pilot = helperOFDMPilotSignal(pilotsPerSym)
%helperOFDMPilotSignal  Generates pilot signal
%helperOFDMPilotSignal Genera il segnale pilota
%   Questa funzione genera il segnale pilota (pilot). Questo segnale pilota è
%   conosciuto sia dal trasmettitore che dal ricevitore. La sequenza utilizza
%   una sequenza binaria pseudo-casuale modulata BPSK. La sequenza può essere
%   definita dall'utente.
%
%   pilot = helperOFDMPilotSignal(pilotsPerSym)
%   pilotsPerSym - numero di piloti per simbolo
%   pilot - sequenza pilota nel dominio delle frequenze

% Copyright 2023 The MathWorks, Inc.

s = RandStream("dsfmt19937","Seed",15);
pilot = (randi(s,[0 1],pilotsPerSym,1)-0.5)*2;

% Output check
if length(pilot) ~= pilotsPerSym
    error('Incorrect number of pilot symbols generated.');
end

end
