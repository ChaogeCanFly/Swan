classdef OptimizationMetricsPrinter_AugLag < OptimizationMetricsPrinter
    
    methods (Access = protected)
        
        function printConvergenceVariables(obj,fid)
            fprintf(fid,'Optimality tolerance: %f \n',obj.optimizer.unconstrainedOptimizer.opt_cond);
            fprintf(fid,'Kappa: %f \n',obj.optimizer.unconstrainedOptimizer.lineSearch.kappa);
        end
        
    end
    
end

