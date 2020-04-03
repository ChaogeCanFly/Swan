classdef PlottingTests < testRunner
    properties (Access = protected)
        FieldOfStudy = 'Plotting'
        tests
    end
    
    methods (Access = public)
        function  obj = PlottingTests()
            obj@testRunner();
           % close all;
        end
    end
    
    methods (Access = protected)
        function loadTests(obj)
            obj.tests = {...
            'testPlotCircleQuadrilateral'   
            'testPlotCircleTriangle'                                
            'testRectangleTriangle'
            'testRectangleQuadrilateral'           
            'testSmoothRectangleTriangle'                          
            'testSmoothRectangleQuadrilateral'
            'testCircumferenceTriangle'
            'testCircumferenceQuadrilateral'
            'testPlotSphereTetrahedra';
            'testPlotSphereHexahedra';                                
            'testPlotCylinderTetrahedra';
            'testPlotCylinderHexahedra';  
            };
        end
    end
end
