classdef ShFunc_NonSelfAdjoint_Compliance < ShFunWithElasticPdes
    
    properties (Access = private)
        adjointProb
    end
    
    methods (Access = public)
        
        function obj = ShFunc_NonSelfAdjoint_Compliance(cParams)
            cParams.filterParams.quadratureOrder = 'LINEAR';            
            obj.init(cParams);     
            fileName = cParams.femSettings.fileName;
            obj.createEquilibriumProblem(fileName);
            obj.createAdjointProblem(fileName)            
        end
        
        function f = getPhysicalProblems(obj)
            f{1} = obj.physicalProblem;
            f{2} = obj.adjointProb;
        end
        
    end
    
    methods (Access = protected)

        function computeFunctionValue(obj)
            u = obj.physicalProblem.variables.d_u;
            f = obj.adjointProb.variables.fext;
            obj.value = -f'*u;
        end
        
        function g = updateGradient(obj,igaus,istre,jstre)
            eu   = obj.physicalProblem.variables.strain;
            ev   = obj.adjointProb.variables.strain;
            eu_i = squeeze(eu(igaus,istre,:));
            ev_j = squeeze(ev(igaus,jstre,:)); 
            g = zeros(length(eu_i),1,obj.nVariables);            
            for ivar = 1:obj.nVariables
                dCij = squeeze(obj.homogenizedVariablesComputer.dC(istre,jstre,ivar,:));            
                g(:,1,ivar) = eu_i.*dCij.*ev_j;
            end              
        end
        
        function solvePDEs(obj)
            obj.adjointProb.setC(obj.homogenizedVariablesComputer.C);
            obj.adjointProb.computeVariables();
            obj.physicalProblem.setC(obj.homogenizedVariablesComputer.C);
            obj.physicalProblem.computeVariables();
        end
        
    end
    
    methods (Access = private)
        
        function createAdjointProblem(obj,fileName)
            fAdj = Preprocess.getBC_adjoint(fileName);
            obj.adjointProb = FEM.create(fileName);
            [dof,dofVal] = obj.adjointProb.dof.get_dof_conditions(fAdj,obj.adjointProb.dof.nunkn);
            obj.adjointProb.dof.neumann = dof;
            obj.adjointProb.dof.neumann_values = -dofVal;
            obj.adjointProb.preProcess;
        end
        
    end
end
