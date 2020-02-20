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
        oldMeshUnfitted
    end
    
    properties (Access = private)
        settings
    end
    
    methods (Access = protected)
        
        function createTopOpt(obj)
            obj.createSettings();
            obj.topOpt = TopOpt_Problem(obj.settings);
            obj.levelSet = obj.topOpt.designVariable.value;
        end
        
        function createMesh(obj)
            meshBackground = obj.topOpt.designVariable.mesh;
            interpolation = Interpolation.create(meshBackground,'LINEAR');
            s.unfittedType = obj.meshType;
            s.meshBackground = meshBackground;
            s.interpolationBackground = interpolation;
            s.includeBoxContour = obj.meshIncludeBoxContour;
            cParams = SettingsMeshUnfitted(s);
            
            obj.mesh = UnfittedMesh(cParams);
            obj.mesh.compute(obj.levelSet);
            
            
            meshBackground = obj.topOpt.designVariable.mesh;
            interpolation = Interpolation.create(meshBackground,'LINEAR');
            s.unfittedType = obj.meshType;
            s.meshBackground = meshBackground;
            s.interpolationBackground = interpolation;
            s.includeBoxContour = obj.meshIncludeBoxContour;
            cParams2 = SettingsMeshUnfitted(s);
            obj.oldMeshUnfitted = Mesh_Unfitted.create2(cParams2);
            
            ls = obj.topOpt.designVariable.value;
%            obj.oldMeshUnfitted.computeMesh(ls)
            
            
        end
        
    end
    
    methods (Access = private)
        
        function createSettings(obj)
            obj.createOldSettings();
            obj.translateToNewSettings();
        end
        
        function createOldSettings(obj)
            fileName = obj.testName;
            s = Settings(fileName);
            s.warningHoleBC = false;
            s.printIncrementalIter = false;
            s.printChangingFilter = false;
            s.printing = false;
            obj.settings = s;
        end
        
        function translateToNewSettings(obj)
            translator = SettingsTranslator();
            translator.translate(obj.settings);
            fileName = translator.fileName;
            obj.settings  = SettingsTopOptProblem(fileName);
        end
        
    end
    
end

