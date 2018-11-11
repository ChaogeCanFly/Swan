classdef AnisotropicCTensor < fourthOrderTensor
    
    properties (Access = public)
        FirstTensor
        SecondTensor
        ThirdTensor
    end
    
    methods (Access = public)
        
        function obj = ComplementaryTensor(A,direction)
            obj.generateTensors(A,direction);
            obj.makePlaneStressTensors()
            obj.addTensors()
        end
    end
    
    methods (Access = private)
        
        function generateTensors(obj,A,direction)
            obj.FirstTensor  = A;
            obj.SecondTensor = SecondComplementaryTensor(A,direction);
            obj.ThirdTensor  = ThirdComplementaryTensor(A,direction);
        end
        
        function makePlaneStressTensors(obj)
            obj.FirstTensor.computeTensorVoigtInPlaneStress()
            obj.SecondTensor.computeTensorVoigtInPlaneStress()
            obj.ThirdTensor.computeTensorVoigtInPlaneStress()
        end
        
        function addTensors(obj)
            obj.addFourthOrderRepresentation()
            obj.addVoigtRepresentation()
            obj.addVoigtPlaneStressRepresentation()
%             A2 = obj.tensorVoigtInPlaneStress;
%             obj.computeTensorVoigtInPlaneStress()
%             A3 = obj.tensorVoigtInPlaneStress;
%             A2-A3
        end
        
        function addFourthOrderRepresentation(obj)
            t1  = obj.FirstTensor.tensor;
            t2  = obj.SecondTensor.tensor;
            t3  = obj.ThirdTensor.tensor; 
            obj.tensor = t1 + t2 + t3;
        end
        
        function addVoigtRepresentation(obj)
            t1  = obj.FirstTensor.tensorVoigt;
            t2  = obj.SecondTensor.tensorVoigt;
            t3  = obj.ThirdTensor.tensorVoigt; 
            obj.tensorVoigt = t1 + t2 + t3; 
        end
        
        function addVoigtPlaneStressRepresentation(obj)
            t1  = obj.FirstTensor.tensorVoigtInPlaneStress;
            t2  = obj.SecondTensor.tensorVoigtInPlaneStress;
            t3  = obj.ThirdTensor.tensorVoigtInPlaneStress; 
            obj.tensorVoigtInPlaneStress = t1 + t2 + t3; 
        end
        

        
    end
    
end

