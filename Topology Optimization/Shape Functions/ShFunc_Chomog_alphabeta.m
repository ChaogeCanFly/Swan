classdef ShFunc_Chomog_alphabeta < ShFunc_Chomog
    properties (Access = private)
        alpha
        beta
    end
    methods
        function obj=ShFunc_Chomog_alphabeta(settings)
            obj@ShFunc_Chomog(settings);
            obj.alpha=settings.micro.alpha/norm(settings.micro.alpha);
            obj.beta=settings.micro.beta/norm(settings.micro.beta);
        end
        function computeCostAndGradient(obj,x)
            obj.computePhysicalData(x);
            obj.computeFunctionValue();
            obj.computeGradient(x);
            obj.normalizeFunctionAndGradient();
        end
    end
    
    methods (Access = private)
        
        function computeGradient(obj,x)
            obj.compute_Chomog_Derivatives(x);
            inv_matCh = inv(obj.Chomog);
            gradient = obj.derivative_projection_Chomog(inv_matCh,obj.alpha,obj.beta);            
            mass     = obj.Msmooth;
            gradient = obj.filter.getP1fromP0(gradient');
            gradient = mass*gradient;
            obj.gradient = gradient;
        end
        
        function computeFunctionValue(obj)
            inv_matCh = inv(obj.Chomog);
            c = obj.projection_Chomog(inv_matCh,obj.alpha,obj.beta);
            obj.value = c;
        end
        
    end
end