classdef Density < DesignVariable
    
    methods (Access = public)
        
        function obj = Density(cParams)
            obj.value = cParams.value;
            obj.meshGiD = cParams.mesh;
        end
        
        function update(obj,value)
            obj.value = value;
        end
        
    end
    
    methods (Access = private)
        
    end
    
end

