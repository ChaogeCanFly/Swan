classdef Filter_PDE_LevelSet_3D < Filter_PDE_LevelSet & Filter_LevelSet_3D
    methods
        function obj = Filter_PDE_LevelSet_3D(problemID,scale)
            obj@Filter_PDE_LevelSet(problemID,scale);
        end
        
        function preProcess(obj)
            preProcess@Filter_PDE(obj)
            preProcess@Filter_LevelSet_3D(obj)
        end
    end
end