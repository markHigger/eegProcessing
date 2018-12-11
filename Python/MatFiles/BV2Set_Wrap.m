function complete = BV2Set_Wrap(inputFile)
% Converts raw Brainvision vhdr header and EEG data files and converts them
% into eeglab Set files which the filters 
% *NOTE* saves new Set File in same directory as input direcotry since GA
%   removal requires the Set file as well as the vmrk file with TR times
% Input:
%   inputFile - full file path and name of either .eeg or .vhdr file
%       NOTE: .eeg, .vhdr and .vmrk must be in the same directory
% Output:
%   complete - returns 1 on function completion
%   outputFile - eeglab set file which contains raw eeg struct

complete = 0; %function returns 0 on function failure

% Get filename and director of input .eeg file
[fileDir,fileName] = fileparts(inputFile);

% Uses eeglab method to convert bv data to eeglab 
%function uses header file (vhdr) and eeg file
[EEG, ~] = pop_loadbv(fileDir,[fileName,'.vhdr']); 

% Save data to .set file (can be used by EEGLAB GUI)
save(fullfile(fileDir,[fileName,'.set']),'EEG', '-v7.3');

complete = 1; %function returns 1 on function success
end