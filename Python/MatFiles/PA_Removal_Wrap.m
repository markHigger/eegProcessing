function complete = PA_Removal_Wrap(fileFull_input, fileFull_output)
%Takes in eeg and removes the ECG and BCG  Pulse Artifacts from EEG
%Uses seperate functions from legacy code to remove artifacts
%Input: 
%   fileFull_input: full path for eeglab struct file that includes the following:
%       EEG - [eeglab EEG struct] EEG without Gradient artifact removed
%   fileFull_output: full path for directory which the following file is saved:
%       fileFull_output - [eeglab set file] set file saved containing EEG struct                    
%Output:
%   EEG_filtered - [eeglab EEG format] EEG with GA removed

complete = 0; %return 0 on unsucessful run

%find file directory and name of input file for filename calculations
[fileDir_input, fileName_input] = fileparts(fileFull_input);

%set output directory to input directory if not specified bby user
if isempty(fileFull_output)
    %calculate output filename as:
    %   <fileDir_output>/<fileName_input>_gradient.set
    fileFull_output = fullfile(fileDir_input, ...
                        [fileName_input, '_bcg', '.set']);
end

%load in EEG 
fileMat = load('-mat', fileFull_input);
EEG_input = fileMat.EEG;
clear('fileMat');

%get info from EEG
nChannels = EEG_input.nbchan; % Number of channels
channelEEG = double(1:nChannels);
F_srate = double(EEG_input.srate); % Sampling rate
includedsamples = double(1:length(EEG_input.data));


%Remove ECG Artifact
stCfg.IDX_RAW_QRS_DET = channelEEG;
[EEG_ECGrm] = RemoveMRI_PA(EEG_input,stCfg);

%Remove BCG Artifact
BCG_npc = double(2); % Number of principal components
[data_noBCG, BCGartifact] = removeBCG(double(EEG_ECGrm.data),F_srate,channelEEG,includedsamples,BCG_npc);

EEG = EEG_ECGrm;
EEG.data = data_noBCG;
EEG.artifactBCG = BCGartifact;

save(fileFull_output,'EEG','-v7.3');

complete = 1; 