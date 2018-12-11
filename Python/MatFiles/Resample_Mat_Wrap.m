function complete = Resample_Mat_Wrap(fileFull_input, fileFull_output, fs)
%Applys Notch filter on eeglab EEG struct to remove radient electrical
%noise
%Input:
%   fileFull_input [string] - full input filepath set file containing the following:
%       EEG [eeglab EEG struct] - EEG struct before resampleing 
%   fileFull_output [string] - full filename and dir to save filtered EEG to
%        Default - '<fileDir_input>/<fileName_input>_resample.set'
%   fs [float] - Desired resample rate
%        Default - 500 Hz
%Output:
%   complete - returns 1 on successful program run
%       EEG - [eeglab EEG format] resampled EEG inside set file

%% setup
complete = 0; %return 0 on unsucessful run

%find file directory and name of input file for filename calculations
[fileDir_input, fileName_input] = fileparts(fileFull_input);

%set file output to default if empty
if(isempty(fileFull_output))
    %calculate output filename as:
        %'<fileDir_input>/<fileName_input>_bandpass.set'
    fileFull_output = fullfile(fileDir_input, ...
                            [fileName_input, '_resample', '.set']);
end
if(isempty(fs))
    fs = 500; %in Hz
end

fileMat = load('-mat', fileFull_input);
EEG_input = fileMat.EEG;
clear('fileMat');

EEG_input.pnts = length(EEG_input.data);

%Matlab runtime compiler defaults to int64
fs = double(fs);

EEG_resampled = pop_resample_comp(EEG_input,fs);

EEG = EEG_resampled; % tranfer filtered data to new EEG
save(fileFull_output,'EEG','-v7.3');
complete = 1; %return 1 on sucessful run
