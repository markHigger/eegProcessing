function EEG_filtered = EEG_PA_Removal_Matlab(EEG_input)
%Takes in eeg and removes the ECG and BCG  Pulse Artifacts from EEG
%Uses seperate functions from legacy code to remove artifacts
%Inputs:
%   EEG_input [eeglab eeg struct] - input EEG to be filtered (GA should
%       already be removed
%Outputs:
%   EEG_filtered [eeglab eeg struct] - EEG without PAs

%get info from EEG
nChannels = EEG_input.nbchan; % Number of channels
channelEEG = [1:31 33:nChannels];
F_srate = EEG_input.srate; % Sampling rate
includedsamples = 1:length(EEG_input.data);


%Remove ECG Artifact
stCfg.IDX_RAW_QRS_DET = channelEEG;
[EEG_ECGrm] = RemoveMRI_PA(EEG_input,stCfg);

%Remove BCG Artifact
BCG_npc = 2; % Number of principal components
[data_noBCG, BCGartifact] = removeBCG(EEG_ECGrm.data,F_srate,channelEEG,includedsamples,BCG_npc);

EEG_filtered = EEG_ECGrm;
EEG_filtered.data = data_noBCG;
EEG_filtered.artifactBCG = BCGartifact;