classdef AmplificatorTests < testRunner
    
    
    properties (Access = protected)
        FieldOfStudy = 'AmplificatorTest'
        tests
    end
    
    methods (Access = public)
        function obj = AmplificatorTests()
            obj@testRunner();
        end
    end
    
    methods (Access = protected)
        function loadTests(obj)
            obj.tests = {...   
                   'testAmplificatorTensorForRectangleInclusion';
                   'testAmplificatorTensorForSmoothRectangleInclusion';                
                   'testAmplificatorTensorNumericVsExplicitForSeqLam';
                };

        end
    end
    
end

