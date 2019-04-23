classdef testUnfitted < test
    
    properties (Access = protected, Abstract)
        testName
        meshType
        meshIncludeBoxContour
    end
    
    properties (Access = protected)
        topOpt
        levelSet
        mesh
    end
    
    methods (Access = protected)
        
        function createTopOpt(obj)
            file_name_in = fullfile('.','Input',obj.testName);
            settings = Settings(file_name_in);
            settings.printChangingFilter = false;
            obj.topOpt = TopOpt_Problem(settings);
            obj.levelSet = obj.topOpt.designVariable.value;
        end
        
        function createMesh(obj)
            meshBackground = obj.topOpt.designVariable.meshGiD;
            interpolation = Interpolation.create(meshBackground,'LINEAR');
            settingsUnfitted = SettingsMeshUnfitted(obj.meshType,meshBackground,interpolation,obj.meshIncludeBoxContour);
            obj.mesh = Mesh_Unfitted_Factory.create(settingsUnfitted);
            obj.mesh.computeMesh(obj.levelSet);
        end
        
    end
    
end

