function EEG_filtered = EEG_GA_Removal_Matlab(input_EEG)
%Removes EEG Gradient Artifact induced by MRI Scanner using the bcilab  pop_fmrib_fastr
%   This should be the first step in preprocessing, as the GA removal works
%   better before other filtering
%Input: 
%   input_EEG - [eeglab EEG format] EEG without Gradient artifact removed
%Output:
%   EEG_filtered - [eeglab EEG format] EEG with GA removed

%convert EEG data to double (unknown reason from legacy code)
input_EEG.data = double(input_EEG.data);

ANCFlag = 0;
%Uses Gradient Artifact removal from Legacy Code with default func perams
EEG_filtered = pop_fmrib_fastr (input_EEG, [], [], [], 'R128', 1, ANCFlag, [], [], [], [], 32, 'auto');