classdef Shape_Functional < handle
    properties
        value
        gradient
        target_parameters=struct;
        filter
    end    
    methods
        function obj = Shape_Functional(settings)
            obj.filter = Filter.create(settings.filter,settings.optimizer);
        end
            
        computef(obj, x)
    end
end
