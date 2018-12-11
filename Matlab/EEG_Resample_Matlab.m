function EEG_resampled = EEG_Resample_Matlab(EEG_input, resampleF)
%downsaples the eeg data to resapleF Hz
%Input:
%   EEG_input [eeglab EEG struct] - filtered EEG to resample
%   resampleF [int] - freqency to resample at
%output:
%   EEG_resapmpled [eeglab EEG struct] - 

EEG_input.pnts = length(EEG_input.data);
EEG_resampled = pop_resample(EEG_input,double(resampleF));