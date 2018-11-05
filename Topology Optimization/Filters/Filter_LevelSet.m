classdef Filter_LevelSet < Filter
    properties (Access = public)
        unfitted_mesh
    end
    
    properties (Access = protected)
        quadrature_unfitted
        interpolation_unfitted
    end
    
    properties (Access = protected) % !! TO REMOVE !!
        max_subcells
        nnodes_subelem
        ndim
    end
    
    methods (Abstract)
        createUnfittedMesh(obj)
        setInterpolation_Unfitted(obj)
    end
    
    methods (Access = public)
        function preProcess(obj)
            preProcess@Filter(obj);
            
            obj.setQuadrature_Unfitted;
            obj.createUnfittedMesh;
            obj.setInterpolation_Unfitted;
            
            MSGID = 'MATLAB:delaunayTriangulation:DupPtsWarnId';
            warning('off', MSGID)
        end
        
        function shapeValues = integrateFoverMesh(obj,F1)
            subcells_posgp_iso = obj.computePosGP(obj.unfitted_mesh.coord_iso_per_cell,obj.interpolation_unfitted,obj.quadrature_unfitted);
            
            shapeValues = zeros(size(obj.unfitted_mesh.connec,1),obj.nnode);
            for isubcell = 1:size(obj.unfitted_mesh.connec,1) % !! VECTORIZE THIS LOOP !!
                icell = obj.unfitted_mesh.cell_containing_subcell(isubcell);
                inode = obj.mesh.connec(icell,:);
                
                obj.interpolation.computeShapeDeriv(subcells_posgp_iso(:,:,isubcell)');
                
                djacob = obj.mapping(obj.unfitted_mesh.coord(obj.unfitted_mesh.connec(isubcell,:),:),obj.interpolation_unfitted.dvolu); % !! Could be done through Geometry class?? !!
                
                F0 = (obj.interpolation.shape*obj.quadrature_unfitted.weigp')'*F1(inode)/obj.interpolation_unfitted.dvolu;
                shapeValues(isubcell,:) = shapeValues(isubcell,:) + (obj.interpolation.shape*(djacob.*obj.quadrature_unfitted.weigp')*F0)';
            end
        end
    end
    
    methods (Access = protected)
        function M2 = rearrangeOutputRHS(obj,shape_all)
            M2 = zeros(obj.npnod,1);
            for inode = 1:obj.nnode
                M2 = M2 + accumarray(obj.mesh.connec(:,inode),shape_all(:,inode),[obj.npnod,1],@sum,0);
            end
        end
    end
    
    methods (Access = private)
        function setQuadrature_Unfitted(obj)
            obj.quadrature_unfitted = obj.getQuadrature_Unfitted;
            obj.quadrature_unfitted.computeQuadrature('LINEAR');
        end
    end
    
    methods (Static, Access = protected)
        function [full_elem,cut_elem] = findCutElements(x,connectivities) % !! TO REMOVE !!
            phi_nodes = x(connectivities);
            phi_case = sum((sign(phi_nodes)<0),2);
            
            full_elem = phi_case==size(connectivities,2);
            null_elem = phi_case==0;
            indexes = (1:size(connectivities,1))';
            cut_elem = indexes(~(full_elem+null_elem));
        end
        
        function posgp = computePosGP(subcell_coord,interpolation,quadrature)
            interpolation.computeShapeDeriv(quadrature.posgp);
            posgp = zeros(quadrature.ngaus,size(subcell_coord,3),size(subcell_coord,1));
            for igaus = 1:quadrature.ngaus
                for idime = 1:size(subcell_coord,3)
                    posgp(igaus,idime,:) = subcell_coord(:,:,idime)*interpolation.shape(:,igaus);
                end
            end
        end
    end
    
    methods (Static, Access = public)
        function [F,aire] = faireF2(p,t,psi)
            np = size(p,2); nt = size(t,2);
            F = zeros(np,1);
            p1 = t(1,:); p2 = t(2,:); p3 = t(3,:);
            x1 = p(1,p1); y1 = p(2,p1); x2 = p(1,p2); y2 = p(2,p2); x3 = p(1,p3); y3 = p(2,p3);
            A = 0.5*abs((x2-x1).*(y3-y1)-(x3-x1).*(y2-y1));
            
            beta = (psi<0);
            beta = pdeintrp(p,t,beta);
            k = find(beta>0.5);
            F = F+accumarray(p1(k)',A(k)/3',[np,1],@sum,0);
            F = F+accumarray(p2(k)',A(k)/3',[np,1],@sum,0);
            F = F+accumarray(p3(k)',A(k)/3',[np,1],@sum,0);
            aire = sum(A(k));
            
            k = find(abs(beta-1/3)<0.01);
            p1 = t(1,k); p2 = t(2,k); p3 = t(3,k);
            psi1 = psi(p1)'; psi2 = psi(p2)'; psi3 = psi(p3)';
            [psis,is] = sort([psi1;psi2;psi3],1);
            is = is+3*ones(3,1)*[0:length(k)-1];
            pl = [p1;p2;p3]; ps = pl(is);
            x1 = p(1,ps(1,:)); y1 = p(2,ps(1,:)); x2 = p(1,ps(2,:)); y2 = p(2,ps(2,:)); x3 = p(1,ps(3,:)); y3 = p(2,ps(3,:));
            x12 = (psis(1,:).*x2-psis(2,:).*x1)./(psis(1,:)-psis(2,:));
            y12 = (psis(1,:).*y2-psis(2,:).*y1)./(psis(1,:)-psis(2,:));
            x13 = (psis(1,:).*x3-psis(3,:).*x1)./(psis(1,:)-psis(3,:));
            y13 = (psis(1,:).*y3-psis(3,:).*y1)./(psis(1,:)-psis(3,:));
            A = 0.5*abs(((x12-x1).*(y13-y1)-(x13-x1).*(y12-y1)));
            F = F+accumarray(ps(1,:)',((1+psis(2,:)./(psis(2,:)-psis(1,:))+psis(3,:)./(psis(3,:)-psis(1,:))).*A/3)',[np,1],@sum,0);
            F = F+accumarray(ps(2,:)',((psis(1,:)./(psis(1,:)-psis(2,:))).*A/3)',[np,1],@sum,0);
            F = F+accumarray(ps(3,:)',((psis(1,:)./(psis(1,:)-psis(3,:))).*A/3)',[np,1],@sum,0);
            aire = aire+sum(A);
            
            k = find(abs(beta-2/3)<0.01);
            p1 = t(1,k); p2 = t(2,k); p3 = t(3,k);
            psi1 = psi(p1)'; psi2 = psi(p2)'; psi3 = psi(p3)';
            [psis,is] = sort([psi1;psi2;psi3],1,'descend');
            is = is+3*ones(3,1)*[0:length(k)-1];
            pl = [p1;p2;p3]; ps = pl(is);
            x1 = p(1,ps(1,:)); y1 = p(2,ps(1,:)); x2 = p(1,ps(2,:)); y2 = p(2,ps(2,:)); x3 = p(1,ps(3,:)); y3 = p(2,ps(3,:));
            x12 = (psis(1,:).*x2-psis(2,:).*x1)./(psis(1,:)-psis(2,:));
            y12 = (psis(1,:).*y2-psis(2,:).*y1)./(psis(1,:)-psis(2,:));
            x13 = (psis(1,:).*x3-psis(3,:).*x1)./(psis(1,:)-psis(3,:));
            y13 = (psis(1,:).*y3-psis(3,:).*y1)./(psis(1,:)-psis(3,:));
            A = 0.5*abs(((x12-x1).*(y13-y1)-(x13-x1).*(y12-y1)));
            F = F-accumarray(ps(1,:)',((1+psis(2,:)./(psis(2,:)-psis(1,:))+psis(3,:)./(psis(3,:)-psis(1,:))).*A/3)',[np,1],@sum,0);
            F = F-accumarray(ps(2,:)',((psis(1,:)./(psis(1,:)-psis(2,:))).*A/3)',[np,1],@sum,0);
            F = F-accumarray(ps(3,:)',((psis(1,:)./(psis(1,:)-psis(3,:))).*A/3)',[np,1],@sum,0);
            aire = aire-sum(A);
        end
    end
end