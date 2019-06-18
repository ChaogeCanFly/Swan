classdef UnfittedIntegrationTests < testRunner
    
    properties (Access = protected)
        FieldOfStudy = 'Unfitted integration'
        tests
    end
    
    methods (Access = public)
        
        function  obj = UnfittedIntegrationTests()
            obj@testRunner();
        end
        
    end
    
    methods (Access = protected)
        
        function loadTests(obj)
            obj.tests = {...
                'testSurfaceCylinderTetrahedra';
                
                'testPerimeterRectangleTriangle'
                'testPerimeterRectangleQuadrilateral'
                
                'testPerimeterCircleTriangle'
                'testPerimeterCircleQuadrilateral'
                
                'testAreaCircleTriangle'
                'testAreaCircleQuadrilateral'
                
                'testSurfaceSphereTetrahedra';
                'testSurfaceSphereHexahedra';
                
                'testVolumeSphereTetrahedra';
                'testVolumeSphereHexahedra';
                
                
                'testSurfaceCylinderHexahedra';
                
                'testVolumeCylinderTetrahedra';
                'testVolumeCylinderHexahedra';
                };
        end
        
    end
    
end

