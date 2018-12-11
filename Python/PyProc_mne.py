#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 23 14:49:49 2018

@author: markhigger
"""
import mne
from mne.preprocessing import compute_proj_ecg, compute_proj_eog, ICA
from mne.preprocessing import create_ecg_epochs, create_eog_epochs, read_ica
import matplotlib as plt
fileName_notch = \
'/Users/markhigger/Documents/NKI/EEG_Data/Processed_Data/EEG_fMRI_20180830_01_Checkerboard_Flash_Inside_03_notch.set'

#load in eeg data before MRI starts (hardcoded for now)
raw = mne.io.read_raw_eeglab(fileName_notch)
raw1 = raw.copy().crop(0, 55)
raw1.set_channel_types({raw1.ch_names[31]: 'ecg'})

#compute ICA
method = 'fastica'

# Choose other parameters
n_components = 10  # if float, select n_components by explained variance of PCA
decim = 3  # we needsufficient statistics, not all time points -> saves time

# we will also set state of the random number generator - ICA is a
# non-deterministic algorithm, but we want to have the same decomposition
# and the same order of components each time this tutorial is run
ica = ICA(n_components=n_components, method=method)
ica.fit(raw1)
#ica.plot_sources(raw1)

#remove ECG
n_max_ecg = 3  # use max 3 components
ecg_epochs = create_ecg_epochs(raw1, tmin=-.3, tmax=.3)
ecg_epochs.decimate(5).apply_baseline((None, None))
ecg_inds, scores_ecg = ica.find_bads_ecg(ecg_epochs, method='ctps')
ica.exclude += ecg_inds[:n_max_ecg]
#ica.plot_scores(scores_ecg, exclude=ecg_inds, title='ECG scores')
#find find ECG events and plot average
average_ecg = mne.preprocessing.create_ecg_epochs(raw1).average()
print('We found %i ECG events' % average_ecg.nave)
joint_kwargs = dict(ts_args=dict(time_unit='s'),
                    topomap_args=dict(time_unit='s'))
#average_ecg.plot_joint(**joint_kwargs)


#compute ECG for SSP
#projs, events = compute_proj_ecg(raw1, n_grad=0, n_mag=0, n_eeg=2, average=True)
#print(projs)
#ecg_projs = projs[-2:]
#mne.viz.plot_projs_topomap(ecg_projs)


data_bcg, times = raw1[:]  
plt.pyplot.figure()
plt.pyplot.plot(data_bcg[3, :], linewidth=0.5)

raw1_copy = raw1.copy()
ica.apply(raw1_copy)
data_ica, times = raw1_copy[:]  
#plt.pyplot.figure()
plt.pyplot.plot(data_ica[3, :], linewidth=0.5)
#tmin = 76, tmax = 220

fileName_bcg = \
'/Users/markhigger/Documents/NKI/EEG_Data/Processed_Data/EEG_fMRI_20180830_01_Checkerboard_Flash_Inside_04_bcg.set'
raw = mne.io.read_raw_eeglab(fileName_bcg, event_id = {'qrs': 1, 'Sync On': 2})
raw_mat = raw.copy().crop(0, 55)
mne.io.read_events_eeglab(fileName_bcg)
data_mat, times = raw_mat[:]  
#plt.pyplot.figure()
plt.pyplot.plot(data_mat[3, :], linewidth=0.5)