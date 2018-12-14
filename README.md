# eegProcessing

To run compiled python

1. Download Matlab runtime compiler v93 from mathworks

2. set LD_LIBRARY_PATH to dir/Matlab_Runtime/v93/runtime/glnxa64:dir/Matlab_Runtime/v93/bin/glnxa64:dir/Matlab_Runtime/v93/sys/os/glnxa64:dir/Matlab_Runtime/v93/sys/opengl/lib/glnxa64
  where dir is the directory to the matlab runtime compiler, for exapmple, if matlab runtime compiler is installed in \~/Documents, run the following
  export LD_LIBRARY_PATH=\~/Documents/Matlab_Runtime/v93/runtime/glnxa64:\~/Documents/Matlab_Runtime/v93/bin/glnxa64:\~/Documents/Matlab_Runtime/v93/sys/os/glnxa64:\~/Documents/Matlab_Runtime/v93/sys/opengl/lib/glnxa64

3. go into /eegProcessing/Python/PreProcPkg_v{X}_{x}/for_redistribution_files_only and run "python setup.py install".
4. go to /eegProcessing/Python and edit the file and directory names in ProcessSerial.py
5. run ProcessSerial.py
