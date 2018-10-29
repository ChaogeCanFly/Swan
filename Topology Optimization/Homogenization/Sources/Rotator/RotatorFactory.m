classdef RotatorFactory < handle
    
    properties (Access = private)
        tensor
        angle
        dir
        rotator
        className
    end
    
    methods (Access = public)
        
        function rotator = create(obj,tensor,angle,direction)
            obj.init(tensor,angle,direction)
            obj.createRotator()
            rotator = obj.getRotator();            
        end                
        
    end
    
    methods (Access = private)
        
        function init(obj,tensor,angle,normalDirection)
            obj.tensor = tensor;
            obj.angle = angle;
            obj.dir = normalDirection;            
            obj.obtainClassName()
        end                
        
        function createRotator(obj)
            a = obj.angle;
            d = obj.dir;
            if obj.isStressVoigtTensor()
                if obj.isVoigtTensor3D()
                    obj.rotator = StressVoigtRotator(a,d);
                elseif obj.isVoigtTensorPlaneStress()
                    obj.rotator = StressVoigtPlaneStressRotator(a,d);
                else
                    error('Not admitted object to be Rotated')
                end
            elseif obj.isFourthOrderVoigtTensor()
                if obj.isVoigtTensor3D()
                    obj.rotator = FourthOrderVoigtRotator(a,d);
                elseif obj.isVoigtTensorPlaneStress()
                    obj.rotator = FourthOrderVoigtPlaneStressRotator(a,d);
                else
                    error('Not admitted object to be Rotated')
                end
            elseif obj.isStressTensor() 
                obj.rotator = StressRotator(a,d);
            elseif obj.isVector()
                obj.rotator = VectorRotator(a,d);
            else
                error('Not admitted object to be Rotated')
            end
            
        end
        
        function itIs = isVector(obj)            
            [m,n] = size(obj.tensor);
            itIs = m == 3 && n == 1 || n == 3 && m==1;
        end
        
        function obtainClassName(obj)            
            obj.className = class(obj.tensor);
        end
        
        function itIs = isStressVoigtTensor(obj)
            itIs = strcmp(obj.className,'StressVoigtTensor');            
        end
        
        function itIs = isFourthOrderVoigtTensor(obj)
            itIs = strcmp(obj.className,'FourthOrderVoigtTensor');            
        end
        
        function itIs = isStressTensor(obj)
            itIs = strcmp(obj.className,'StressTensor');            
        end
        
        function itIs = isVoigtTensorPlaneStress(obj)
            itIs = size(obj.tensor.getValue(),1) == 3;
        end
        
        function itIs = isVoigtTensor3D(obj)
            itIs = size(obj.tensor.getValue(),1) == 6;
        end
        
        function r = getRotator(obj)
            r = obj.rotator;                        
        end
        
    end
    
end

