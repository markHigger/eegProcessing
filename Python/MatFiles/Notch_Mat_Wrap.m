function complete = Notch_Mat_Wrap(fileFull_input, fileFull_output, Fn, Fw, order)
%Applys Notch filter on eeglab EEG struct to remove radient electrical
%noise
%Input:
%   fileFull_input [string] - full input filepath set file containing the following:
%       EEG [eeglab EEG struct] - EEG struct before notch filter
%   fileFull_output [string] - full filename and dir to save filtered EEG to
%        Default - '<fileDir_input>/<fileName_input>_notch.set'
%   Fn [float] - Desired frequency to remove
%        Default - 60 Hz
%   Fw [float] - width of notch filter cutoffs 
%        Default - 4 Hz
%   order [int] - filter order for butterworth filter
%        Default - 2
%Output:
%   complete - returns 1 on successful program run
%       EEG - [eeglab EEG format] Notch filtered EEG inside set file

%% setup
complete = 0; %return 0 on unsucessful run

%find file directory and name of input file for filename calculations
[fileDir_input, fileName_input] = fileparts(fileFull_input);

%set file output to default if empty
if(isempty(fileFull_output))
    %calculate output filename as:
        %'<fileDir_input>/<fileName_input>_bandpass.set'
    fileFull_output = fullfile(fileDir_input, ...
                            [fileName_input, '_notch', '.set']);
end

%Set notch freq for filter to default if empty
if(isempty(Fn))
    Fn = 60; %in Hz
end
if(isempty(Fw))
    Fw = 4; %in Hz
end
%Set order to default if empty
if(isempty(order))
    order = 2;
end

%load in EEG struct from input file
fileMat = load('-mat', fileFull_input);
EEG_input = fileMat.EEG;
clear('fileMat');

EEG_data = double(EEG_input.data);

nChannels = EEG_input.nbchan;
nSamples = EEG_input.pnts;
filterData = zeros(nChannels,nSamples);
%% filter
% Bandstop frequency range cutoff based on sampling rate and filter width
Fn_lo = Fn - (Fw/2);
Fn_hi = Fn + (Fw/2);

Wnotch = [Fn_lo Fn_hi]*2/EEG_input.srate;

%Design Low order butterworth Filter 
N = order;
[a,b]=butter(N,Wnotch,'stop');

%Filter data

for chanIdx = 1:nChannels
    % Notch filter 60Hz noise with notch filter
    filterData(chanIdx,:) = filtfilt(a,b,EEG_data(chanIdx,:));
end
EEG = EEG_input; % set EEG to original EEG as template for non-data properties
EEG.data = filterData; % tranfer filtered data to new EEG
save(fileFull_output,'EEG','-v7.3');

complete = 1; %return 1 on sucessful run