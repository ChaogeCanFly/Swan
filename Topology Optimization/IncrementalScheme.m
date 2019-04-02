classdef IncrementalScheme < handle
    
    properties (GetAccess = public, SetAccess = private)
        iStep
        nSteps
        targetParams
    end
    
    properties (Access = private)
        targetParamsManager
        
        epsilonInitial
        epsilonFinal
        epsilonPerInitial
        epsilonPerFinal
        epsilonIsoInitial
        epsilonIsoFinal
        
        shallDisplayStep
    end
    
    methods (Access = public)
        
        function obj = IncrementalScheme(settings,mesh)
            obj.init(settings,mesh);
            obj.createTargetParams(settings);
        end
        
        function next(obj)
            obj.incrementStep();
            obj.updateTargetParams();
        end
        
        function display(obj)
            disp(['Incremental Scheme - Step: ',int2str(obj.iStep),' of ',int2str(obj.nSteps)]);
        end
        
        function itDoes = hasNext(obj)
            if obj.iStep < obj.nSteps
                itDoes = true;
            else
                itDoes = false;
            end
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,settings,mesh)
            obj.iStep = 0;
            obj.nSteps = settings.nsteps;
            obj.setupEpsilons(settings,mesh);
            obj.setWhetherShallDisplayStep(settings);
        end
        
        function createTargetParams(obj,cParams)
            settingsTargetParams = obj.createTargetSettings(cParams);            
            obj.targetParamsManager = TargetParamsManager(settingsTargetParams);
            obj.targetParams = obj.targetParamsManager.targetParams;
        end
        
        function updateTargetParams(obj)
            obj.targetParamsManager.update(obj.iStep);
        end
        
        function incrementStep(obj)
            obj.iStep = obj.iStep + 1;
            if obj.shallDisplayStep
                obj.display();
            end
        end
        
        function setupEpsilons(obj,cParams,mesh)
            L = mesh.computeCharacteristicLength();
            D = mesh.computeMeanCellSize();
            obj.assignWithBackup('epsilonInitial',cParams.epsilon_initial,D);
            obj.assignWithBackup('epsilonFinal',cParams.epsilon_final,obj.epsilonInitial);
            obj.epsilonPerInitial = L;
            obj.epsilonPerFinal = obj.epsilonInitial;
            obj.assignWithBackup('epsilonIsoInitial',cParams.epsilon_isotropy_initial,nan);
            obj.assignWithBackup('epsilonIsoFinal',cParams.epsilon_isotropy_final,nan);
            
        end
        
        function settingsTargetParams = createTargetSettings(obj,cParams)
            settingsTargetParams = SettingsTargetParamsManager();
            
            settingsTargetParams.nSteps = obj.nSteps;
            settingsTargetParams.Vfrac_initial = cParams.Vfrac_initial;
            settingsTargetParams.Vfrac_final = cParams.Vfrac_final;
            settingsTargetParams.constr_initial = cParams.constr_initial;
            settingsTargetParams.constr_final = cParams.constr_final;
            settingsTargetParams.optimality_initial = cParams.optimality_initial;
            settingsTargetParams.optimality_final = cParams.optimality_final;
            
            settingsTargetParams.epsilonInitial = obj.epsilonInitial;
            settingsTargetParams.epsilonFinal = obj.epsilonFinal;
            settingsTargetParams.epsilonPerInitial = obj.epsilonPerInitial;
            settingsTargetParams.epsilonPerFinal = obj.epsilonPerFinal;
            settingsTargetParams.epsilonIsotropyInitial = cParams.epsilon_isotropy_initial;
            settingsTargetParams.epsilonIsotropyFinal = cParams.epsilon_isotropy_final;
        end
        
        function setWhetherShallDisplayStep(obj,settings)
            obj.shallDisplayStep = settings.printIncrementalIter;
            if isempty(settings.printIncrementalIter)
                obj.shallDisplayStep = true;
            end
        end
        
        function assignWithBackup(obj,prop,a,b)
            if ~isempty(a)
                obj.(prop) = a;
            else
                obj.(prop) = b;
            end
        end
        
    end
    
end