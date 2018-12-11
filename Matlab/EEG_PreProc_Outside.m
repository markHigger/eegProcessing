function EEG = EEG_PreProc_Outside(fileinput, fileoutput)

%seperate file name and directory
[fileDir_input, fileName_input] = fileparts(fileinput);

%load in raw EEG from brainvision format (.eeg, .vhdr & .vmrk must be in dir
[EEG_Raw, ~] = pop_loadbv(fileDir_input,[fileName_input,'.vhdr']);

%bandpass at 0.05 to 70 Hz to allow for unhindered 0.2Hz signal in
%entrainment
%*NOTE: bandpass from 0.5 to 70Hz if not working with low frequency entrainment 
EEG_bp = EEG_Bandpass_Matlab(EEG_Raw, 0.05, 70, 2);

%resample to 500 Hz to allow for faster ICA
EEG_resample = pop_resample(EEG_bp, 500);

%Run ICA to allow for manual piscking of eyeblink components
%*NOTE: this does not change the EEG data in any way
EEG_ica = pop_runica(EEG_resample, 'icatype', 'runica', 'chanind', [1:64]);

%use Matlab v7.3 to allow for larger files to be saved
EEG = EEG_ica;
save(fileoutput, 'EEG', '-v7.3')

end