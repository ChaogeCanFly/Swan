classdef test3dHexahedra < testCheckStoredAndFemComputedVariable
    
    
    properties (Access = protected)
        testName = 'test3d_hexahedra';  
        computedVar
        variablesToStore = {'d_u'};
    end
       
    methods (Access = protected)
        
        function selectComputedVar(obj)
            obj.computedVar{1} = obj.fem.variables.d_u;            
        end
        
    end
    

end

