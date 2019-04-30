classdef Optimizer_Constrained < Optimizer
    
    properties (Access = public)
        fhtri
        niter = 0
        maxiter
    end
    
    properties (Access = protected)
        hasFinished
        designVariable
        monitor
        cost
        constraint
        constraintCase
        historyPrinter
        iStep
        nStep
    end
    
    properties (Access = private)
        postProcess
        printing
        printMode
    end
    
    methods (Access = public)
        
        function solveProblem(obj,iStep,nStep)
            obj.iStep = iStep;
            obj.nStep = nStep;
            obj.createPostProcess();
            x0 = obj.designVariable.value;
            obj.cost.computeCostAndGradient();
            obj.constraint.computeCostAndGradient();
            obj.printOptimizerVariable();
            
            obj.hasFinished = false;
            
             while ~obj.hasFinished
                obj.niter = obj.niter+1;
                obj.update();
                obj.updateStatus();
                obj.monitor.refresh(obj.niter,obj.hasFinished,iStep,nStep);
                obj.printOptimizerVariable();
                obj.printHistory()
            end
            obj.printOptimizerVariable();            
            obj.hasConverged = 0;
        end
        
    end
    
    methods (Access = protected)
        
        function updateStatus(obj)
            obj.hasFinished = obj.hasConverged || obj.niter >= obj.maxiter*(obj.iStep/obj.nStep);
        end
        
        function printOptimizerVariable(obj)
            d.x = obj.designVariable.value;
            d.cost = obj.cost;
            d.constraint = obj.constraint;
            obj.postProcess.print(obj.niter,d);
        end
        
        function printHistory(obj)
            obj.historyPrinter.print(obj.niter,obj.iStep);
        end
        
        function createPostProcess(obj)
            fileName = obj.designVariable.mesh.problemID;
            d = obj.createPostProcessDataBase(fileName);
            d.printMode = obj.printMode;
            d.optimizer = obj.name;
            d.cost = obj.cost;
            d.constraint = obj.constraint;
            d.designVar  = obj.designVariable.type;
            if obj.printing
                obj.postProcess = Postprocess('TopOptProblem',d);
            else
                obj.postProcess = Postprocess_Null('',d);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function init(obj,cParams)
            set = cParams.settings;
            
            obj.constraintCase   = set.constraint_case;
            obj.hasConverged     = false;
            
            obj.cost       = cParams.cost;
            obj.constraint = cParams.constraint;
            
            obj.designVariable = cParams.designVar;
            obj.maxiter   = set.maxiter;
            obj.printing  = set.printing;
            obj.printMode = set.printMode;
            obj.createHistoyPrinter();
            
            convVarD = ConvergenceVarsDispatcher.dispatchNames(obj.name);
            nconvVar = numel(convVarD);
            convVar = ConvergenceVariables(nconvVar);
            
            obj.convergenceVars = convVar;
            
            obj.createMonitorDocker(cParams,set);
        end
        
    end
    
    methods (Access = private)
        
        function createHistoyPrinter(obj)
            settingsMetricsPrinter.fileName = obj.designVariable.mesh.problemID;
            settingsMetricsPrinter.optimizer = obj;
            settingsMetricsPrinter.cost = obj.cost;
            settingsMetricsPrinter.constraint = obj.constraint;
            obj.historyPrinter = OptimizationMetricsPrinterFactory.create(obj.name,obj.printing,settingsMetricsPrinter);
        end
        
        function createMonitorDocker(obj,cParams,set) 
            s = cParams.settingsMonitor;
            
            s.problemID                   = set.case_file;
            s.costFuncNames               = set.cost;
            s.costWeights                 = set.weights;
            s.constraintFuncs             = set.constraint;
            s.dim                         = set.pdim;
            
            s.designVar                   = obj.designVariable;
            s.optimizerName               = obj.name;
            s.cost                        = obj.cost;
            s.constraint                  = obj.constraint;
            
            s.convergenceVars = obj.convergenceVars;
            
            
            obj.monitor = MonitoringDocker(s);
        end
        
        function d = createPostProcessDataBase(obj,fileName)
            d.mesh    = obj.designVariable.mesh;
            d.outName = fileName;
            ps = PostProcessDataBaseCreator(d);
            d  = ps.getValue();
        end
        
    end
    
end
