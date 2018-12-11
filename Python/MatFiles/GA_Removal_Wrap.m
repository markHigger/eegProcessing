function complete = GA_Removal_Wrap(fileFull_input, fileFull_output, ECGChan, PCAs)
%Takes in eeglab set file with EEG struct and Removes EEG Gradient Artifact 
%   induced by MRI Scanner using the fmrib eeglab plugin pop_fmrib_fastr 
%   This should be the first step in preprocessing, as the GA removal works
%   better before other filtering, and other filtering tequniques may
%   require clean signals
%Input: 
%   fileFull_output: full path for eeglab struct file that includes the following:
%       EEG - [eeglab EEG struct] EEG without Gradient artifact removed
%   output_path: full path for directory which the following file is saved:
%       fileFull_output - [eeglab set file] set file saved containing EEG struct
%                    
%Output:
%   output_EEG
%   EEG_filtered - [eeglab EEG format] EEG with GA removed

complete = 0; %return 0 on unsucessful run
%Check for valid arguments
if nargin < 1
    error('Not enough arguments, inout file needed')
end
if nargin > 2
    error('Too many input arguments')
end

%find file directory and name of input file for filename calculations
[fileDir_input, fileName_input] = fileparts(fileFull_input);

%set output directory to input directory if not specified bby user
if nargin == 1
    %calculate output filename as:
    %   <fileDir_output>/<fileName_input>_gradient.set
    fileFull_output = fullfile(fileDir_input, ...
                        [fileName_input, '_gradient', '.set']);
end
if ~exist('ECGChan')
    ECGChan = 32;
end
if ~exist('PCAs')
    PCAs = 'auto';
end

%load in EEG 
fileMat = load('-mat', fileFull_input);
EEG_input = fileMat.EEG;
clear('fileMat');

%convert EEG data to double 
EEG_input.data = double(EEG_input.data);

%Uses Gradient Artifact removal from Legacy Code with default func perams
EEG = pop_fmrib_fastr (EEG_input, [], [], [], 'R128', 1, 1, [], [], [], [], 32, 'auto');

save(fileFull_output,'EEG','-v7.3');

complete = 1; %return 1 on sucessful run
