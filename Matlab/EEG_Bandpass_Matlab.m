function EEG_filtered = EEG_Bandpass_Matlab(EEG_input, Flow, Fhigh, order)
%Applys bandpass filter on eeglab EEG struct
%   For filter design, low order filters are used because maintaing integrity
%    of wanted band if far more important than fully rejecting unwanted
%    frequencies
%Input:
%   EEG_input [eeglab EEG struct] - EEG_data before bandpass filter
%   Flow [float] - lowest wanted frequency for filter
%   Fhigh [float] - highest wanted frequency for filter 

F_srate = EEG_input.srate; % Sampling rate
nChannels = EEG_input.nbchan; % Number of channels
nSamples = EEG_input.pnts; % Number of samples
EEG_Data = double(EEG_input.data);

% Bandpass frequency range cutoff based on sampling rate
Wn = [Flow Fhigh]*2/F_srate;

% Filter order
N = order;

% Create low order Butterworth filter
[a,b] = butter(N,Wn); %bandpass filtering

filterData = zeros(nChannels,nSamples);
        
for chanIdx = 1:nChannels
    % Bandpass filter signal with Butterworth filter
    filterData(chanIdx,:) = filtfilt(a,b,EEG_Data(chanIdx,:));
end
%%

EEG_filtered = EEG_input;
EEG_filtered.data = filterData;