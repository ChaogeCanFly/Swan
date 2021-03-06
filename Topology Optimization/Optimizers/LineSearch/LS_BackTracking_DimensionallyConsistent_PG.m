classdef LS_BackTracking_DimensionallyConsistent_PG < LS_BackTracking_DimensionallyConsistent & LS_BackTracking_PG
    methods
        function obj = LS_BackTracking_DimensionallyConsistent_PG(cParams)
            obj@LS_BackTracking_PG(cParams);
        end
        
        function initKappa(obj,x,g)
            xNorm = obj.scalar_product.computeSP(x,x);
            gNorm = obj.scalar_product.computeSP(g,g);
            %obj.kappa = sqrt(xNorm/gNorm);
            obj.kappa = 0.1*sqrt(xNorm/gNorm);
        end
    end
end

