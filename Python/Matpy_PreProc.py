#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 22 14:51:42 2018

@author: markhigger
"""
import PreProc_MatFun_Wraps as Wrap
import os

def preProc(fileFull_input, fileDir_output):
    #get base file names and directories, currntly only works for unix dirs
    fileParts_input = fileFull_input.split('/')
    fileDir_input = '/'.join(fileParts_input[0:-1]) + '/'
    fileName_input = fileParts_input[-1] #input file with extension
    fileName_base = '.'.join(fileName_input.split('.')[0:-1]) #input file w/o extension
    
    #set output directory equal to input directory if not specified
    if fileDir_output == None:
        fileDir_output = fileDir_input
    
    #calculate file names in input directory s
    fileName_raw = fileDir_input + fileName_base + '.eeg'
    fileName_set = fileDir_input + fileName_base + '.set'
    
    #calculate file names in output file directory
    fileName_gradient = fileDir_output + fileName_base + '_gradient.set'
    fileName_bandpass = fileDir_output + fileName_base + '_bandpass.set'
    fileName_notch = fileDir_output + fileName_base + '_notch.set'
    fileName_bcg = fileDir_output + fileName_base + '_bcg.set'
    
    #check if files exist to compute what processing needs to be done
    FileExists_set = os.path.exists(fileName_set) 
    FileExists_gradient = os.path.isfile(fileName_gradient)
    FileExists_bandpass = os.path.isfile(fileName_bandpass)
    FileExists_notch = os.path.isfile(fileName_notch)
    FileExists_bcg = os.path.isfile(fileName_bcg)
    #Check which processing needs to be done, skip Processing if a file exits where
    #   Processing or any Processing after exists
    skip_bcg = FileExists_bcg
    skip_notch = FileExists_notch or skip_bcg
    skip_bandpass = FileExists_bandpass or skip_notch
    skip_gradient = FileExists_gradient or skip_bandpass
    skip_set = FileExists_set or skip_gradient
    
    
    #initialize matlab runtime compiler with preprocessor functions
    Funs = Wrap.init()
    
    #convert brainvision data to 
    if skip_set:
        print('set file already exists, skiping creation of set file')
    else:
        Wrap.BV2Set(Funs, fileName_raw)
    
    #Run EEG through GA removal
    if skip_gradient:
        print('gradient artifact already removed')
    else:
        Wrap.GA_Removal(Funs, fileName_set, fileName_gradient)
    
    #Run EEG through Bandpass filter - uses forward-backward butterworth iir bandpass
    if skip_bandpass:
        print('bandpass filter already appled')
    else:
        Flow = 0.5 #low cuttoff at 0.5 Hz
        Fhigh = 70 #high cutoff at 70 Hz
        N = 2 #use second order filter 
        Wrap.Bandpass_Mat(Funs, fileName_gradient, fileName_bandpass, Flow, Fhigh, N)
    
    #Run EEG through Notch filter - uses forward-backward butterworth iir bandstop
    if skip_notch:
        print('Notch filter already applied')
    else:
        Fn = 60 #Notch filter at 60Hz
        Fw = 4 #Notch width of 4Hz
        N = 2 #use second order bandstop
        Wrap.Notch_Mat(Funs, fileName_bandpass, fileName_notch, Fn, Fw, N)
    
    #Run EEG through PA removal 
    if skip_bcg:
        print('bcg already removed')
    else:
        Wrap.PA_Removal(Funs, fileName_notch, fileName_bcg)
    
    #terminate matlab runtime compiler
    Wrap.term(Funs)

fileDir_input = '/home/mhigger/Desktop/EEG_data/Scan_2018_08_30/'
filePaths_input = []
filePaths_input.append(fileDir_input + 'EEG_fMRI_20180830_01_Checkerboard_Flash_Inside')
filePaths_input.append(fileDir_input + 'EEG_fMRI_20180830_02_ThePresent_Inside')
filePaths_input.append(fileDir_input + 'EEG_fMRI_20180830_03_Checkerboard_Flash_Inside')
filePaths_input.append(fileDir_input + 'EEG_fMRI_20180830_04_Checkerboard_Flash_Inside')
filePaths_input.append(fileDir_input + 'EEG_fMRI_20180830_05_ThePresent_Flash_Inside')
filePaths_input.append(fileDir_input + 'EEG_fMRI_20180830_06_Checkerboard_Flash_Inside')
#fileFull_input = '/home/mhigger/Desktop/EEG_data/EEG_fMRI_20180822_0001_Checkerboard_02.eeg'
fileDir_output = '/home/mhigger/Desktop/EEG_data/Scan_2018_08_30/Processed/'
for filepath in filePaths_input:
    preProc(filepath, fileDir_output)


