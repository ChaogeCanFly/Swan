classdef testPerimeterCircleQuadrilateral < testUnfittedIntegration_InternalIntegrator...
                                  & testUnfittedPerimeterIntegration
    
    properties (Access = protected)
        testName = 'test_circle_quadrilateral';
        analiticalArea = 2*pi;
        meshType = 'BOUNDARY';
    end
end

