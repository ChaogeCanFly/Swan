classdef testCommutingVoigtHomogPlaneStress < test
    
    properties (Access = private)
        theta
        direction
        stiffTensor
        weakTensor
        vhpTensor
        hvpTensor
        vphTensor
    end
    
    methods (Access = public)
        
        function obj = testCommutingVoigtHomogPlaneStress() 
            obj.init()
            obj.computeWeakStiffTensor()
            obj.computeVoigtPlaneStressHomog()
            obj.computeHomogVoigtPlaneStressTensor()
            obj.computeVoigtHomogPlaneStressTensor()
        end       
        
    end
    
    methods (Access = private)
        
        function init(obj)
            obj.theta = rand(1);
            angle = rand(1)*pi/2;
            dir = [cos(angle) sin(angle) 0];           
            obj.direction = Vector3D;
            obj.direction.setValue(dir);
        end
        
        function computeWeakStiffTensor(obj)
            E1  = 1;
            nu1 = 1/3;
            E0  = 1e-1*E1;
            nu0 = 0.1;                
            obj.stiffTensor = IsotropicConstitutiveTensor(E1,nu1);
            obj.weakTensor  = IsotropicConstitutiveTensor(E0,nu0);
        end
                
        function computeHomogVoigtPlaneStressTensor(obj)
            c0     = obj.weakTensor;
            c1     = obj.stiffTensor;
            dir{1} = obj.direction;
            m1     = 1;
            seqHomog = HomogVoigtPlaneStressHomogenizer(c0,c1,dir,m1,obj.theta);
            obj.hvpTensor  = seqHomog.getPlaneStressHomogenizedTensor();
        end
        
        
        function computeVoigtHomogPlaneStressTensor(obj)
            c0     = obj.weakTensor;
            c1     = obj.stiffTensor;
            dir{1} = obj.direction;
            m1     = 1;
            seqHomog = VoigtHomogPlaneStressHomogenizer(c0,c1,dir,m1,obj.theta);  
            obj.vhpTensor  = seqHomog.getPlaneStressHomogenizedTensor();
        end
        
        function computeVoigtPlaneStressHomog(obj)
            c0     = obj.weakTensor;
            c1     = obj.stiffTensor;
            dir{1} = obj.direction;
            m1     = 1;
            seqHomog = VoigtPlaneStressHomogHomogenizer(c0,c1,dir,m1,obj.theta);  
            obj.vphTensor  = seqHomog.getPlaneStressHomogenizedTensor();            
        end
        
        function error = computeTensorDifference(obj,Tensors)
            meanTensor = obj.computeMeanTensor(Tensors);
            error = obj.computeDesviationNorm(Tensors,meanTensor);
        end
        
    end    
    
    methods (Access = private, Static)

        function meanTensor = computeMeanTensor(Tensors)
            d = numel(Tensors);
            meanTensor = zeros(size(Tensors{1}));
            for itens = 1:d
                meanTensor = meanTensor + Tensors{itens};
            end
            meanTensor = meanTensor/d;            
        end
        
        function error = computeDesviationNorm(Tensors,meanTensor)
            d = numel(Tensors);
            tensError = zeros(d,1);
            for itens = 1:d
                desvTensor = (Tensors{itens}-meanTensor);
                tensError(itens) = norm(desvTensor)/norm(meanTensor);
            end             
            error = norm(tensError);
        end
        
    end
        
    methods (Access = protected)
       
         function hasPassed = hasPassed(obj)
            Tensors{1} = obj.vhpTensor.getValue();
            Tensors{2} = obj.hvpTensor.getValue();
            Tensors{3} = obj.vphTensor.getValue();            
            error = obj.computeTensorDifference(Tensors);
            hasPassed = error < 1e-2;
        end
        
        
    end
    
end

