function EEG_filtered = EEG_Notch_Matlab(EEG_input, Fn, Wn, order)
%Applys Notch filter on eeglab EEG struct to remove radient electrical
%noise
%Input:
%   EEG_input [eeglab EEG struct] - EEG_data before bandpass filter
%   Fn [float] - unwanted frequency of notch filter

EEG_data = double(EEG_input.data);
% Bandpass frequency range cutoff based on sampling rate
if ~exist('Wn', 'var')
    Wn = 4;
end
Fn_lo = Fn - Wn/2;
Fn_hi = Fn + Wn/2;
Wnotch = [Fn_lo Fn_hi]*2/EEG_input.srate;

%Design Low order butterworth Filter 
if ~exist('order', 'var')
    order = 2;
end
N = order;
[a,b]=butter(N,Wnotch,'stop');

%Filter data
nChannels = EEG_input.nbchan;
nSamples = EEG_input.pnts;
filterData = zeros(nChannels,nSamples);
for chanIdx = 1:nChannels
    % Notch filter 60Hz noise with notch filter
    filterData(chanIdx,:) = filtfilt(a,b,EEG_data(chanIdx,:));
end
EEG_filtered = EEG_input;
EEG_filtered.data = filterData;