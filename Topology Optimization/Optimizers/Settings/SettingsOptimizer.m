classdef SettingsOptimizer < AbstractSettings
    
    properties (Access = protected)
        defaultParamsName = 'paramsOptimizer.json'
    end
    
    properties (Access = public)
        type
        problemData
        targetParameters
        constraintCase
        nConstr
        maxIter
        
        designVar
        dualVariable
        cost
        constraint
        
        shallPrint
        printMode
        
        uncOptimizerSettings
        monitoringDockerSettings
        incrementalScheme
        postProcessSettings
        historyPrinterSettings
    end
    
    methods (Access = public)
        
        function obj = SettingsOptimizer(varargin)
            if nargin == 1
                obj.loadParams(varargin{1});
            end
            obj.init();
        end
        
        function init(obj)
            obj.initProblemData();
            obj.initSettingsMonitorDocker();
            obj.initSettingsHistoryPrinter();
            obj.initSettingsPostProcess();
            obj.initOptimizerUnconstrainedSettings();
        end
        
    end
    
    methods (Access = private)
        
        function initProblemData(obj)
            s = obj.problemData;
            obj.problemData = TopOptProblemDataContainer(s);
        end
        
        function initSettingsMonitorDocker(obj)
            s = obj.monitoringDockerSettings;
            obj.monitoringDockerSettings = SettingsMonitoringDocker(s);
            
            s2.optimizerName = obj.type;
            s2.problemID       = obj.problemData.caseFileName;
            s2.dim             = obj.problemData.femData.pdim;
            s2.costFuncNames   = obj.problemData.costFunctions;
            s2.costWeights     = obj.problemData.costWeights;
            s2.constraintFuncs = obj.problemData.constraintFunctions;
            s2.boundaryConditions = obj.problemData.femData.bc;
            obj.monitoringDockerSettings.loadParams(s2);
        end
        
        
        function initSettingsHistoryPrinter(obj)
            obj.historyPrinterSettings.fileName   = obj.problemData.caseFileName;
            obj.historyPrinterSettings.shallPrint = obj.shallPrint;
        end
        
        function initSettingsPostProcess(obj)
            obj.postProcessSettings.shallPrint  = obj.shallPrint;
            obj.postProcessSettings.printMode   = obj.printMode;
            obj.postProcessSettings.femFileName = obj.problemData.caseFileName;
            %obj.postProcessSettings.femFileName = obj.problemData.femData.fileName;
            obj.postProcessSettings.pdim  = obj.problemData.femData.pdim;
            obj.postProcessSettings.ptype = obj.problemData.femData.ptype;
        end
        
        function initOptimizerUnconstrainedSettings(obj)
            s = obj.uncOptimizerSettings;
            obj.uncOptimizerSettings = SettingsOptimizerUnconstrained(s);
            s2.problemData = obj.problemData;
            obj.uncOptimizerSettings.loadParams(s2);
            obj.uncOptimizerSettings.init();
        end
        
    end
    
end