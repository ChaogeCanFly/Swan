classdef testPerimeterRectangleQuadrilateral < testUnfittedIntegration_InternalIntegrator...
                                  & testUnfittedPerimeterRectangleIntegration
    
    properties (Access = protected)
        testName = 'test_rectangle_quadrilateral';
        analiticalArea = 8;
        meshType = 'BOUNDARY';
    end
    
end

