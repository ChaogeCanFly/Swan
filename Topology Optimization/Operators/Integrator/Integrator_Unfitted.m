classdef Integrator_Unfitted < Integrator
    
    properties (Access = private)
        integrators
    end
    
    methods (Access = public)
        
        function obj = Integrator_Unfitted(cParams)
            obj.init(cParams);
        end
        
        function int = integrateInDomain(obj,F)
            obj.computeInteriorIntegrators();
            int = obj.integrators.integrateAndSum(F);
        end
        
        function int = integrateInBoundary(obj,F)
            obj.computeBoundaryIntegrators();
            int = obj.integrators.integrateAndSum(F);
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.mesh = cParams.mesh;
        end
        
        function computeInteriorIntegrators(obj)
            s = obj.createInteriorParams(obj.mesh,obj.mesh.backgroundMesh.connec);
            obj.integrators = Integrator.create(s);
        end
        
        function computeBoundaryIntegrators(obj)
            uMesh  = obj.mesh;
            s.type = 'COMPOSITE';      
            s.npnod = uMesh.backgroundMesh.npnod; 
            s.compositeParams = obj.computeCompositeParams();
            obj.integrators = Integrator.create(s);
        end
        
        function s = computeCompositeParams(obj)
            uMesh  = obj.mesh.unfittedBoundaryMesh;        
            [sUnfitted,nMeshes] = obj.createUnfittedBoundaryMeshParams(uMesh);     
            s = cell(nMeshes+1,1);
            for iMesh = 1:nMeshes
                s{iMesh} = sUnfitted{iMesh};
            end
            sCut = obj.createCutParams(obj.mesh.backgroundMesh.connec,obj.mesh.boundaryCutMesh,obj.mesh.backgroundMesh);            
            s{nMeshes+1} = sCut;            
        end
        
        function [s,nMeshes] = createUnfittedBoundaryMeshParams(obj,uMesh)            
            uMeshes = uMesh.getActiveMesh();
            gConnec = uMesh.getGlobalConnec();
            nMeshes = numel(uMeshes);
            s = cell(nMeshes,1);
            for iMesh = 1:nMeshes
              s{iMesh} = obj.createInteriorParams(uMeshes{iMesh},gConnec{iMesh});
            end
        end
        
        function s = createInnerParams(obj,gConnec,mesh)
            s.mesh = mesh;
            s.type = 'SIMPLE';
            s.globalConnec      = gConnec;
            s.npnod             = obj.mesh.backgroundMesh.npnod;
            s.geometryType      = mesh.type;
        end
        
        function s = createCutParams(obj,gConnec,mesh,backgroundMesh)
            s.mesh = mesh;
            s.type = 'CutMesh';
            s.globalConnec      = gConnec;
            s.npnod             = obj.mesh.backgroundMesh.npnod;
            s.geometryType      = backgroundMesh.type;
        end
        
        function s = createInteriorParams(obj,mesh,connec)
            s.type = 'COMPOSITE';
            s.npnod = mesh.backgroundMesh.npnod;
            s.compositeParams = cell(0);
            if ~isempty(mesh.innerMesh)
                fullCells = mesh.innerMesh.fullCells;
                gConnec   = connec(fullCells,:);
                s.compositeParams{1} = obj.createInnerParams(gConnec,mesh.innerMesh.mesh);
            end
            if ~isempty(mesh.innerCutMesh)
                gConnec = connec;
                s.compositeParams{end+1} = obj.createCutParams(gConnec,mesh.innerCutMesh,mesh.backgroundMesh);
            end
        end
        

        
    end
    
end