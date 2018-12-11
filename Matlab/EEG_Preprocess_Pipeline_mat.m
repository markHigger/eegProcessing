function success = EEG_Preprocess_Pipeline_mat(filepath_input, varargin)
%This is the matlab preprocesssing script for automating EEG preprocessign
%It takes in a BrainVision EEG format and creates a set of eeglab formatted
%files of filtered eegs, by default creates only the final Mat file
%
%Function can be called with :
%EEG_Preprocess_pipeline_mat(filepath_input,'peram1', val, 'peram2', val)
%   perameters do not have to be in order
%Inputs:
%   filepath_input - This is the full filename of the input vhdr file
%   filepath_output - This is the full path of the output Directory:
%       by default, this is the input directory
%   Flags:
%       saveAll_Mat/Set - saves EEG after each stage in .mat or .set format
%       saveGA_Mat/Set - saves EEG after Gradient artifact is removed
%       saveBP_Mat/Set - saves EEG after bandpass filter
%       saveNotch_Mat/Set - saves EEG after notch filter
%       savePA_Mat/Set - saves EEG after Pulse artifact is removed
%Outputs:
%   saves eeg structs in eeglab format with either mat or set, where .mat
%       files can be in Matlab, and .set files can be used in eeglab
%
%Version:
%   Current - 1.0:
%       functional Build
%   Future Additions
%       Filter design through functions
%       ability to re-order filtering stages
%       possible class based implementaion

%% Parse function input
%Set input parser names and default values
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('filepath_input')
[fileDir, fileName] = fileparts(filepath_input);
p.addParameter('filepath_output', fileDir)
p.addParameter('saveAll_Mat', 0);
p.addParameter('saveAll_Set', 0);
p.addParameter('saveGA_Mat', 0);
p.addParameter('saveGA_Set', 0);
p.addParameter('saveBP_Mat', 0);
p.addParameter('saveBP_Set', 0);
p.addParameter('saveNotch_Mat', 0);
p.addParameter('saveNotch_Set', 0);
p.addParameter('savePA_Mat', 0);
p.addParameter('savePA_Set', 0);
p.addParameter('saveResamp_Mat', 0);
p.addParameter('saveResamp_Set', 1);


p.parse(filepath_input, varargin{:});

filepath_input = p.Results.filepath_input;
filepath_output = p.Results.filepath_output;

%Set flags if user input has them set or if saveALL is enabled
saveAll_Mat = p.Results.saveAll_Mat;
saveAll_Set = p.Results.saveAll_Set;
saveGA_Mat = p.Results.saveGA_Mat || saveAll_Mat;
saveGA_Set = p.Results.saveGA_Set || saveAll_Set;
saveBP_Mat = p.Results.saveBP_Mat || saveAll_Mat;
saveBP_Set = p.Results.saveBP_Set || saveAll_Set;
saveNotch_Mat = p.Results.saveNotch_Mat || saveAll_Mat;
saveNotch_Set = p.Results.saveNotch_Set || saveAll_Set;
savePA_Mat = p.Results.savePA_Mat || saveAll_Mat;
savePA_Set = p.Results.savePA_Set || saveAll_Set;
saveResamp_Mat = p.Results.saveResamp_Mat || saveAll_Mat;
saveResamp_Set = p.Results.saveResamp_Set || saveAll_Set;

success = 0;
%% Determain control flow of pipelines

%TODO: Deteramine and set filenames 
%filenames are [outputDir][inputfile(-extension)][Last Process][extension]
%   eg: usr/documents/EEG_data/despicableme-02_Bandpass.set
fileName_gradient = fullfile(filepath_output,[fileName,'_01_gradient']);
fileName_bandpass = fullfile(filepath_output,[fileName,'_02_bandpass']);
fileName_notch = fullfile(filepath_output,[fileName,'_03_notch']);
fileName_bcg = fullfile(filepath_output,[fileName,'_04_bcg']);
fileName_resample = fullfile(filepath_output,[fileName,'_05_resample']);

%Check if filenames exist in output path
GAExist = (exist([fileName_gradient, '.mat'],'file') || exist([fileName_gradient, '.set'],'file'));
BPExist = (exist([fileName_bandpass, '.mat'],'file') || exist([fileName_bandpass, '.set'],'file'));
NotchExist = (exist([fileName_notch, '.mat'],'file') || exist([fileName_notch, '.set'],'file'));
PAExist = (exist([fileName_bcg '.mat'],'file') || exist([fileName_bcg '.set'],'file'));
resampExist = (exist([fileName_resample, '.mat'],'file')|| exist([fileName_resample '.set'],'file'));

%Set Control flags - a step should not be performed if the proceding
%   files exist of previos process completion 
resample = ~resampExist;
removePA = ~PAExist && resample;
removeNotch = ~NotchExist && removePA;
removeBP = ~BPExist && removeNotch;
removeGA = ~GAExist && removeBP;

%% Remove GA from EEG
if removeGA
    fprintf('removing fMRI gradient artifact \n')
    %load in raw eeg to eeglab struct
    [fileDir_input, fileName_input] = fileparts(filepath_input);
    [EEG_Raw, ~] = pop_loadbv(fileDir_input,[fileName_input,'.vhdr']);
    
    %perform gradient removal
    EEG_GA = EEG_GA_Removal_Matlab(EEG_Raw);
    
    %save output
    if (saveGA_Mat)
        fprintf('saving GA removed EEG as mat file \n');
        EEG = EEG_GA;
        save([fileName_gradient,'.mat'],'EEG');
        clear EEG
    end
    if (saveGA_Set)
        fprintf('saving GA removed EEG as Set file \n');
        EEG = EEG_GA;
        save([fileName_gradient,'.set'],'EEG');
        clear EEG
    end
