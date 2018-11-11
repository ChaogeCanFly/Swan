classdef Filter_P1_LevelSet_3D < Filter_P1_LevelSet & Filter_LevelSet_3D
    methods
        function obj = Filter_P1_LevelSet_3D(problemID,scale,unfitted_mesh_algorithm)
            obj@Filter_P1_LevelSet(problemID,scale);
            obj@Filter_LevelSet_3D(unfitted_mesh_algorithm);
        end
        
        function preProcess(obj)
            preProcess@Filter_P1(obj)
            preProcess@Filter_LevelSet_3D(obj)
        end
    end
end