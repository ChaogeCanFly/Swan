classdef PrintingTests < testRunner
    
    
    properties (Access = protected)
        FieldOfStudy = 'Printing Tests'
        tests
    end
    
    methods (Access = public)
        function obj = PrintingTests()
            obj@testRunner();
        end
    end
    
    methods (Access = protected)
        function loadTests(obj)
            obj.tests = {...        
                  'testTopOptDesignAndShapes';                                      
            'testTopOptLevelSetPrinting';
            'testTopOptGaussDensityPrinting';                
                  'testFEMPrinting';
                  'testTopOptNonSelfAdjoint'
                  'testTopOptLevelSetGaussDensityPrinting';                                                     
                  'testTopOptDesignElemDensShapePrinting';                                  
                  'testTopOptDensityPrinting';                                    
                };

        end
    end
    
end
