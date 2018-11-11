classdef StressTensor < SecondOrderTensor
   
    properties

    end
    
    methods 
        
        function obj = StressTensor()
          obj = obj@SecondOrderTensor();
        end
        
        
        
        function computeVoigtFactor(obj,iv)
            obj.VoigtFactor = 1;
        end
        
        
        
        function makeItPlaneStress(obj)
            obj.makeTensorPlaneStress();
            obj.transformTensor2Voigt();
            obj.computePlaneStressTensor();
        end


        
        
    end
    
    methods (Access = private)
        function makeTensorPlaneStress(obj)
            obj.tensor(1,3) = 0;
            obj.tensor(2,3) = 0;
            obj.tensor(3,1) = 0;
            obj.tensor(3,2) = 0;
            obj.tensor(3,3) = 0;        
        end  
        
        
    end
    
end

