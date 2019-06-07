classdef TopOptTests < testRunner

    properties (Access = protected)
        FieldOfStudy = 'Topology Optimization'
        tests
    end

    methods (Access = public)

        function obj = TopOptTests()
            obj@testRunner();
        end

    end

    methods (Access = protected)

        function loadTests(obj)
            obj.tests = {...                
                'testCantilever3';
                'testBridge';                
                'testMicro';
                'testMicro2';    
                'testCantilever2';
                'testCantilever';
                'testBridge2';                                  
                'testDualNestedInPrimalWithProjectedGradient';  
                'testDualNestedInPrimalWithSlerp';                                
                'testStressM1M2';                
                'testM1M2';    
                'testGripping';        
                
                };
        end

    end

end
