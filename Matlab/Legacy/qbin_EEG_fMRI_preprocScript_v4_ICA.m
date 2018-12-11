function EEG = qbin_EEG_fMRI_preprocScript_v4_ICA(EEG_fileName,outputDir,setFlag, options)
%Inputs:    EEG_fileName - full filepath of .EEG file to be processed,
%                           Must be in same dir as vhdr & vhmk
%           outputDir - Full path of output directory for mat & sat files
%           setFlag - set to True if intermediate set files should be
%                       genrated
%Output:
%           EEG - eeglab EEG object of final filtered EEG
%           files - Running this function generates .set and .mat files 
%                       after each process  
%
%Takes an EEG from EEG/vhdr/vhmk file, filters it and produces a mat and
%set file after each filter. Filters are as follows: GA removal ->
%Bandpass(0.5:70) -> Notch(60) -> PA removal -> ICA
%
%
%
%
%
%--------------------------------------------------------------------------
% CHANGE/VERSION LOG
% Author: Qawi Telesford & Mark Higger
%
%       Date: 2018-07-24
%    Version: 4.1
% Updates(s): 
%             -Added setFlag in pameter
%             -Added Kurtosis ICA rejection
%             -Added Documentation
%
%       Date: 2018-07-24
%    Version: 4.0
% Updates(s): 
%             -Added ICA
%
%       Date: 2018-01-25
%    Version: 1.0c
% Updates(s):
%             - Changed QRS detection algorithm parameters
%
%       Date: 2018-01-22
%    Version: 1.0b
% Updates(s):
%             - Changed to run gradient artifact removal first
%
% Date: 2017-12-18 (Initial Release)
%   Version: 1.0
%--------------------------------------------------------------------------
%% Error Checking
if(nargin < 1 || isempty(EEG_fileName))
    error('Missing data, please input filename for EEG data.');
end

if(nargin < 2 || isempty(outputDir))
    currentDir = pwd;
    outputDir = currentDir;
    
    disp(['No output directory entered, using current directory: ',currentDir]);
else
    if(~exist(outputDir,'dir'))
        mkdir(outputDir);
    end
end

if(nargin < 4 || isempty(options))
    options = 1; %#ok<NASGU>
end

%% Parameters/Flags

eeg2setFlag = 1;	% Flag to convert BrainVision EEG file to MAT/SET format
bandpassFlag = 1;	% Flag to bandpass filter data
notchFlag = 1;      % Flag to use notch filter for 60Hz noise
gradientFlag = 1;	% Flag to remove gradient artifact from EEG-fMRI data
bcgFlag = 1;        % Flag to remove ballistocardiogram artifact
resampleFlag = 1;	% Flag to resample dat

resampleF = 500;    % Resample frequency in Hz
ICAFlag = 1;        % Flag to apply ICA
rejectFlag = 1; % Flag to automatically reject channels for ICA with kurtosis
if ~exist('setFlag', 'var')
    setFlag = 0; % Convert MAT to SET if flag is set to 1
end


[fileDir,fileName] = fileparts(EEG_fileName);

% Output filename for bandpass-filtered data
fileName_gradient = fullfile(outputDir,[fileName,'_01_gradient_v3','.mat']);
fileName_bandpass = fullfile(outputDir,[fileName,'_02_bandpass_v3','.mat']);
fileName_notch = fullfile(outputDir,[fileName,'_03_notch_v3','.mat']);
fileName_bcg = fullfile(outputDir,[fileName,'_04_bcg_v3','.mat']);
fileName_resample = fullfile(outputDir,[fileName,'_05_resample_v3','.mat']);
fileName_ICA = fullfile(outputDir, [fileName,'_06_ICA_v4','.mat']);

%% 00: EEG to MAT/SET conversion
if(eeg2setFlag == 1)
    % Filenames for MAT and SET file the same as original file
    convert_fileMAT = fullfile(fileDir,[fileName,'.mat']);
    convert_fileSET = fullfile(fileDir,[fileName,'.set']);
    
    % Check if both files exist, if neither or only one exist, functions
    % converts EEG file to MAT/SET
    if(~exist(convert_fileMAT,'file') || ~exist(convert_fileSET,'file'))
        eeg2set(EEG_fileName);
    end
end

%% 01: Gradient artifact removal
if(gradientFlag == 1)
    if(~exist(fileName_gradient,'file'))
        convert_fileMAT = fullfile(fileDir,[fileName,'.mat']);
        
        if(~exist(convert_fileMAT,'file'))
            error('Skipped conversion of original EEG file to MAT, please set eeg2setFlag to 1');
        end
        
        % Load fileMAT
        fileMAT = load(convert_fileMAT);
        input_EEG = fileMAT.EEG;
        input_EEG.data = double(input_EEG.data);
        clear('fileMAT');
        
        EEG = pop_fmrib_fastr (input_EEG, [], 10, 30, 'R128', 0, 0, 0, 0, 0, 0, [], 0);
        
        % Save notch filtered data
        save(fileName_gradient,'EEG','-v7.3');
        
        % Save SET (flag dependent)
        if(setFlag == 1)
            [fileDirMAT,fileNameMAT] = fileparts(fileName_gradient);
            fileSET = fullfile(fileDirMAT,[fileNameMAT,'.set']);
            copyfile(fileName_gradient,fileSET);
        end
    else
        [~,fileName_gradient_disp] = fileparts(fileName_gradient);
        % disp(['Loading: ',fileName_gradient_disp]);
        % load(fileName_gradient);
        disp(['Already completed processing ',fileName_gradient_disp]);
    end