else
    fprintf('File exists with GA removed \n')
end


%% remove Bandpass from EEG
if (removeNotch)
    %if previos filtering was skipped load EEG_BA from file 
    %   else use EEG_GA from Gradient removal step
    if ~removeGA
        if exist([fileName_gradient,'.mat'], 'file')
            fileMat = load([fileName_gradient,'.mat']);
            EEG_GA = fileMat.EEG;
            clear('fileMat');

        elseif exist([fileName_gradient,'.set'], 'file')
            EEG_GA = pop_loadset([fileName_gradient,'.set']);
        end
    end
    
    fprintf('applying bandpass filter\n')

    %perform bandpassfilter
    %set low and high end of wanted frequencies
    %OPTIONAL TODO: specify freqs & filt info from function call
    F_low = 0.5;
    F_high = 70;
    N = 3;
    EEG_BP = EEG_Bandpass_Matlab(EEG_GA, F_low, F_high, N);
    %save output
    if (saveBP_Mat)
        fprintf('saving Bandpassfilterd eeg as mat file \n');
        EEG = EEG_BP;
        save([fileName_bandpass,'.mat'],'EEG');
        clear EEG
    end
    if (saveBP_Set)
        fprintf('saving Bandpassfilterd eeg as set file \n');
        EEG = EEG_BP;
        save([fileName_bandpass,'.set'],'EEG');
        clear EEG
    end
else
    fprintf('File with bandpass filter already exists \n');
end
%% filter out Notch at 60 hz
if (removeNotch)
    %if previos filtering was skipped load EEG_BP from file 
    %   else use EEG_BP from BP step
    if ~removeBP
        if exist([fileName_bandpass,'.mat'], 'file')
            fileMat = load([fileName_bandpass,'.mat']);
            EEG_BP = fileMat.EEG;
            clear('fileMat');
        
        elseif exist([fileName_bandpass,'.set'], 'file')
            EEG_BP = pop_loadset([fileName_bandpass,'.set']);
        end
        
    end
    fprintf('applying Notch filter\n')

    %perform Notch
    %set notch cutoff
    %OPTIONAL TODO: specify freqs & filt info from function call
    F_Notch = 60;
    EEG_Notch = EEG_Notch_Matlab(EEG_BP, F_Notch);
    % save output
    if (saveNotch_Mat)
        fprintf('saving Notch filterd eeg as mat file \n');
        EEG = EEG_Notch;
        save([fileName_notch,'.mat'],'EEG');
        clear EEG
    end
    if (saveNotch_Set)
        fprintf('saving Notch filterd eeg as set file \n');
        EEG = EEG_Notch;
        save([fileName_notch,'.set'],'EEG');
        clear EEG
    end
else
    fprintf('File with Notch filter already exists \n');
end
%% Remove EEG and BCG
if (removePA)
    %if previos filtering was skipped load EEG_Notch from file 
    %   else use EEG_Notch from Notch removal step

    if ~removeNotch
        if exist([fileName_notch,'.mat'], 'file')
            fileMat = load([fileName_notch,'.mat']);
            EEG_Notch = fileMat.EEG;
            clear('fileMat');

        elseif exist([fileName_notch,'.set'], 'file')
            EEG_Notch = pop_loadset([fileName_notch,'.set']);
        end
    end
    fprintf('applying PA removal \n')

    %remove PAs
    EEG_PA = EEG_PA_Removal_Matlab(EEG_Notch);

    if (savePA_Mat)
        fprintf('saving PA removed eeg as mat file \n');
        EEG = EEG_PA;
        save([fileName_bcg,'.mat'],'EEG');
        clear EEG
    end
    if (savePA_Set)
        fprintf('saving PA removed eeg as set file \n');
        EEG = EEG_PA;
        save([fileName_bcg,'.set'],'EEG');
        clear EEG
    end
else
    fprintf('File with PA removal already exists');
end

%% Resample Data
if (resample)
    %if previos filtering was skipped load EEG_Notch from file 
    %   else use EEG_Notch from Notch removal step
    if ~removePA
        fileMat = load([fileName_bcg,'.mat']);
        EEG_PA = fileMat.EEG;
        clear('fileMat');
    elseif exist([fileName_bcg,'.set'], 'file')
        EEG_PA = pop_loadset([fileName_bcg,'.set']);
   end
    fprintf('resampling data \n')
    resampleFreq = 500;
    
    %resample data
    EEG_Resample = EEG_Resample_Matlab(EEG_PA, resampleFreq);

    if (saveResamp_Mat)
        fprintf('saving resampled eeg as mat file \n');
        EEG = EEG_Resample;
        save([fileName_resample,'.mat'],'EEG');
        clear EEG
    end
    if (saveResamp_Set)
        fprintf('saving resampled eeg as set file \n');
        EEG = EEG_Resample;
        save([fileName_resample,'.set'],'EEG');
        clear EEG
    end
else
    fprintf('resampled File already exists');
end

%SET OUTPUT
success = 1;
