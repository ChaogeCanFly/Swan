set path "/home/alex/git-repos/FEM-MAT-OO/FEM/PostProcess/ImageCapturer/"
set tclFile "CaptureImage.tcl"
source $path$tclFile 
set output /home/alex/Dropbox/Amplificators/Images/SmoothRectangularInclusion15 
set inputFile Output/AmplificatorTensorForInclusionDensity/AmplificatorTensorForInclusionDensity_15.flavia.res
CaptureImage $inputFile $output 