else
    convert_fileMAT = fullfile(fileDir,[fileName,'.mat']);
end

%% 02: Bandpass filter data
% This setion of code bandpass filters the EEG data, function is performed
% on MAT file, and saved as MAT/SET
if(bandpassFlag == 1)
    if(~exist(fileName_bandpass,'file'))
        % Load fileMAT
        if(gradientFlag == 1)
            fileMAT = load(fileName_gradient);
        elseif(gradientFlag == 0)
            fileMAT = load(convert_fileMAT);
        end
        
        EEG = fileMAT.EEG;
        clear('fileMAT');
        
        F_srate = EEG.srate; % Sampling rate
        nChannels = EEG.nbchan; % Number of channels
        nSamples = EEG.pnts; % Number of samples
        
        % Create Butterworth filter
        % Low end of frequency range (Hz)
        F_lo = 0.5;
        
        % High end of frequency range (Hz)
        F_hi = 70;
        
        % Bandpass frequency range cutoff based on sampling rate
        Wn = [F_lo F_hi]*2/F_srate;
        
        % Filter order
        N = 2;
        
        % Butterworth bandpass filter
        [a,b] = butter(N,Wn); %bandpass filtering
        
        filterData = zeros(nChannels,nSamples);
        
        for ii = 1:nChannels
            % Bandpass filter signal with Butterworth filter
            filterData(ii,:) = filtfilt(a,b,double(EEG.data(ii,:)));
        end
        
        % EEG.original = EEG.data;
        EEG.data = filterData;
        
        % Save bandpass filtered data
        save(fileName_bandpass,'EEG','-v7.3');
        
        % Save SET (flag dependent)
        if(setFlag == 1)
            [fileDirMAT,fileNameMAT] = fileparts(fileName_bandpass);
            fileSET = fullfile(fileDirMAT,[fileNameMAT,'.set']);
            copyfile(fileName_bandpass,fileSET);
        end
    else
        [~,fileName_bandpass_disp] = fileparts(fileName_bandpass);
        % disp(['Loading: ',fileName_bandpass_disp]);
        % load(fileName_bandpass);
        disp(['Already completed processing ',fileName_bandpass_disp]);
    end
end

%% 03: Notch filter
% Use notch filter on data to remove 60Hz noise
if(notchFlag == 1)
    if(~exist(fileName_notch,'file'))
        % Load fileMAT
        fileMAT = load(fileName_bandpass);
        EEG = fileMAT.EEG;
        clear('fileMAT');
        
        % Range around: 60 Hz
        Fn_lo = 58;
        Fn_hi = 62;
        
        % Bandpass frequency range cutoff based on sampling rate
        Wnotch = [Fn_lo Fn_hi]*2/F_srate;
        
        % Filter order
        N = 2;
        
        [notchnum60,notchdenom60]=butter(N,Wnotch,'stop');
        
        filterData = zeros(nChannels,nSamples);
        
        for ii = 1:nChannels
            % Notch filter 60Hz noise with notch filter
            filterData(ii,:) = filtfilt(notchnum60,notchdenom60,double(EEG.data(ii,:)));
        end
        
        % EEG.bandpass = EEG.data;
        EEG.data = filterData;
        
        % Save notch filtered data
        save(fileName_notch,'EEG','-v7.3');
        
        % Save SET (flag dependent)
        if(setFlag == 1)
            [fileDirMAT,fileNameMAT] = fileparts(fileName_notch);
            fileSET = fullfile(fileDirMAT,[fileNameMAT,'.set']);
            copyfile(fileName_notch,fileSET);
        end
    else
        [~,fileName_notch_disp] = fileparts(fileName_notch);
        % disp(['Loading: ',fileName_notch_disp]);
        % load(fileName_notch);
        disp(['Already completed processing ',fileName_notch_disp]);
    end
end

