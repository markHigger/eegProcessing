from Matpy_PreProc import preProc

#fileDir_input = '/home/mhigger/Desktop/EEG_Data/20181115/Raw/'

filePaths_input = []
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181115_0001_ET12_75_75_02_02_passive.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181115_0002_ET12_75_75_05_05_passive.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181115_0003_ET12_75_75_10_10_passive.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181115_0004_ET12_75_75_05_02_passive.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181115_0006_ET12_Rest.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181115_0005_ET12_75_75_02_05_passive.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181115_0007_Checkerboard.eeg')

#files for 20181128 
fileDir_input = '/home/mhigger/Desktop/EEG_Data/20181128/Raw/'
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_001_Checkerboard_Outside.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_002_Checkerboard_Scanner_ON.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_003_Rest.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_004_ThePresent.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_005_Inscapes.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_006_Monkey1.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_007_DespicableMe.eeg')
filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_008_Monkey1_02.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_009_Inscapes_02.eeg')
#filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_010_ThePresent_02.eeg')
filePaths_input.append(fileDir_input + 'EEG_fMRI_20181128_011_DespicableMe_02.eeg')

#filePaths_input.append(fileDir_input +s 'EEG_fMRI_20180830_06_Checkerboard_Flash_Inside.eeg')
#fileFull_input = '/home/mhigger/Desktop/EEG_data/EEG_fMRI_20180822_0001_Checkerboard_02.eeg'
fileDir_output = '/home/mhigger/Desktop/EEG_Data/20181128/Processed/'
#fileDir_output = '/home/mhigger/Desktop/EEG_Data/20181115/Processed/'
for filepath in filePaths_input:
	print(filepath)
	preProc(filepath, fileDir_output)
