function complete = Bandpass_Mat_Wrap(fileFull_input, fileFull_output, Flow, Fhigh, order)
%Applys bandpass filter on eeglab EEG struct
%   For filter design, low order filters are used because maintaing integrity
%    of wanted band if far more important than fully rejecting unwanted
%    frequencies
%Input:
%   fileFull_input [string] - full input filepath set file containing the following:
%       EEG [eeglab EEG struct] - EEG struct before bandpass filter
%   fileFull_output [string] - full filename and dir to save filtered EEG to
%        Default - '<fileDir_input>/<fileName_input>_bandpass.set'
%   Flow [float] - lowest wanted frequency for filter
%        Default - 0.5 Hz
%   Fhigh [float] - highest wanted frequency for filter 
%        Default - 70 Hz
%   order [int] - filter order for butterworth filter
%        Default - 2
%Output:
%   complete - returns 1 on successful program run
%       EEG - [eeglab EEG format] bandpassed EEG inside set file

complete = 0; %return 0 on unsucessful run

%find file directory and name of input file for filename calculations
[fileDir_input, fileName_input] = fileparts(fileFull_input);

%set file output to default if empty
if(isempty(fileFull_output))
    %calculate output filename as:
        %'<fileDir_input>/<fileName_input>_bandpass.set'
    fileFull_output = fullfile(fileDir_input, ...
                            [fileName_input, '_bandpass', '.set']);
end
%Set cutoff freqs for filter to default if empty
if(isempty(Flow))
    Flow = 0.5; %in Hz
end
if(isempty(Fhigh))
    Fhigh = 70; %in Hz
end
%Set order to default if empty
if(isempty(order))
    order = 2;
end

%Specify numbers as double
Flow = double(Flow);
Fhigh = double(Fhigh);

%load in EEG struct from input file
fileMat = load('-mat', fileFull_input);
EEG_input = fileMat.EEG;
clear('fileMat');

%get EEG params
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

EEG = EEG_input; % set EEG to original EEG as template for non-data properties
EEG.data = filterData; % tranfer filtered data to new EEG
save(fileFull_output,'EEG');

complete = 1; %return 1 on sucessful run