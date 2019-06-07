classdef Filter_P1_Density < handle %Filter_P1
    
    properties (Access = private)
       mesh
       quadratureOrder
               
        Poper

        x
        x_reg        

        geometry
        quadrature
        
        M
        Kernel        
    end
    
    properties
        
    end
    
    methods (Access = public)
        
        function obj = Filter_P1_Density(cParams)
            obj.init(cParams);
            obj.createMassMatrix(cParams);
            obj.createQuadrature();
            obj.createGeometry();
            obj.createPoperator(cParams);
            obj.createFilterKernel();
        end
        
        function preProcess(obj)
            
        end
        
        function x_reg = getP1fromP0(obj,x0)
            RHS = obj.integrateRHS(x0);
            P = obj.Poper.value;
            x_reg = P'*RHS;
        end
        
        function x0 = getP0fromP1(obj,x)
            if obj.xHasChanged(x)
                x0 = obj.computeP0fromP1(x);
            else
                x0 = obj.x_reg;
            end
            obj.updateStoredValues(x,x0);
        end
        
    end
    
    methods (Access = private)
        
        function itHas = xHasChanged(obj,x)
            itHas = ~isequal(x,obj.x);
        end
        
        function updateStoredValues(obj,x,x0)
            obj.x = x;
            obj.x_reg = x0;
        end        
        
        function init(obj,cParams)
            obj.createDiffReacProblem(cParams);
            obj.mesh = cParams.designVar.mesh;
            obj.quadratureOrder = cParams.quadratureOrder;
        end
      
        function x0 = computeP0fromP1(obj,x)
            x0 = obj.Kernel*x;
        end
        
        function createFilterKernel(obj)
            P = obj.Poper.value;
            obj.Kernel = P*obj.M;
        end
        
        function createMassMatrix(obj,cParams)
            diffReacProb = obj.createDiffReacProblem(cParams);
            diffReacProb.preProcess();
            obj.M = diffReacProb.element.M;
        end
        
        function pB = createDiffReacProblem(obj,cParams)
            s = cParams.femSettings;
            switch s.scale
                case 'MACRO'
                    pB = DiffReact_Problem(s);
                case 'MICRO'
                    pB = DiffReact_Problem_Micro(s);
            end
        end        
        
        function intX = integrateRHS(obj,x)
            intX = zeros(obj.mesh.nelem,1);
            ngaus = size(x,2);
            for igaus = 1:ngaus
                dvolu = obj.geometry.dvolu(:,igaus);
                intX = intX + dvolu.*x(:,igaus);
            end
        end
        
        function createPoperator(obj,cPar)
            cParams.nelem  = obj.mesh.nelem;
            cParams.nnode  = obj.geometry.interpolation.nnode;
            cParams.npnod  = obj.geometry.interpolation.npnod;
            cParams.connec = obj.mesh.connec;
            cParams.diffReactEq = cPar.femSettings;
            obj.Poper = Poperator(cParams);
        end
        
        function createQuadrature(obj)
            obj.quadrature = Quadrature.set(obj.mesh.geometryType);
            obj.quadrature.computeQuadrature(obj.quadratureOrder);
        end
                
        function createGeometry(obj)
            obj.geometry = Geometry(obj.mesh,'LINEAR');
            obj.geometry.interpolation.computeShapeDeriv(obj.quadrature.posgp);
            obj.geometry.computeGeometry(obj.quadrature,obj.geometry.interpolation);
        end
        
    end
    
end