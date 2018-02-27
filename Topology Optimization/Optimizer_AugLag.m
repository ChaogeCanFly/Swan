classdef Optimizer_AugLag < Optimizer
    properties
        optimizer_unconstr
        penalty
        iter = 0;
    end
    methods
        function obj = Optimizer_AugLag(settings,optimizer_unconstr)
            obj@Optimizer(settings,settings.monitoring);
            obj.objfunc = Objective_Function_AugLag(settings);
            obj.optimizer_unconstr = optimizer_unconstr;
        end
        function x = updateX(obj,x_ini,cost,constraint,interpolation)
            obj.checkInitial;
            obj.optimizer_unconstr.target_parameters = obj.target_parameters;
            obj.objfunc.lambda = obj.objfunc.lambda+obj.objfunc.penalty.*constraint.value';
            constraint.lambda = obj.objfunc.lambda;
            obj.objfunc.computeFunction(cost,constraint);
            obj.objfunc.computeGradient(cost,constraint);
                       
            obj.optimizer_unconstr.objfunc = obj.objfunc;
            obj.optimizer_unconstr.objfunc.value_initial = obj.objfunc.value;
            obj.optimizer_unconstr.computeKappa(x_ini,obj.objfunc.gradient);
            obj.optimizer_unconstr.stop_criteria = 1;
            
            while (obj.optimizer_unconstr.stop_criteria)
                x = obj.optimizer_unconstr.updateX(x_ini,cost,constraint,interpolation); %x = obj.optimizer_unconstr.updateX(x_ini,cost,constraint,obj.physicalProblem,interpolation,filter);
                obj.stop_vars = obj.optimizer_unconstr.stop_vars;
            end
            
            active_constr = obj.penalty > 0;
            obj.stop_criteria = obj.optimizer_unconstr.opt_cond >=  obj.optimizer_unconstr.optimality_tol || any(any(abs(constraint.value(active_constr)) > obj.optimizer_unconstr.constr_tol(active_constr)));
            
%             % !! For monitoring (NOT DECIDED IF MONITOR AugLag) !!
%             stop_vars{1,1} = obj.optimizer_unconstr.optimality_tol; stop_vars{1,2} = obj.optimizer_unconstr.opt_cond;
%             stop_vars{2,1} = abs(constraint.value(active_constr)); stop_vars{2,2} = obj.optimizer_unconstr.constr_tol(active_constr);
        end
        function checkInitial(obj)
            if isempty(obj.optimizer_unconstr.Ksmooth)
                obj.optimizer_unconstr.Msmooth = obj.Msmooth;
                obj.optimizer_unconstr.Ksmooth = obj.Ksmooth;
                obj.optimizer_unconstr.epsilon_scalar_product_P1 = obj.epsilon_scalar_product_P1;
            end
        end
        
    end
    
end