%% 04: ECG/BCG artifact removal
if(bcgFlag == 1)
    if(~exist(fileName_bcg,'file'))
        % Load fileMAT
        fileMAT = load(fileName_notch);
        EEG = fileMAT.EEG;
        clear('fileMAT');
        
        nChannels = EEG.nbchan; % Number of channels
        channelEEG = 1:nChannels;
        stCfg.IDX_RAW_QRS_DET = channelEEG;
        [EEG_ECG_PA] = RemoveMRI_PA(EEG,stCfg);
        EEG = EEG_ECG_PA;
        
        %% ECG signal removal (Part 2a)
        % outputfileName5a = fullfile(fileDir,[fileName,'_EEG_5a_removeBCG','.mat']);
        
        % if(~exist(outputfileName5a,'file'))
        % data: EEG data
        % channelEEG: [1-31,33-64]
        % F_srate: sampling rate
        % includedsamples = startTR:finishTR
        F_srate = EEG.srate; % Sampling rate
         
        % nSamples = EEG.pnts; % Number of samples
        
        includedsamples = 1:length(EEG.data);
        % if(gradientFlag == 1)
        %     includedsamples = startTR:finishTR-1;
        % else
        %     includedsamples = 1:length(EEG.data);
        % end
        BCG_npc = 2; % Number of principal components
        
        [data_noBCG, BCGartifact] = removeBCG(EEG.data,F_srate,channelEEG,includedsamples,BCG_npc);
        
        EEG.data = data_noBCG;
        EEG.artifactBCG = BCGartifact;
        
        save(fileName_bcg,'EEG','-v7.3');
        % Save SET (flag dependent)
        if(setFlag == 1)
            [fileDirMAT,fileNameMAT] = fileparts(fileName_bcg);
            fileSET = fullfile(fileDirMAT,[fileNameMAT,'.set']);
            copyfile(fileName_bcg,fileSET);
        end
    else
        [~,fileName_bcg_disp] = fileparts(fileName_bcg);
        % disp(['Loading: ',fileName_gradient_disp]);
        % load(fileName_gradient);
        disp(['Already completed processing ',fileName_bcg_disp]);
    end
end
%% 05: Resample Data
if(resampleFlag == 1)
    if(~exist(fileName_resample,'file'))
        % Load fileMAT
        fileMAT = load(fileName_bcg);
        EEG = fileMAT.EEG;
        clear('fileMAT');
        
        EEG.pnts = length(EEG.times);
        % save(fullfile(fileDir,[fileName,'_preprocessed','.mat']),'EEG','-v7.3');
        % copyfile(fullfile(fileDir,[fileName,'_preprocessed','.mat']),fullfile(fileDir,[fileName,'_a_preprocessed','.set']));
        
        EEG_resample = pop_resample(EEG,resampleF);
        EEG = EEG_resample;
        save(fileName_resample,'EEG','-v7.3');
        %copyfile(fullfile(fileDir,[fileName,'_resample','.mat']),fullfile(fileDir,[fileName,'_resample_v3','.set']));
    end
else
    [~,fileName_resample_disp] = fileparts(fileName_resample);
    % disp(['Loading: ',fileName_gradient_disp]);
    % load(fileName_gradient);
    disp(['Already completed processing ',fileName_resample_disp]);
end

%% 06 Apply ICA
if(ICAFlag == 1)
    if(~exist(fileName_ICA,'file'))
        
        % Load f
        fileMAT = load(fileName_resample);
        input_EEG = fileMAT.EEG;
        input_EEG.data = double(input_EEG.data);
        clear('fileMAT');
        %Reject components for ICA
        if rejectFlag
            %settings for automatic Kurtosis rejections
            rejectEEGData = 1; %setting to reject EEG data
            Chans = 1:64; % electrodes to take into consideration for rejection
            locThresh = 5; % activity kurtosis limit in terms of standard-dev 
            globThresh = 5; % global limit for all chans
            EEG_rejected = pop_rejkurt(input_EEG, rejectEEGData, ... 
                Chans, locThresh, globThresh);
        end
        %run ICA
        EEG = pop_runica(EEG_rejected, 'extended',64,'interupt','on');
        
        % Save ICA data
        save(fileName_ICA,'EEG','-v7.3');
        
        % Save SET (flag dependent)
        if(setFlag == 1)
            [fileDirMAT,fileNameMAT] = fileparts(fileName_ICA);
            fileSET = fullfile(fileDirMAT,[fileNameMAT,'.set']);
            copyfile(fileName_ICA,fileSET);
        end
    else
        [~,fileName_ICA_disp] = fileparts(fileName_ICA);
        % disp(['Loading: ',fileName_ICAdisp]);
        % load(fileName_gradient);
        disp(['Already completed processing ',fileName_ICA_disp]);
    end
end
end


%% Subfunction: Convert EEG to SET/MAT
function eeg2set(inputFile)
    
% Get filename and director of input .eeg file
[fileDir,fileName] = fileparts(inputFile);

% Use pop_loadbv to extract EEG data, function uses header file (vhdr)
[EEG, ~] = pop_loadbv(fileDir,[fileName,'.vhdr']); %#ok<ASGLU>

% Save data to .set file (can be used by EEGLAB GUI)
save(fullfile(fileDir,[fileName,'.set']),'EEG');
save(fullfile(fileDir,[fileName,'.mat']),'EEG');
end