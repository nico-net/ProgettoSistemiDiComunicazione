function SNRestimation = helperSNRestimate(spectrumAnalyze)
%SNRESTIMATION  La funzione fa una stima del SNR utilizzando l'oggetto
%spectrumAnalyze. Il SNR è calcolato dividendo la media dei valori
%associati alla banda (-100kHz, 100kHz) per un valore preso a f=129kHz che
%rappresenta approsimativamente l'inizio delle bande laterali (costituite
% principalmente da rumore).

    res = getSpectrumData(spectrumAnalyze);
    freq = cell2mat(res.FrequencyVector);
    spectrum = cell2mat(res.Spectrum);
    fmin = -100e3;
    idx = (freq >= fmin) & (freq <= fmin*(-1));
    meanPowerdB = mean(spectrum(idx));
    idx = find(freq == 129000);
    SNRestimation = meanPowerdB - (spectrum(idx));
    fprintf('SNR estimated: %d\n', SNRestimation);
end