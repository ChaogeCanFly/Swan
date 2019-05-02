classdef Cost < CC
    
    properties (Access = private)
        weights
    end
    
    methods (Access = public)
        
        function obj = Cost(settings,designVar,homogVarComputer,targetParameters)
            obj.init(settings,settings.cost,designVar,homogVarComputer,targetParameters);            
            obj.setWeights(settings.weights);
        end
        
    end
    
    methods (Access = protected)
        
        function updateFields(obj,iSF)
            obj.value = obj.value + obj.weights(iSF)*obj.shapeFunctions{iSF}.value;
            obj.gradient = obj.gradient + obj.weights(iSF)*obj.shapeFunctions{iSF}.gradient;
        end
        
    end
    
    methods (Access = private)
        
        function setWeights(obj,weights)
            if isempty(weights)
                obj.weights = ones(1,length(settings.cost));
            else
                obj.weights = weights;
            end
        end
        
    end
    
end
