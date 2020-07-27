classdef PlottingTests < testRunner
    properties (Access = protected)
        FieldOfStudy = 'Plotting'
        tests
    end
    
    methods (Access = public)
        function  obj = PlottingTests()
            obj@testRunner();
            pause(0.5)
            close all;
        end
    end
    
    methods (Access = protected)
        function loadTests(obj)
            obj.tests = {... 
          %  'testCircumferenceQuadrilateral'                
          %  'testCircumferenceTriangle'            
            'testPlotCircleTriangle'                 
            'testPlotCircleQuadrilateral'                 
            'testRectangleTriangle'
            'testRectangleQuadrilateral'      
             'testSmoothRectangleTriangle'
            'testSmoothRectangleQuadrilateral'                            
            'testPlotSphereTetrahedra';
            'testPlotSphereHexahedra';                                
            'testPlotCylinderTetrahedra';
            'testPlotCylinderHexahedra';  
             'testPlotLargeCylinderTethaedra';            
            };
        end
    end
end
