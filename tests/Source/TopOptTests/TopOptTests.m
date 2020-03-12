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
                'testCantilever2';
            'SimplAllTest3DExplicitVsImplicit';                
                 'SimplAllTest2DExplicitVsImplicit';
                'testCantilever3';                 
                 'testBridge2';                                                               
                'testMicro';                 
                'testDualNestedInPrimalWithProjectedGradient';
                'testDualNestedInPrimalWithSlerp';                  
                 'testMicro2';                 
                'testCantilever';                
                'testAnalyticVsRegularizedPerimeter';               
                'testInteriorPerimeter';                
                'testVigdergauzMicroStructureWithStrain';                 
                'testVigdergauzMicroStructure';                                                              
                'testGripping';   
                'testStressM1M2';
                'testM1M2';               
                'testBridge';                                 
                };
        end
        
    end
    
end
