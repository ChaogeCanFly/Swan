classdef ShFunc_Volume < Shape_Functional
    properties 
        Vfrac
        geometric_volume
    end
    
    methods 
        function obj = ShFunc_Volume(settings)
           obj@Shape_Functional(settings);
           obj.geometric_volume = sum(obj.dvolu(:));
        end
        

        
        function computeCostAndGradient(obj,x)

            rho = obj.filter.getP0fromP1(x);
            
            volume = sum(sum(obj.dvolu,2)'*rho);
            volume = volume/(obj.geometric_volume);
            
            gradient_volume = 1/(obj.geometric_volume);
            
            gradient_volume = gradient_volume*ones(size(obj.filter.connectivities,1),size(obj.dvolu,2));
            gradient_volume = obj.filter.getP1fromP0(gradient_volume);
            gradient_volume = obj.Msmooth*gradient_volume;
            
            obj.value = volume;
            obj.gradient = gradient_volume;
        end
    end
end
