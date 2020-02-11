classdef IntegratorCutMesh < Integrator
    
    properties (GetAccess = public, SetAccess = protected)
        cutMesh
        backgroundMesh
    end
    
    properties (Access = private)
        backgroundInterp
        unfittedInterp
        quadrature
        xGauss
        RHScells
        RHScellsCut
    end
    
    methods (Access = public)
        
        function obj = IntegratorCutMesh(cParams)
            obj.init(cParams);
            obj.cutMesh = obj.mesh;
            obj.backgroundMesh = obj.cutMesh.getBackgroundMesh();
        end
        
        function A = integrate(obj,F)
            obj.initShapes();
            obj.computeElementalRHS(F);
            obj.assembleSubcellsInCells();
            A = obj.assembleIntegrand();
        end
        
    end
    
    methods (Access = private)
        
        function initShapes(obj)
            nelem = obj.backgroundMesh.nelem;
            cNelem = length(obj.cutMesh.cellContainingSubcell);obj.cutMesh.nelem;
            nnode = obj.backgroundMesh.nnode;
            obj.RHScells = zeros(nelem,nnode);
            obj.RHScellsCut = zeros(cNelem,nnode);
        end
        
        function computeElementalRHS(obj,F1)
            int = obj.RHScellsCut;
            obj.createBackgroundInterpolation();
            obj.createUnfittedInterpolation();
            obj.computeThisQuadrature();
            obj.computeUnfittedGaussPoints();
            
            nelem = length(obj.cutMesh.cellContainingSubcell);% nelem;
            for isubcell = 1:nelem
                shape = obj.computeShape(isubcell);
                djacob = obj.computeJacobian(isubcell);
                icell  = obj.cutMesh.cellContainingSubcell(isubcell);
                inode = obj.backgroundMesh.connec(icell,:);
                weight = obj.quadrature.weigp';
                isoDv  = obj.unfittedInterp.isoDv;
                
                F0 = (shape*weight)'*F1(inode)/isoDv;
                
                int(isubcell,:) = int(isubcell,:) + (shape*(djacob.*weight)*F0)';
            end
            obj.RHScellsCut = int;
        end
        
        function assembleSubcellsInCells(obj)
            totalInt = obj.RHScells;
            nnode = obj.backgroundMesh.nnode;
            nelem = obj.backgroundMesh.nelem;
            cellNum = obj.cutMesh.cellContainingSubcell;
            
            for iNode = 1:nnode
                int = obj.RHScellsCut(:,iNode);
                intGlobal  = accumarray(cellNum,int,[nelem,1],@sum,0);
                totalInt(:,iNode) = totalInt(:,iNode) + intGlobal;
            end
            obj.RHScells = totalInt;
        end
        
        function f = assembleIntegrand(obj)
            integrand = obj.RHScells;
            npnod  = obj.backgroundMesh.npnod;
            nnode  = obj.backgroundMesh.nnode;
            connec = obj.backgroundMesh.connec;
            f = zeros(npnod,1);
            for inode = 1:nnode
                int = integrand(:,inode);
                con = connec(:,inode);
                f = f + accumarray(con,int,[npnod,1],@sum,0);
            end
        end
        
        function itIs = isLeveSetCuttingMesh(obj)
            itIs = ~isempty(obj.cutMesh.backgroundCutCells);
        end
        
    end
    
    methods (Static, Access = private)
        
        function xG = computeXgauss(coord,interpolation,quadrature)
            interpolation.computeShapeDeriv(quadrature.posgp);
            xG = zeros(quadrature.ngaus,size(coord,3),size(coord,1));
            for igaus = 1:quadrature.ngaus
                for idime = 1:size(coord,3)
                    xG(igaus,idime,:) = coord(:,:,idime)*interpolation.shape(:,igaus);
                end
            end
        end
        
        function djacob = mapping(points,dvolu)
            % !! PERFORM THROUGH GEOMETRY CLASS OR EXTRACT "mapping" CAPACITY FROM
            % GEOMETRY CLASS !!
            
            N_points = size(points,1);
            switch N_points
                case 2
                    v = diff(points);
                    L = norm(v);
                    djacob = L/dvolu;
                case 3
                    if size(points,2) == 2
                        points = [points, zeros(N_points,1)];
                    end
                    v1 = diff(points([1 2],:));
                    v2 = diff(points([1 3],:));
                    A = 0.5*norm(cross(v1,v2));
                    djacob = A/dvolu;
                case 4
                    v1 = diff(points([1 2],:));
                    v2 = diff(points([1 3],:));
                    v3 = diff(points([1 4],:));
                    V = (1/6)*det([v1;v2;v3]);
                    djacob = V/dvolu;
            end
        end
        
    end
    
    methods (Access = private)
        
        function shape = computeShape(obj,isubcell)
            xGaus = obj.xGauss(:,:,isubcell)';
            obj.backgroundInterp.computeShapeDeriv(xGaus);
            shape = obj.backgroundInterp.shape;
        end
        
        function computeThisQuadrature(obj)
            type = obj.cutMesh.geometryType;
            obj.quadrature = obj.computeQuadrature(type);
        end
        
        function computeUnfittedGaussPoints(obj)
            coord = obj.cutMesh.subcellIsoCoords;
            inter = obj.unfittedInterp;
            quad  = obj.quadrature;
            xGaus = obj.computeXgauss(coord,inter,quad);
            obj.xGauss = xGaus;
        end
        
        function createBackgroundInterpolation(obj)
            mesh = obj.backgroundMesh;
            int = Interpolation.create(mesh,'LINEAR');
            obj.backgroundInterp = int;
        end
        
        function createUnfittedInterpolation(obj)
            mesh = obj.cutMesh;
            int = Interpolation.create(mesh,'LINEAR');
            obj.unfittedInterp = int;
        end
        
        function dJ = computeJacobian(obj,isubcell)
            connec = obj.cutMesh.connec(isubcell,:);
            coord  = obj.cutMesh.coord(connec,:);
            isoDv = obj.unfittedInterp.isoDv;
            dJ = obj.mapping(coord,isoDv); % !! Could be done through Geometry class?? !!
        end
        
    end
    
end

