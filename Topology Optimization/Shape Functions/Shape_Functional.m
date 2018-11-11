<<<<<<< HEAD
classdef Shape_Functional < handle
    properties
        value
        gradient
        target_parameters=struct;
        filter
        Msmooth
        dvolu
    end 
    
    methods
        function obj = Shape_Functional(settings)
            obj.filter = Filter.create(settings);
           diffReacProb = DiffReact_Problem(settings.filename);
           diffReacProb.preProcess;
           obj.Msmooth = diffReacProb.element.M;
           obj.dvolu = diffReacProb.geometry.dvolu;

        end
            
        computeCostAndGradient(obj, x)
    end
end
=======
classdef Shape_Functional < handle
    properties
        value
        gradient
        target_parameters=struct;
        filter
        Msmooth
        dvolu
    end 
    
    methods
        function obj = Shape_Functional(settings)
           obj.filter = Filter.create(settings);
           diffReacProb = DiffReact_Problem(settings.filename);
           diffReacProb.preProcess;
           obj.Msmooth = diffReacProb.element.M;
           obj.dvolu = diffReacProb.geometry.dvolu;

        end
            
        computeCostAndGradient(obj, x)
    end
end
>>>>>>> master
