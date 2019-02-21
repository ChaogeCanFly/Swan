classdef HomogenizationTests < testRunner
    
    properties (Access = protected)
        FieldOfStudy = 'Homogenization'
        tests
    end
    
    methods (Access = public)
        function obj = HomogenizationTests()
            obj@testRunner();
        end
    end
    
    methods (Access = protected)
        function loadTests(obj)
            obj.tests = {...
                'testHorizontalLaminate';
                'testNumericalConvergenceOfNumberOfLaminates';                                
                'testDiagonalLaminate';
                'testCommutingHomogPlaneStressWithZeroPoisson';
                'testNotCommutingHomogPlaneStress';
                'testCommutingVoigtHomog';
                'testAnisotropicPlaneStressbyEnergyEquivalence';
                'testStressInPlaneStress';
                'testStressRotationInVoigtNotationIn3D';
                'testStressRotationInVoigtNotationInPlaneStress';
                'testInverseSymmetricFourthOrderTensor' ;
                'testInverseNonSymmetricFourthOrderTensor';
                'testInverseOfInverseForStiffTensor';
                'testIsotropicFourthOrderTensor'
                'testInverseSymmetricFourthOrderTensor';
                'testSymmetrizeIsotropicFourthOrderTensor';
                'testSymmetryForIAniTensorInVoigt'
                'testMakeAnisotorpicTensorPlaneStressSymbolically';
                'testEnergyEquivalenceVoigtAndTensorNotationForIsoTensor';
                'testEnergyEquivalenceVoigtAndTensorNotationForIAniTensor';
                'testSymmetrizeFourthOrderTensor';
                'testComplianceTensorThrougtVoigtComparingEnergy';
                'TestTwoRankSequentialLaminate';
                'testHorizontalTensorRotatedVsVHP';
                'testHorizontalTensorRotatedVsVPH';
                'testHorizontalTensorRotatedVsRank2';
                'testHorizontalTensorRotatedVsHVP';
                'TestGeneralTwoRankSequentialLaminate';
                };
        end
        
    end
    
end

