classdef SettingsTopOptProblem < AbstractSettings
    
    properties (Access = protected)
        defaultParamsName = 'paramsTopOptProblem'
    end
    
    properties (Access = public)
        settings
        fileName
        pdim
        nelem
        designVarSettings
        homogenizedVarComputerSettings
        incrementalSchemeSettings
        optimizerSettings
        videoManagerSettings
    end
    
    properties (Access = private)
        mesh
        caseFileName
    end
    
    methods (Access = public)
        
        function obj = SettingsTopOptProblem(varargin)
            if nargin == 1
                % obj.loadParams(varargin{1});
                settings = varargin{1};
            elseif nargin == 2
                obj.loadParams(varargin{1});
                settings = varargin{2};
            end
            obj.settings = settings;
            obj.caseFileName = settings.case_file;
            obj.createMesh(settings);
            obj.createDesignVarSettings(settings);
            obj.setupProblemData();
            obj.createHomogenizedVarComputerSettings(settings);
            obj.createIncrementalSchemeSettings(settings);
            obj.createOptimizerSettings(settings);
            obj.createVideoManagerSettings();
        end
        
    end
    
    methods (Access = private)
        
        function createMesh(obj,settings)
            obj.mesh = Mesh_GiD(settings.filename);
        end
        
        function createDesignVarSettings(obj,settings)
            obj.designVarSettings.mesh = obj.mesh;
            obj.designVarSettings.type = settings.designVariable;
            obj.designVarSettings.levelSetCreatorSettings       = settings.levelSetDataBase;
            obj.designVarSettings.levelSetCreatorSettings.ndim  = obj.mesh.ndim;
            obj.designVarSettings.levelSetCreatorSettings.coord = obj.mesh.coord;
            obj.designVarSettings.levelSetCreatorSettings.type = settings.initial_case;
            switch obj.designVarSettings.levelSetCreatorSettings.type
                case 'holes'
                    obj.designVarSettings.levelSetCreatorSettings.dirichlet = obj.mesh.dirichlet;
                    obj.designVarSettings.levelSetCreatorSettings.pointload = obj.mesh.pointload;
            end
        end
        
        function setupProblemData(obj)
            obj.pdim  = obj.mesh.pdim;
            obj.nelem = size(obj.mesh.connec,1);
            obj.settings.pdim = obj.pdim;
        end
        
        function createHomogenizedVarComputerSettings(obj,settings)
            obj.homogenizedVarComputerSettings.type                   = settings.homegenizedVariablesComputer;
            obj.homogenizedVarComputerSettings.interpolation          = settings.materialInterpolation;
            obj.homogenizedVarComputerSettings.typeOfMaterial         = settings.material;
            obj.homogenizedVarComputerSettings.constitutiveProperties = settings.TOL;
            obj.homogenizedVarComputerSettings.vademecumFileName      = settings.vademecumFileName;
            obj.homogenizedVarComputerSettings.dim                    = obj.pdim;
            obj.homogenizedVarComputerSettings.nelem                  = obj.nelem;
        end
        
        function createIncrementalSchemeSettings(obj,settings)
            tpS = obj.createTargetParamsSettings(settings);
            obj.incrementalSchemeSettings.settingsTargetParams = tpS;
            obj.incrementalSchemeSettings.nSteps = settings.nsteps;
            obj.incrementalSchemeSettings.shallPrintIncremental = settings.printIncrementalIter;
            
            obj.incrementalSchemeSettings.mesh = obj.mesh;
        end
        
        function createOptimizerSettings(obj,settings)
            settings.pdim = obj.pdim;
            
            uoS = obj.createOptimizerUnconstrainedSettings(settings);
            obj.optimizerSettings.uncOptimizerSettings = uoS;
            
            obj.optimizerSettings.nconstr              = settings.nconstr;
            obj.optimizerSettings.target_parameters    = settings.target_parameters;
            obj.optimizerSettings.constraint_case      = settings.constraint_case;
            obj.optimizerSettings.name                 = settings.optimizer;
            obj.optimizerSettings.maxiter              = settings.maxiter;
            
            obj.optimizerSettings.shallPrint           = settings.printing;
            obj.optimizerSettings.printMode            = settings.printMode;
            
            obj.optimizerSettings.setupSettingsMonitor(settings);
        end
        
        function uoS = createOptimizerUnconstrainedSettings(obj,settings)
            spS = obj.createScalarProductSettings(settings);
            lsS = obj.createLineSearchSettings(settings,spS);
            
            uoS = SettingsOptimizerUnconstrained();
            
            uoS.lineSearchSettings    = lsS;
            uoS.scalarProductSettings = spS;
            
            uoS.e2                  = settings.e2;
            uoS.filter              = settings.filter;
            uoS.printChangingFilter = settings.printChangingFilter;
            uoS.filename            = settings.filename;
            uoS.ptype               = settings.ptype;
            uoS.lb                  = settings.lb;
            uoS.ub                  = settings.ub;
            uoS.type                = settings.optimizer;
        end
        
        function createVideoManagerSettings(obj)
           obj.videoManagerSettings.caseFileName  = obj.caseFileName;
           obj.videoManagerSettings.shallPrint    = obj.optimizerSettings.shallPrint;
           obj.videoManagerSettings.designVarType = obj.designVarSettings.type;
           obj.videoManagerSettings.pdim          = obj.pdim;
        end
        
    end
    
    methods (Access = private, Static)
        
        function tpS = createTargetParamsSettings(settings)
            tpS = SettingsTargetParamsManager;
            tpS.VfracInitial = settings.Vfrac_initial;
            tpS.VfracFinal = settings.Vfrac_final;
            tpS.constrInitial = settings.constr_initial;
            tpS.constrFinal = settings.constr_final;
            tpS.optimalityInitial = settings.optimality_initial;
            tpS.optimalityFinal = settings.optimality_final;
            tpS.epsilonInitial = settings.epsilon_initial;
            tpS.epsilonFinal = settings.epsilon_final;
            tpS.epsilonIsotropyInitial = settings.epsilon_isotropy_initial;
            tpS.epsilonIsotropyFinal = settings.epsilon_isotropy_final;
        end
        
        function spS = createScalarProductSettings(settings)
            spS.filename = settings.filename;
        end
        
        function lsS = createLineSearchSettings(settings,spS)
            lsS.scalarProductSettings = spS;
            lsS.line_search     = settings.line_search;
            lsS.optimizer       = settings.optimizer;
            lsS.HJiter0         = settings.HJiter0;
            lsS.filename        = settings.filename;
            lsS.kappaMultiplier = settings.kappaMultiplier;
        end
        
    end
    
end