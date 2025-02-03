function SNRestimation = helperSNRestimate(spectrumAnalyze)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %
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