classdef TopOpt_Problem < handle
    
    properties (GetAccess = public,SetAccess = public)
        cost
        constraint
        designVariable
        x
        algorithm
        optimizer
        mesh
        settings
        incrementalScheme
    end
    
    properties (Access = private)
        hole_value
        ini_design_value
    end
    
    methods (Access = public)
        
        function obj = TopOpt_Problem(settings)
            obj.createDesignVariable(settings);
            settings.pdim = obj.mesh.pdim;
            obj.settings = settings;
            obj.incrementalScheme = IncrementalScheme(settings,obj.mesh);
            obj.optimizer = OptimizerFactory().create(obj.settings.optimizer,settings,obj.designVariable,obj.incrementalScheme.targetParams.epsilon);
            obj.cost = Cost(settings,settings.weights);
            obj.constraint = Constraint(settings);
        end
        
        function preProcess(obj)
            obj.cost.preProcess;
            obj.constraint.preProcess;
            obj.x = obj.designVariable.value;
        end
        
        function computeVariables(obj)
            obj.incrementalScheme.link(obj.cost,obj.constraint,obj.optimizer);
            while obj.incrementalScheme.hasNext()
                obj.incrementalScheme.next();
                obj.solveCurrentProblem();
            end
        end
        
        
        function postProcess(obj)
            % Video creation
            if obj.settings.printing
                gidPath = 'C:\Program Files\GiD\GiD 13.0.4';% 'C:\Program Files\GiD\GiD 13.0.3';
                files_name = obj.settings.case_file;
                files_folder = fullfile(pwd,'Output',obj.settings.case_file);
                iterations = 0:obj.optimizer.niter;
                video_name = strcat('./Videos/Video_',obj.settings.case_file,'_',int2str(obj.optimizer.niter),'.gif');
                My_VideoMaker = VideoMaker_TopOpt.Create(obj.settings.optimizer,obj.mesh.pdim,obj.settings.case_file);
                My_VideoMaker.Set_up_make_video(gidPath,files_name,files_folder,iterations)
                
                output_video_name_design_variable = fullfile(pwd,video_name);
                My_VideoMaker.Make_video_design_variable(output_video_name_design_variable)
            end
        end
        
    end
    
    methods (Access = private)
        
        function createDesignVariable(obj,settings)
            obj.mesh = Mesh_GiD(settings.filename);
            designVarSettings.mesh = obj.mesh;
            designVarInitializer = DesignVariableCreator(settings,obj.mesh);
            designVarSettings.value = designVarInitializer.getValue();
            designVarSettings.optimizer = settings.optimizer;
            obj.designVariable = DesignVariableFactory().create(designVarSettings);
        end
        
        function solveCurrentProblem(obj)
            istep = obj.incrementalScheme.iStep;
            obj.designVariable = obj.optimizer.solveProblem(obj.designVariable,obj.cost,obj.constraint,istep,obj.settings.nsteps);
            obj.x = obj.designVariable.value;
        end
        
    end
    
end