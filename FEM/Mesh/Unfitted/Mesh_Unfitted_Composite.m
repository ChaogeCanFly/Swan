classdef Mesh_Unfitted_Composite < Mesh_Unfitted
    
    properties (Access = public)
        meshBackground
    end
    
    properties (GetAccess = public, SetAccess = private)
        meshes
        nMeshes
        
        meshInterior
        boxFaceMeshes
        globalConnectivities
        activeBoxFaceMeshesList
        activeMeshesList
        nBoxActiveMeshes
        nActiveMeshes
        unfittedType = 'COMPOSITE'
    end
    
    properties (Access = private)
        nodesInBoxFaces
        isBoxFaceMeshActive
        
        removedDimensions
        removedDimensionCoord
        
        nboxFaces
        ndim
        nsides = 2;
    end
    
    methods (Access = public)
        
        function obj = Mesh_Unfitted_Composite(cParams)
            obj.init(cParams.meshBackground);
            obj.createInteriorMesh(cParams);
            obj.createBoxMeshes();
            obj.createMeshes();
        end
        
        function computeMesh(obj,levelSet)
            obj.levelSet_background = levelSet;
            obj.computeInteriorMesh(levelSet);
            obj.computeBoxMeshes(levelSet);
            obj.createMeshes();
        end
        
        function M = computeMass(obj)
            Mi = obj.computeInteriorMass();
            Mb = obj.computeBoxMass();
            M = Mi + Mb;
        end
        
        function plot(obj)
            h = figure;
            obj.add2plot(axes(h));
            light
            axis equal off
            hold off
        end
        
        function add2plot(obj,ax)
            obj.meshInterior.add2plot(ax);
            for iActive = 1:obj.nBoxActiveMeshes
                iface = obj.activeBoxFaceMeshesList(iActive);
                obj.boxFaceMeshes{iface}.add2plot(ax,obj.removedDimensions(iface),obj.removedDimensionCoord(iface));
            end
        end
        
        function aMeshes = getActiveMeshes(obj)
            aMeshes = cell(1,obj.nActiveMeshes);
            for iActive = 1:obj.nActiveMeshes
                iMesh = obj.activeMeshesList(iActive);
                aMeshes{iActive} = obj.meshes{iMesh};
            end
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,meshBackground)
            obj.ndim = meshBackground.ndim;
            obj.meshBackground = meshBackground;
            obj.nboxFaces = obj.ndim*obj.nsides;
        end
        
        function createMeshes(obj)
            obj.meshes{1} = obj.meshInterior;
            for iface = 1:obj.nboxFaces
                obj.meshes{iface+1} = obj.boxFaceMeshes{iface};
            end
            obj.nMeshes = numel(obj.meshes);
        end
        
        function createInteriorMesh(obj,cParams)
            obj.meshInterior = Mesh_Unfitted_Single(cParams);
        end
        
        function computeInteriorMesh(obj,levelSet)
            obj.meshInterior.computeMesh(levelSet);
        end
        
        function M = computeInteriorMass(obj)
            M = obj.meshInterior.computeMass();
        end
        
        function createBoxMeshes(obj)
            iface = 0;
            for idime = 1:obj.ndim
                for iside = 1:obj.nsides
                    iface = iface + 1;
                    [boxFaceMesh,nodesInBoxFace] = obj.createBoxFaceMesh(idime,iside);
                    obj.boxFaceMeshes{iface}        = boxFaceMesh;
                    obj.nodesInBoxFaces{iface}      = nodesInBoxFace;
                    obj.globalConnectivities{iface} = obj.computeGlobalConnectivities(nodesInBoxFace,boxFaceMesh);
                end
            end
        end
        
        function connec = computeGlobalConnectivities(obj,nodesInBoxFace,boxFaceMesh)
            nodes = find(nodesInBoxFace);
            boxFaceConnec = boxFaceMesh.meshBackground.connec;
            connec = [nodes(boxFaceConnec(:,1)),nodes(boxFaceConnec(:,2))];
        end
        
        function computeBoxMeshes(obj,levelSet)
            obj.resetBoxMeshes();
            iface = 0;
            obj.isBoxFaceMeshActive = false([1 obj.nboxFaces]);
            for idime = 1:obj.ndim
                for iside = 1:obj.nsides
                    iface = iface + 1;
                    boxFaceMesh = obj.boxFaceMeshes{iface};
                    mshBack = boxFaceMesh.meshBackground;
                    lsBoxFace = levelSet(obj.nodesInBoxFaces{iface});
                    if obj.isBoxMeshActive(lsBoxFace,mshBack)
                        obj.boxFaceMeshes{iface}.computeMesh(lsBoxFace);
                        obj.isBoxFaceMeshActive(iface) = true;
                    end
                end
            end
            obj.updateActiveBoxFaceMeshesList();
        end
        
        function resetBoxMeshes(obj)
            obj.createBoxMeshes();
        end
        
        function M = computeBoxMass(obj)
            M = 0;
            for iactive = 1:obj.nBoxActiveMeshes
                iface = obj.activeBoxFaceMeshesList(iactive);
                M = M + obj.boxFaceMeshes{iface}.computeMass();
            end
        end
        
        function [boxFaceMesh,nodesInBoxFace] = createBoxFaceMesh(obj,idime,iside)
            [mesh,nodesInBoxFace] = obj.createBoxFaceBackgroundMesh(idime,iside);
            interp = Interpolation.create(mesh,'LINEAR');
            cParams = SettingsMeshUnfitted('INTERIOR',mesh,interp);
            boxFaceMesh = Mesh_Unfitted.create2(cParams);
        end
        
        function [mb, nodesInBoxFace] = createBoxFaceBackgroundMesh(obj,idime,iside)
            [boxFaceCoords,nodesInBoxFace] = obj.getFaceCoordinates(idime,iside);
            
            switch obj.ndim
                case 2
                    boxFaceConnec = obj.computeConnectivities(boxFaceCoords);
                case 3
                    boxFaceConnec = obj.computeDelaunay(boxFaceCoords);
            end
            mb = Mesh;
            mb = mb.create(boxFaceCoords,boxFaceConnec);
        end
        
        function [boxFaceCoords, nodesInBoxFace] = getFaceCoordinates(obj,idime,iside)
            D = obj.getFaceCharacteristicDimension(idime,iside);
            nodesInBoxFace = obj.meshBackground.coord(:,idime) == D;
            boxFaceCoords = obj.meshBackground.coord(nodesInBoxFace,:);
            boxFaceCoords = obj.removeExtraDimension(boxFaceCoords,idime);
            obj.storeRemovedDimensions(idime,iside,D);
        end
        
        function indexes = findConnecIndexes(obj,coord_indexes,nnode)
            number_of_valid_nodes_per_element = sum(ismember(obj.meshBackground.connec,coord_indexes),2);
            indexes = number_of_valid_nodes_per_element == nnode;
        end
        
        function D = getFaceCharacteristicDimension(obj,idime,iside)
            if iside == 1
                D = min(obj.meshBackground.coord(:,idime));
            elseif iside == 2
                D = max(obj.meshBackground.coord(:,idime));
            else
                error('Invalid iside value. Valid values: 1 and 2.')
            end
        end
        
        function face_coord = removeExtraDimension(obj,face_coord,idime)
            dimen = 1:obj.ndim;
            face_coord = face_coord(:,dimen(dimen~=idime));
        end
        
        function storeRemovedDimensions(obj,idime,iside,D)
            iface = (idime-1)*obj.nsides + iside;
            obj.removedDimensions(iface) = idime;
            obj.removedDimensionCoord(iface) = D;
        end
        
        function updateActiveBoxFaceMeshesList(obj)
            obj.activeBoxFaceMeshesList = find(obj.isBoxFaceMeshActive);
            obj.activeMeshesList = find([true obj.isBoxFaceMeshActive]);
            obj.nBoxActiveMeshes = length(obj.activeBoxFaceMeshesList);
            obj.nActiveMeshes = length(obj.activeMeshesList);
        end
    end
    
    methods (Static, Access = private)
        
        function itIs = isBoxMeshActive(levelSet,meshBack)
            phi_nodes = levelSet(meshBack.connec);
            phi_case = sum((sign(phi_nodes)<0),2);
            itIs = (any(phi_case));
        end
        
        function face_connec = removeExtraNodes(face_connec_raw,coord_indexes,nnode)
            valid_nodes = ismember(face_connec_raw,coord_indexes);
            
            face_connec = zeros(size(face_connec_raw,1),nnode);
            for i = 1:size(face_connec,1)
                face_connec(i,:) = face_connec_raw(i,valid_nodes(i,:));
            end
        end
        
        function connec = computeDelaunay(coord)
            DT = delaunayTriangulation(coord);
            connec = DT.ConnectivityList;
        end
        
        function connec = computeConnectivities(coord)
            [~,I] = sort(coord);
            connec = [I circshift(I,-1)];
            connec(end,:) = [];
        end
        
    end
    
end

