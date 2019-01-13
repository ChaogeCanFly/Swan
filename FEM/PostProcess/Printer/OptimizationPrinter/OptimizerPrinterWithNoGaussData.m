classdef OptimizerPrinterWithNoGaussData < OptimizerPrinter
    
    
    methods (Access = protected)
        
        function obtainHasGaussDataAndQuad(obj)
            obj.hasGaussData = false;
        end
        
    end
    
    
end