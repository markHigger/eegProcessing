#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 22 13:21:52 2018

@author: mhigger

"""
import PreProcPkg_v5_3 as PreProcPkg

def init():
    Funs = PreProcPkg.initialize()
    
    print('Matlab Runtime compiler initialized \n')
    return Funs
def BV2Set(Funs, fileFull_input):
    """
    Converts Brainvision format to eeglab Set file to be used for other MATLAB
    #   Processing
    #inputs:
    #   Funs - initialized matlab runtime compiler package (run Funs = init() first)
    #   fileFull_input - full path and file of .eeg or .vhdr file
    #Outputs:
    #   output set File - eeglab set file which contains raw eeg struct, has 
    #                       same name as input file with new extension
    #NOTE: requires .eeg, .vhdr and .vmrk to all have the same name in the 
    #       same directory
    
    #MATLAB Funcion description...
    #function complete = BV2Set_Wrap(inputFile)
    # Converts raw Brainvision vhdr header and EEG data files and converts them
    # into eeglab Set files which the filters 
    # *NOTE* saves new Set File in same directory as input direcotry since GA
    #   removal requires the Set file as well as the vmrk file with TR times
    # Input:
    #   inputFile - full file path and name of either .eeg or .vhdr file
    #       NOTE: .eeg, .vhdr and .vmrk must be in the same directory
    # Output:
    #   complete - returns 1 on function completion
    #   outputFile - eeglab set file which contains raw eeg struct
    """
    
    Funs.BV2Set_Wrap(fileFull_input)
    print('BV file saved as Set file')
    
def GA_Removal(Funs, fileFull_input, fileFull_output = None, ECGChan = 32, PCAs = 'auto'):
    """
    Removes fMRI induced gradient artifact from 
    #
    #%Takes in eeglab set file with EEG struct and Removes EEG Gradient Artifact 
    %   induced by MRI Scanner using the fmrib eeglab plugin pop_fmrib_fastr 
    %   This should be the first step in preprocessing, as the GA removal works
    %   better before other filtering, and other filtering tequniques may
    %   require clean signals
    %Input: 
    #   Funs - initialized matlab runtime compiler package (run Funs = init() first)
    %   fileFull_output: full path for eeglab struct file that includes the following:
    %       EEG - [eeglab EEG struct] EEG without Gradient artifact removed
    %   output_path: full path for directory which the following file is saved:
    %       fileFull_output - [eeglab set file] set file saved containing EEG struct
    %                    
    %Output:
    %   output_EEG
    %   EEG_filtered - [eeglab EEG format] EEG with GA removed
    """
    if fileFull_output == None:
        fileFull_output = \
            '.'.join(fileFull_input.split('.')[0:-1]) + '_gradient.set'
        
    Funs.GA_Removal_Wrap(fileFull_input, fileFull_output)
    print('GA Removed')
    
def Bandpass_Mat(Funs, fileFull_input, fileFull_output = None, 
                 Flow = 0.5, Fhigh = 70, order = 2):
    """
    %Applys bandpass filter on eeglab EEG struct
    %   For filter design, low order filters are used because maintaing integrity
    %    of wanted band if far more important than fully rejecting unwanted
    %    frequencies
    %Input:
    %   fileFull_input [string] - full input filepath set file containing the following:
    %       EEG [eeglab EEG struct] - EEG struct before bandpass filter
    %   fileFull_output [string] - full filename and dir to save filtered EEG to
    %        Default - '<fileDir_input>/<fileName_input>_bandpass.set'
    %   Flow [float] - lowest wanted frequency for filter
    %        Default - 0.5 Hz
    %   Fhigh [float] - highest wanted frequency for filter 
    %        Default - 70 Hz
    %   order [int] - filter order for butterworth filter
    %        Default - 2
    %Output:
    %   complete - returns 1 on successful program run
    %       EEG - [eeglab EEG format] bandpassed EEG inside set file
    """
    
    #Set default output filename to <inputfile> - <extension> + '_bandpass.set'
    if fileFull_output == None:
        fileFull_output = \
            '.'.join(fileFull_input.split('.')[0:-1]) + '_bandpass.set'
            
    Funs.Bandpass_Mat_Wrap(fileFull_input, fileFull_output, \
                           float(Flow), float(Fhigh), order)
    
def Notch_Mat(Funs, fileFull_input, fileFull_output = None,
              Fn = 60, Fw = 4, order = 2):
    """
    %Applys Notch filter on eeglab EEG struct to remove radient electrical
    %noise
    %Input:
    %   fileFull_input [string] - full input filepath set file containing the following:
    %       EEG [eeglab EEG struct] - EEG struct before notch filter
    %   fileFull_output [string] - full filename and dir to save filtered EEG to
    %        Default - '<fileDir_input>/<fileName_input>_bandpass.set'
    %   Fn [float] - Desired frequency to remove
    %        Default - 60 Hz
    %   Fw [float] - width of notch filter cutoffs 
    %        Default - 4 Hz
    %   order [int] - filter order for butterworth filter
    %        Default - 2
    %Output:
    %   complete - returns 1 on successful program run
    %       EEG - [eeglab EEG format] bandpassed EEG inside set file
    """
    #Set default output filename to <inputfile> - <extension> + '_notch.set'
    if fileFull_output == None:
        fileFull_output = \
            '.'.join(fileFull_input.split('.')[0:-1]) + '_notch.set'
            
    Funs.Notch_Mat_Wrap(fileFull_input, fileFull_output, \
                        float(Fn), float(Fw), order)
    
def PA_Removal(Funs, fileFull_input, fileFull_output = None):
    """
    %Takes in eeg and removes the ECG and BCG  Pulse Artifacts from EEG
    %Uses seperate functions from legacy code to remove artifacts
    %Input: 
    %   fileFull_input: full path for eeglab struct file that includes the following:
    %       EEG - [eeglab EEG struct] EEG without Gradient artifact removed
    %   fileFull_output: full path for directory which the following file is saved:
    %       fileFull_output - [eeglab set file] set file saved containing EEG struct                    
    %Output:
    %   EEG_filtered - [eeglab EEG format] EEG with GA removed
    """
    
    #Set default output filename to <inputfile> - <extension> + '_bcg.set'
    if fileFull_output == None:
        fileFull_output = \
            '.'.join(fileFull_input.split('.')[0:-1]) + '_bcg.set'
            
    Funs.PA_Removal_Wrap(fileFull_input, fileFull_output)

def Resample_Mat(Funs, fileFull_input, fileFull_output = None, fs = 500):
    if fileFull_output == None:
        fileFull_output = \
            '.'.join(fileFull_input.split('.')[0:-1]) + '_resample'

    Funs.Resample_Mat_Wrap(fileFull_input, fileFull_output, fs)

    
def term(Funs):   
    Funs.terminate()
    print('Matlab runtime compiler terminated')

    
