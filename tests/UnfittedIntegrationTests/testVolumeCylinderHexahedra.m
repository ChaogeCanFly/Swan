classdef testVolumeCylinderHexahedra < testUnfittedIntegration_InternalIntegrator...
                                  & testUnfittedVolumeIntegration
    
   properties (Access = protected)
        testName = 'test_cylinder_hexahedra';  
        analiticalArea = pi*2;
        meshType = 'INTERIOR';
   end
 
end

