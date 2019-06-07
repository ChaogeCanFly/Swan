classdef Filter_PDE_LevelSet < Filter_PDE 
    
    properties(Access = private)
        integrator
        unfittedMesh
        domainType        
    end
    
    methods (Access = public)
        
        function obj = Filter_PDE_LevelSet(cParams)
            obj.init(cParams)
            obj.domainType = cParams.domainType;
            
            obj.diffReacProb.preProcess();
            obj.createQuadrature();
            obj.computeGeometry();
            obj.nelem = obj.mesh.nelem;
            obj.npnod = obj.geometry.interpolation.npnod;           
            obj.ngaus = obj.quadrature.ngaus;
            obj.Anodal2Gauss = obj.computeA();
            
            cParams = SettingsMeshUnfitted(obj.domainType,obj.mesh,obj.interpolation);
            obj.unfittedMesh = Mesh_Unfitted.create2(cParams);
            obj.integrator = Integrator.create(obj.unfittedMesh);            
            obj.disableDelaunayWarning();                 
        end
        
        function preProcess(obj)
       
        end
        
        function RHS = integrate_L2_function_with_shape_function(obj,x)
            F = ones(size(x));
            RHS = obj.computeRHS(x,F);
        end
        
        function RHS = integrate_function_along_facets(obj,x,F)
            RHS = obj.computeRHS(x,F);
        end
        
        function M2 = computeRHS(obj,x,F1)
            obj.unfittedMesh.computeMesh(x);
            M2 = obj.integrator.integrateUnfittedMesh(F1,obj.unfittedMesh);
        end        
        
    end
    
    methods (Access = private)
        
        function createQuadrature(obj)
            obj.quadrature = Quadrature.set(obj.mesh.geometryType);
            obj.quadrature.computeQuadrature(obj.quadratureOrder);
        end        
          
        function computeGeometry(obj)
            obj.geometry = Geometry(obj.mesh,'LINEAR');
            obj.geometry.interpolation.computeShapeDeriv(obj.quadrature.posgp);
            obj.geometry.computeGeometry(obj.quadrature,obj.geometry.interpolation);
        end
                
        
      function disableDelaunayWarning(obj)
            MSGID = 'MATLAB:delaunayTriangulation:DupPtsWarnId';
            warning('off', MSGID)
        end        
          
    end
    
end