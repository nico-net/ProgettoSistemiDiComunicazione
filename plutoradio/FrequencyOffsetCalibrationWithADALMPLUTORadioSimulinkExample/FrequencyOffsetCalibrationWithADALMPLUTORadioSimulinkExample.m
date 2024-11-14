%% Frequency Offset Calibration with ADALM-PLUTO Radio in Simulink
% These two models show how to determine the relative frequency offset
% between two ADALM-PLUTO radios.
%
% The transmitter sends a 12000 Hz sine wave with the
% <matlab:openExample('plutoradio/FrequencyOffsetCalibrationWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradiofreqcalib')
% Frequency Offset Calibration (Tx) with ADALM-PLUTO Radio> model. The
% receiver receives the signal, calculates the frequency offset and
% displays the offset in the
% <matlab:openExample('plutoradio/FrequencyOffsetCalibrationWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradiofreqcalib_rx')
% Frequency Offset Calibration (Rx) with ADALM-PLUTO Radio> model.
%
% This example deals with offset in the center frequency only. To
% compensate for offsets in both the center frequency and the baseband
% sample rate, see the
% <matlab:openExample('plutoradio/FrequencyCorrectionForADALMPLUTORadioExample')
% Frequency Correction for ADALM-PLUTO Radio> example.

% Copyright 2017-2022 The MathWorks, Inc. 

%% Overview
%
% These two models perform an FFT-based frequency offset calculation at
% complex baseband. The receiver model provides the following information:
%
% * The quantitative value of the frequency offset
% * A graphical view of the spur-free dynamic range of the receiver
% * A graphical view of the qualitative SNR level of the received signal

%% Structure of the Example
% The following figure shows the transmitter model:
modelname1 = 'plutoradiofreqcalib';
open_system(modelname1);
set_param(modelname1, 'SimulationCommand', 'update')
%%
% The following figure shows the receiver model:
modelname2 = 'plutoradiofreqcalib_rx';
close_system(modelname1, 0);
open_system(modelname2);
set_param(modelname2, 'SimulationCommand', 'update')
%%
% The following figure shows the detailed structure of the *Receiver*
% subsystem:
%%
%
open_system([modelname2 '/Receiver']);
%%
% * The *Find Peak Frequency* block - uses an FFT to find the frequency
% with the maximum power in the received signal.
% * The *Spectrum Analyzer* block - computes and displays the power
% spectral density of the received signal.
%% Receiver
%% Find Peak Frequency
% The *Find Peak Frequency* subsystem finds the frequency with the maximum
% power in the received signal, which equals the frequency offset plus 12000
% Hz. The following diagram shows the subsystem. In this subsystem, the
% Periodogram block returns the PSD estimate of the received signal. The
% Probe block finds the frame size and the frame sample time. With this
% information, this subsystem finds the index of the maximum amplitude
% across the frequency band and converts the index to the frequency value
% according to
%
% Foffset = IndexofMaxAmplitude * FrameSize / (FFTLength * FrameSampleTime)
%
% The MATLAB function findpeakfreq.m performs this conversion.

close_system([modelname2 '/Receiver']);
open_system([modelname2 '/Receiver/Find Peak Frequency'],'force');


%% Spectrum Analyzer
% The following figure shows the output of the Spectrum Analyzer on a
% frequency range of -50 kHz to 50 kHz. In the case shown below, the
% frequency with the maximum power of the received signal is about 7 kHz,
% and the spur-free dynamic range of the receiver is about 34 dB.
% 
% <<../plutoradiofreqcalibspectrum.png>>
%
%% Running the Example
% Connect two ADALM-PLUTO Radios to the computer. Run the
% <matlab:openExample('plutoradio/FrequencyOffsetCalibrationWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradiofreqcalib')
% Frequency Offset Calibration (Tx) with ADALM-PLUTO Radio> model, and then
% open the
% <matlab:openExample('plutoradio/FrequencyOffsetCalibrationWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradiofreqcalib_rx')
% Frequency Offset Calibration (Rx) with ADALM-PLUTO Radio> model.
% 
% To run the receiver model, set the _Center frequency_ parameter of the
% *ADALM-PLUTO Radio Receiver* block to the same value as the center
% frequency setting of the
% <matlab:openExample('plutoradio/FrequencyOffsetCalibrationWithADALMPLUTORadioSimulinkExample','supportingFile','plutoradiofreqcalib')
% Frequency Offset Calibration (Tx) with ADALM-PLUTO Radio> model. Then run
% the model. The frequency offset is calculated and displayed while the
% simulation is running.
%
% To compensate for a transmitter/receiver frequency offset, add the
% displayed frequency offset value to the center frequency of the ADALM-PLUTO Radio
% Receiver block. If the displayed frequency offset is negative, then
% subtract it from the center frequency. The spectrum displayed by the
% Spectrum Analyzer block should then have its maximum at 12000 Hz.

close_system([modelname2 '/Receiver/Find Peak Frequency']);
close_system(modelname2, 0);
