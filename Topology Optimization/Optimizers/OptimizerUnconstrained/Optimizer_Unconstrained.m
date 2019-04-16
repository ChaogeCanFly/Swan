classdef Optimizer_Unconstrained < Optimizer
    
    properties (Access = public)
        objectiveFunction
        opt_cond
    end
    
    properties (GetAccess = public, SetAccess = protected)
        designImproved
        maxIncrNormX
    end
    
    properties (GetAccess = public, SetAccess = private)
        line_search
        scalar_product
        constr_tol
    end
    
    methods (Access = public, Abstract)
        
        computeX(obj)
        
    end
    
    
    methods (Access = public)
        
        function obj = Optimizer_Unconstrained(settings)            
            obj.nconstr           = settings.nconstr;
            obj.target_parameters = settings.target_parameters;
            obj.has_converged     = false;            
            
            obj.line_search    = LineSearch.create(settings.lineSearchSettings);
            obj.scalar_product = ScalarProduct(settings.scalarProductSettings);
        end
        
        function x = update(obj,x0,objfunc)
            obj.objectiveFunction = objfunc;
            x = obj.computeX(x0,obj.objectiveFunction.gradient);
            obj.objectiveFunction.updateBecauseOfPrimal(x);
            obj.updateConvergenceParams(x,x0);
            
            if ~obj.has_converged
                obj.line_search.computeKappa();
            end
        end
        
        function init(obj,x0,objFunc)
            obj.objectiveFunction = objFunc;
            obj.objectiveFunction.setInitialValue();
            obj.initLineSearch(x0);
            obj.has_converged = false;
        end
        
    end
    
    methods (Access = private)
        
        function updateConvergenceParams(obj,x,x_ini)
            incrementNormL2  = obj.norm_L2(x,x_ini);
            incrementObjFunc = obj.objectiveFunction.computeIncrement();
            
            obj.designImproved = incrementObjFunc < 0 && incrementNormL2 < obj.maxIncrNormX;
            
            obj.has_converged = obj.designImproved || obj.line_search.kappa <= obj.line_search.kappa_min;
            
            obj.stop_vars(1,1) = incrementObjFunc;                 obj.stop_vars(1,2) = 0;
            obj.stop_vars(2,1) = incrementNormL2;              obj.stop_vars(2,2) = obj.maxIncrNormX;
            obj.stop_vars(3,1) = obj.line_search.kappa;     obj.stop_vars(3,2) = obj.line_search.kappa_min;
        end
        
        function initLineSearch(obj,x0)
            obj.line_search.initKappa(x0,obj.objectiveFunction.gradient);
        end
        
    end
    
    methods (Access = public)
        
        function N_L2 = norm_L2(obj,x,x_ini)
            inc_x = x-x_ini;
            N_L2 = obj.scalar_product.computeSP_M(inc_x,inc_x)/obj.scalar_product.computeSP_M(x_ini,x_ini);
        end
        
    end
    
    methods
        
        function constr_tol = get.constr_tol(obj)
            constr_tol(1:obj.nconstr) = obj.target_parameters.constr_tol;
        end
        
    end
    
end