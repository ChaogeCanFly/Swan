classdef IsotropicConstitutiveTensor3D < IsotropicConstitutiveTensor
    
    properties
    end
    
    methods
        
        function obj = IsotropicConstitutiveTensor3D(E,nu)
            obj.CreateIsotropicConstitutiveTensor(E,nu);
            obj.generate()
            obj.tensorVoigt = obj.RespresentTensorinVoigt(obj.tensor);
        end
        
        function computeBulkModulus(obj)
            obj.kappa = obj.lambda + 2/3*obj.mu;        
        end
        
        function generate(obj)
           dim = 3;
           %obj.tensor = zeros(dim,dim,dim,dim);
           I = eye(dim,dim); 
          % I(3,3) = 1/sqrt(2);
               for i = 1:dim
                    for j = 1:dim
                        for k = 1:dim
                            for l = 1:dim
                                T(i,j,k,l) =  obj.mu*(I(i,k)*I(j,l) + I(i,l)*I(j,k)) + obj.lambda*I(i,j)*I(k,l);
                            end
                        end
                    end
               end
               
             obj.tensor = T;
        end
        
    end
    
end

