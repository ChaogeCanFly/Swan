classdef UnfittedMesh < handle
    
    
    properties (GetAccess = public, SetAccess = private)
        innerMesh
        innerCutMesh
        boundaryCutMesh
        unfittedBoxMeshes
        
        backgroundEmptyCells
        
        %TopOpt + Unfitted
        backgroundFullCells
        globalConnec
        unfittedType
        meshBackground
        
        
        %TopOpt
        backgroundCutCells
        
        cellContainingSubcell
        geometryType
        coord
        connec
        
        
        
        
        isInBoundary
        
    end
    
    properties (Access = private)
        levelSet
    end
    
    methods (Access = public)
        
        function obj = UnfittedMesh(cParams)
            obj.meshBackground = cParams.meshBackground;
            
            obj.unfittedType = cParams.unfittedType;

            if isobject(cParams)
                if (isempty(cParams.isInBoundary))
                    obj.isInBoundary = false;
                else
                    obj.isInBoundary = cParams.isInBoundary;
                end
            else
                if isfield(cParams,'isInBoundary')
                    obj.isInBoundary = cParams.isInBoundary;
                else
                    obj.isInBoundary = false;
                end
            end
            
             
        end
        
        function compute(obj,lvlSet)
            
            obj.levelSet = lvlSet;
            
            cellsClassifier = CellsClassifier;
            [F,E,C] = cellsClassifier.classifyCells(lvlSet,obj.meshBackground.connec);
            
            
            %1.subcellIsoCoords
            %2.cellContainingSubcell
            
            
            
            %Both
            obj.backgroundFullCells  = F;
            obj.backgroundEmptyCells = E;
            obj.backgroundCutCells   = C;
            
            
            obj.computeInnerMesh();
            obj.computeInnerCutMesh();
            obj.computeBoundaryCutMesh();
            obj.computeUnfittedBoxMesh();
            
            obj.updateParamsforTopOpt();
            
            
        end
        
        function plot(obj)
            % figure
            switch obj.unfittedType
                case 'BOUNDARY'
                    %obj.oldUnfittedMeshBoundary.plot();
                    %figure
                    hold on
                    obj.boundaryCutMesh.plot();
                    
                    for imesh = 1:length(obj.unfittedBoxMeshes.isBoxFaceMeshActive)
                        if obj.unfittedBoxMeshes.isBoxFaceMeshActive(imesh)
                            m = obj.unfittedBoxMeshes.boxFaceMeshes{imesh};
                            m.plot();
                        end
                    end
                    
                    light
                    axis equal off
                    hold off
                case 'INTERIOR'
                    % figure;
                    hold on
                    obj.innerMesh.plot;
                    obj.innerCutMesh.plot;
                    light
                    axis equal off
                    hold off
            end
        end
        
    end
    
    methods (Access = private)
        
        function updateParamsforTopOpt(obj)
            
            switch obj.unfittedType
                case 'BOUNDARY'
                    mesh = obj.boundaryCutMesh;
                case 'INTERIOR'
                    mesh = obj.innerCutMesh;
            end
            
            if isprop(mesh,'geometryType')
                %obj.geometryType = mesh.geometryType;
                obj.geometryType = obj.innerMesh.geometryType;
            end
            
            obj.cellContainingSubcell = mesh.cellContainingSubcell;
            obj.coord  = mesh.coord; %Why?? Not necessary
            obj.connec = mesh.connec; %Why?? Not necessary
            
        end
        
        function computeInnerMesh(obj)
            obj.computeInnerGlobalConnec();
            s.backgroundCoord = obj.meshBackground.coord;
            s.globalConnec    = obj.globalConnec;
            s.isInBoundary    = obj.isInBoundary;
            obj.innerMesh = InnerMesh(s);
        end
        
        function computeInnerGlobalConnec(obj)
            fullCells = obj.backgroundFullCells;
            obj.globalConnec = obj.meshBackground.connec(fullCells,:);
        end
        
        function computeInnerCutMesh(obj)
            s.type                   = 'INTERIOR';
            s.meshBackground          = obj.meshBackground;
            s.interpolationBackground = Interpolation.create(obj.meshBackground,'LINEAR');
            s.backgroundFullCells     = obj.backgroundFullCells;
            s.backgroundEmptyCells    = obj.backgroundEmptyCells;
            s.backgroundCutCells      = obj.backgroundCutCells;
            s.isInBoundary            = obj.isInBoundary;
            s.levelSet = obj.levelSet;
            obj.innerCutMesh = CutMesh(s);
        end
        
        function computeBoundaryCutMesh(obj)
            if ~obj.isInBoundary
                s.type                    = 'BOUNDARY';
                s.meshBackground          = obj.meshBackground;
                s.interpolationBackground = Interpolation.create(obj.meshBackground,'LINEAR');
                s.backgroundFullCells     = obj.backgroundFullCells;
                s.backgroundEmptyCells    = obj.backgroundEmptyCells;
                s.backgroundCutCells      = obj.backgroundCutCells;                
                s.isInBoundary            = obj.isInBoundary;                
                s.levelSet = obj.levelSet;
                obj.boundaryCutMesh = CutMesh(s);
            end
        end
        
        function computeUnfittedBoxMesh(obj)
            if isequal(class(obj.meshBackground),'Mesh_Total')
                m = obj.meshBackground;
                fMeshes = m.boxFaceMeshes;
                fNodes  = m.nodesInBoxFaces;
                fGlobalConnec = m.globalConnectivities;
                sides = 2;
                nboxFaces = sides*m.ndim;
                isBoxFaceMeshActive = false([1 nboxFaces]);
                iFace = 0;
                for idime = 1:m.ndim
                    for iside = 1:sides
                        iFace = iFace + 1;
                        mesh = fMeshes{iFace};
                        nodesInBoxFace = fNodes{iFace};
                        interp = Interpolation.create(mesh,'LINEAR');
                        s.type = 'INTERIOR';
                        s.meshBackground = mesh;
                        s.interpolationBackground = interp;
                        cParams = SettingsMeshUnfitted(s);
                        %cParams.type = 'BOUNDARY';
                        cParams.isInBoundary = true;
                        boxFaceMesh = UnfittedMesh(cParams);
                        
                        %mshBack = boxFaceMesh.meshBackground;
                        
                        lsBoxFace = obj.levelSet(nodesInBoxFace);
                        if any(sign(lsBoxFace)<0) %obj.isBoxMeshActive(lsBoxFace)
                            boxFaceMesh.compute(lsBoxFace);
                            isBoxFaceMeshActive(iFace) = true;
                        end
                        
                        boxFaceMeshes{iFace}        = boxFaceMesh;
                        nodesInBoxFaces{iFace}      = nodesInBoxFace;
                        globalConnectivities{iFace} = fGlobalConnec{iFace};
                        
                    end
                end
                obj.unfittedBoxMeshes.boxFaceMeshes = boxFaceMeshes;
                obj.unfittedBoxMeshes.isBoxFaceMeshActive = isBoxFaceMeshActive;
                obj.unfittedBoxMeshes.nodesInBoxFaces = nodesInBoxFaces;
                obj.unfittedBoxMeshes.globalConnectivities = globalConnectivities;
            end
        end
        
    end
    
    methods (Access = public)
        
        function m = computeMass(obj)
            switch obj.unfittedType
                case 'BOUNDARY'
                    cParams.mesh = obj.boundaryCutMesh;
                    cParams.type = obj.unfittedType;
                    integrator = Integrator.create(cParams);
                    nnodesBackground = size(obj.levelSet);
                    fInt = integrator.integrate(ones(nnodesBackground));
                    m = sum(fInt);
                    
                case 'INTERIOR'
                    s.mesh = obj;
                    s.type = 'COMPOSITE';
                    s = obj.createInteriorParams(s,s.mesh);
                    integrator = Integrator.create(s);
                    nodalF = ones(size(obj.levelSet));
                    fInt = integrator.integrateAndSum(nodalF);
                    m = sum(fInt);
            end
        end
        
        function int = integrateNodalFunction(obj,f)
            uMesh = obj;
            cParams.mesh = uMesh;
            cParams.type = 'COMPOSITE';
            switch obj.unfittedType%    meshType
                case 'INTERIOR'
                    cParams = obj.createInteriorParams(cParams,uMesh);
                case 'BOUNDARY'
                        cParams.compositeParams = cell(0);                    
                    if ~isempty(uMesh.unfittedBoxMeshes)
                        meshes = uMesh.unfittedBoxMeshes;
                        cParams.boxFaceToGlobal = meshes.nodesInBoxFaces;
                        iActive = 1;
                        for iMesh = 1:length(meshes.isBoxFaceMeshActive)
                            isActive = meshes.isBoxFaceMeshActive(iMesh);
                            if isActive
                                boxFaceMesh = meshes.boxFaceMeshes{iMesh};
                                params = obj.createCompositeParams(boxFaceMesh,uMesh);
                                params.boxFaceToGlobal = meshes.nodesInBoxFaces{iMesh};
                                params.meshBackground = uMesh.meshBackground;
                                cParams.compositeParams{iActive} = params;
                                iActive = iActive + 1;
                            end
                        end
                    end
                    cParamsInnerBoundaryCut = obj.createBoundaryCutParams(uMesh);
                    cParams.compositeParams{end+1} = cParamsInnerBoundaryCut;
            end
            integratorC = Integrator.create(cParams);
            int = integratorC.integrateAndSum(f);
        end
        
        function mass = computeMass2(obj)
            npnod = obj.meshBackground.npnod;
            f = ones(npnod,1);
            fInt = obj.integrateNodalFunction(f);
            mass = sum(fInt);
        end
        
        function add2plot(obj,ax,removedDim,removedCoord)
            switch obj.unfittedType
                case 'BOUNDARY'
                    obj.boundaryCutMesh.add2plot(ax);
                    for imesh = 1:length(obj.unfittedBoxMeshes.isBoxFaceMeshActive)
                        if obj.unfittedBoxMeshes.isBoxFaceMeshActive(imesh)
                            m = obj.unfittedBoxMeshes.boxFaceMeshes{imesh};
                            m.add2plot(ax,removedDim,removedCoord);
                        end
                    end
                    
                case 'INTERIOR'
                    obj.innerMesh.add2plot(ax);
                    obj.innerCutMesh.add2plot(ax,removedDim,removedCoord);                    
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function cParams = createInteriorParams(obj,cParams,mesh)
            if mesh.innerCutMesh.nelem ~= 0
                cParamsInnerCut = obj.createInnerCutParams(mesh);
                cParams.compositeParams{1} = cParamsInnerCut;
                if mesh.innerMesh.nelem ~= 0
                    cParamsInner = obj.createInnerParams(mesh);
                    cParams.compositeParams{end+1} = cParamsInner;
                end
            else
                if mesh.innerMesh.nelem ~= 0
                    cParamsInner = obj.createInnerParams(mesh);
                    cParams.compositeParams{1} = cParamsInner;
                else
                    cParams.compositeParams = cell(0);
                end
            end
        end
        
        function cParams = createInnerParams(obj,mesh)
            cParams.mesh = mesh.innerMesh;
            cParams.type = 'SIMPLE';
            cParams.globalConnec = mesh.globalConnec;
            cParams.npnod = mesh.innerMesh.npnod;
            cParams.backgroundMesh = mesh.meshBackground;
            cParams.innerToBackground = mesh.backgroundFullCells;
        end
        
        function cParams = createInnerCutParams(obj,mesh)
            cParams.mesh = mesh.innerCutMesh;
            cParams.type = 'CutMesh';
            cParams.meshBackground = mesh.meshBackground;
        end
        
        function cParams = createBoundaryCutParams(obj,mesh)
            cParams.mesh = mesh.boundaryCutMesh;
            cParams.type = 'CutMesh';
            cParams.meshBackground = mesh.meshBackground;
        end
        
        function cParams = createCompositeParams(obj,mesh,thisMesh)
            cParams.mesh = mesh;
            cParams.type = 'COMPOSITE';
            cParams.backgroundMesh = obj.meshBackground; %%
            cParams.globalConnec = obj.globalConnec;
            cParams.innerToBackground = [];
            cParams.npnod = thisMesh.meshBackground.npnod;
            cParams = obj.createInteriorParams(cParams,mesh);
        end
    end
 
    
end