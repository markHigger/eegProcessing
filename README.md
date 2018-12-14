# eegProcessing

To run compiled MATLAB in Python:

1. Download Matlab runtime compiler v93 from mathworks

2. set LD_LIBRARY_PATH to dir/Matlab_Runtime/v93/runtime/glnxa64:dir/Matlab_Runtime/v93/bin/glnxa64:dir/Matlab_Runtime/v93/sys/os/glnxa64:dir/Matlab_Runtime/v93/sys/opengl/lib/glnxa64

	where dir is the directory to the matlab runtime compiler, for exapmple, if matlab runtime compiler is installed in \~/Documents, run the following - 
		
		export LD_LIBRARY_PATH=~/Documents/Matlab_Runtime/v93/runtime/glnxa64:~/Documents/Matlab_Runtime/v93/bin/glnxa64:~/Documents/Matlab_Runtime/v93/sys/os/glnxa64:~/Documents/Matlab_Runtime/v93/sys/opengl/lib/glnxa64

3. go into /eegProcessing/Python/PreProcPkg_v{X}_{x}/for_redistribution_files_only and run "python setup.py install".
4. go to /eegProcessing/Python and edit the file and directory names in ProcessSerial.py
5. run ProcessSerial.py


To Run Matlab:
1. Download eeglab toolbox from https://github.com/eeglabdevelopers/eeglab
2. Run eeglab command in Matlab
3. Go to "manage eeglab extension" in eeglab window and add bva-io (under data import) and fMRIb (under data processing) 
4. Add all files from /eegProcessing/Matlab/ to you Matlab path
5. For full processing simply Run -

		EEG_Preprocess_Pipeline_mat([inputFilepath, 'filepath_output', [outputFilepath])
	*More save options are available in file documentation	
	
	*Please note that this method requires use of a wrapper script for FMRIB from ... that cannot be put on GITHUB, feel free to contact me at markbhigger@gmail.com for more information
6. For individual Procoessing steps see individual file documentation
