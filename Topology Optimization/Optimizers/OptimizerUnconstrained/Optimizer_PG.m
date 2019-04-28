classdef Optimizer_PG < Optimizer_Unconstrained
    
    properties  (GetAccess = public, SetAccess = private)
        optimality_tol
    end
    
    properties (GetAccess = public, SetAccess = protected)
        name = 'PROJECTED GRADIENT'
    end
    
    properties (Access = private)
       upperBound
       lowerBound
    end
    
    methods (Access = public)
        
        function obj = Optimizer_PG(settings)
            obj@Optimizer_Unconstrained(settings);
            obj.upperBound = settings.ub;
            obj.lowerBound = settings.lb;            
        end
        
        function x_new = compute(obj)
            x_n      = obj.designVariable.value;
            gradient = obj.objectiveFunction.gradient;            
            x_new = x_n-obj.line_search.kappa*gradient;
            ub = obj.upperBound*ones(length(x_n(:,1)),1);
            lb = obj.lowerBound*ones(length(x_n(:,1)),1);
            x_new = max(min(x_new,ub),lb);
            obj.opt_cond = sqrt(obj.scalar_product.computeSP(x_new - x_n,x_new - x_n))/sqrt(obj.scalar_product.computeSP(x_n,x_n));
        end
        
    end
    
    methods
        
        function optimality_tol = get.optimality_tol(obj)
            optimality_tol = obj.target_parameters.optimality_tol;
        end
        
    end
    
end