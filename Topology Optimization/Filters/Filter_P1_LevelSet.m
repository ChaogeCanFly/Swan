classdef Filter_P1_LevelSet < Filter_P1
    properties
        quadrature
        geometry        
        quadrature_del
        interp_del
        shape_full
    end
    methods    
        function obj = Filter_P1_LevelSet(problemID,scale)
            obj@Filter_P1(problemID,scale);
        end
        function preProcess(obj)
            preProcess@Filter_P1(obj)
            obj.quadrature = Quadrature.set(obj.diffReacProb.geometry.type);
            mesh=obj.diffReacProb.mesh;
            obj.geometry= Geometry(mesh,'LINEAR');    
            mesh_del=mesh; 
            switch mesh.pdim
                case '2D'
                    mesh_del.geometryType='TRIANGLE';
                    obj.quadrature_del=Quadrature_Triangle;
                    obj.quadrature_del.computeQuadrature('LINEAR');
                    obj.interp_del=Triangle_Linear(mesh_del);
                    obj.interp_del.computeShapeDeriv(obj.quadrature_del.posgp)
                case '3D'
                    mesh_del.geometryType='TETRAHEDRA';
                    obj.quadrature_del=Quadrature_Tetrahedra;
                    obj.quadrature_del.computeQuadrature('LINEAR');
                    obj.interp_del=Tetrahedra(mesh_del);
                    obj.interp_del.computeShapeDeriv(obj.quadrature_del.posgp)                    
            end   
            obj.initGeometry
            obj.shape_full=obj.integrateFull;
        end
        function x_gp = getP0fromP1(obj,x)
            if norm(x) == norm(obj.x)
                x_gp=obj.x_reg;
            else
                %M2=obj.faireF2(obj.coordinates',obj.connectivities',x);
                % x_gp = obj.P_operator*M2;
                obj.x=x;
                
                M2=obj.computeDelaunay(x);
                x_gp = obj.P_operator*M2;
                obj.x_reg=x_gp;
            end
        end
        function initGeometry(obj)
            obj.quadrature.computeQuadrature('LINEAR');
            obj.geometry.interpolation.computeShapeDeriv(obj.quadrature.posgp)
            obj.geometry.computeGeometry(obj.quadrature,obj.geometry.interpolation);
        end
        function [full_elem,cut_elem]=findCases(obj,x)
            phi_nodes=x(obj.connectivities);
            phi_case=sum((sign(phi_nodes)<0),2);
            
            full_elem = phi_case==size(obj.connectivities,2);
            null_elem = phi_case==0;
            indexes = (1:size(obj.connectivities,1))';
            cut_elem = indexes(~(full_elem+null_elem));
        end
        function shape=integrateFull(obj)
            shape=zeros(size(obj.connectivities,1),size(obj.connectivities,2));
            for igauss=1:size(obj.geometry.interpolation.shape,2)
                shape=shape+obj.geometry.interpolation.shape(:,igauss)'.*obj.geometry.dvolu(:,igauss);
            end
        end
        function [P,active_nodes]=findCrossPoints(obj,x,cut_elem)
            switch obj.diffReacProb.mesh.pdim
                case '2D'
                    gamma_1=permute(x(obj.connectivities(cut_elem,:)),[2 3 1]);
                    gamma_2=permute([x(obj.connectivities(cut_elem,2:end)),x(obj.connectivities(cut_elem,1))],[2 3 1]);
                    P1=repmat(obj.geometry.interpolation.pos_nodes,[1 1 size(cut_elem)]);
                    P2=repmat([obj.geometry.interpolation.pos_nodes(2:end,:);obj.geometry.interpolation.pos_nodes(1,:)],[1 1 size(cut_elem)]);
                    P=P1+gamma_1.*(P2-P1)./(gamma_1-gamma_2);
                    active_nodes = sign(gamma_1) ~= sign(gamma_2);
                case '3D'
                    iteration_1=[1 1 1 2 2 3];
                    iteration_2=[2 3 4 3 4 4];
                    gamma_1=permute(x(obj.connectivities(cut_elem,iteration_1)),[2 3 1]);
                    gamma_2=permute(x(obj.connectivities(cut_elem,iteration_2)),[2 3 1]);
                    P1=repmat(obj.geometry.interpolation.pos_nodes(iteration_1,:),[1 1 size(cut_elem)]);
                    P2=repmat(obj.geometry.interpolation.pos_nodes(iteration_2,:),[1 1 size(cut_elem)]);
                    P=P1+gamma_1.*(P2-P1)./(gamma_1-gamma_2);
                    active_nodes = sign(gamma_1) ~= sign(gamma_2);
            end
        end
        function A=computeDvoluCut(obj,elcrd)
            switch obj.diffReacProb.mesh.pdim
                case '2D'
                    x1 = elcrd(:,1,1); y1 = elcrd(:,1,2); x2 = elcrd(:,2,1); y2 = elcrd(:,2,2); x3 = elcrd(:,3,1); y3 = elcrd(:,3,2);
                    A = 0.5*abs((x2-x1).*(y3-y1)-(x3-x1).*(y2-y1));
                case '3D'
                    x1 = elcrd(:,1,1); y1 = elcrd(:,1,2); z1=elcrd(:,1,3);
                    x2 = elcrd(:,2,1); y2 = elcrd(:,2,2); z2=elcrd(:,2,3);
                    x3 = elcrd(:,3,1); y3 = elcrd(:,3,2); z3=elcrd(:,3,3);
                    x4 = elcrd(:,4,1); y4 = elcrd(:,4,2); z4=elcrd(:,4,3);
                    J=x1.*y3.*z2-x1.*y2.*z3+x2.*y1.*z3-x2.*y3.*z1-x3.*y1.*z2+x3.*y2.*z1+x1.*y2.*z4-x1.*y4.*z2-x2.*y1.*z4+x2.*y4.*z1+...
                    x4.*y1.*z2-x4.*y2.*z1-x1.*y3.*z4+x1.*y4.*z3+x3.*y1.*z4-x3.*y4.*z1-x4.*y1.*z3+x4.*y3.*z1+x2.*y3.*z4-x2.*y4.*z3...
                    -x3.*y2.*z4+x3.*y4.*z2+x4.*y2.*z3-x4.*y3.*z2;
                    A=J/6;
            end
        end
        function shape_all=integrateCut(obj,phi_cut, global_connec, A, shape_all)
            notcompute = phi_cut > 0;
            isnegative = ~any(notcompute');
            dvolu=sum(obj.geometry.dvolu,2)/obj.geometry.interpolation.dvolu;
            v=isnegative'.*(obj.geometry.interpolation.shape'.*A.*dvolu(global_connec));
            for idelaunay=1:size(v,2)
                shape_all(:,idelaunay)=shape_all(:,idelaunay)+accumarray(global_connec,v(:,idelaunay),[obj.nelem,1],@sum,0);
            end
        end
        function pos_gp_del_natural=computeDelGaussNatural(obj,elcrd)
            switch obj.diffReacProb.mesh.pdim
                case '2D'
                    pos_gp_del_natural=[elcrd(:,:,1)*obj.interp_del.shape,elcrd(:,:,2)*obj.interp_del.shape];
                case '3D'
                    pos_gp_del_natural=[elcrd(:,:,1)*obj.interp_del.shape,elcrd(:,:,2)*obj.interp_del.shape,elcrd(:,:,3)*obj.interp_del.shape];     
            end
        end        
        function M2=computeDelaunay(obj,x)            
            [full_elem,cut_elem]=obj.findCases(x);
            shape_all=zeros(size(obj.connectivities,1),size(obj.connectivities,2));
            shape_all(full_elem,:)=obj.shape_full(full_elem,:);
            if ~isempty(cut_elem)
                [P,active_nodes]=obj.findCrossPoints(x,cut_elem);
                elecoord=[];phi_cut=[];global_connec=[];
                for ielem=1:length(cut_elem)
                    del_coord = [obj.geometry.interpolation.pos_nodes;P(active_nodes(:,:,ielem),:,ielem)];
                    del_x=[x(obj.connectivities(cut_elem(ielem),:));zeros(size(P(active_nodes(:,:,ielem)),1),1)];
                    DT=delaunayTriangulation(del_coord);
                    del_connec=DT.ConnectivityList;
                    for idelaunay=1:size(del_connec,1)
                        elecoord=[elecoord;permute(del_coord(del_connec(idelaunay,:),:)',[3 2 1])];
                        phi_cut =[phi_cut;del_x(del_connec(idelaunay,:))'];
                    end
                    global_connec=[global_connec;repmat(cut_elem(ielem),[size(del_connec,1) 1])];
                end
                dvolu_cut=obj.computeDvoluCut(elecoord);
                pos_gp_del_natural=obj.computeDelGaussNatural(elecoord);                
                obj.geometry.interpolation.computeShapeDeriv(pos_gp_del_natural');                
                shape_all=obj.integrateCut(phi_cut, global_connec, dvolu_cut, shape_all);
            end
            M2=zeros(obj.npnod,1);
            for inode=1:obj.nnode
                p = obj.connectivities(:,inode);
                M2 = M2+accumarray(p,shape_all(:,inode),[obj.npnod,1],@sum,0);
            end
        end
    end
end

%                                         figure(3)
%                                         hold on
%                                         x_global=coord(connec(cut_elem(ielem),:)',1);
%                                         y_global=coord(connec(cut_elem(ielem),:)',2);
%                                         for i=1:size(x_global,1)
%                                             vec=[i;i+1];
%                                             if i+1 > size(x_global,1)
%                                                 vec(2)=1;
%                                             end
%                                             plot(x_global(vec,:),y_global(vec,:),'b')
%                                         end
%                     
%                                         for idel=1:size(delaunay_connec,1)
%                                             x_delaunay=mesh_del.coord(delaunay_connec(idel,:)',1);
%                                             y_delaunay=mesh_del.coord(delaunay_connec(idel,:)',2);
%                                             for i=1:size(x_delaunay,1)
%                                                 vec=[i;i+1];
%                                                 if i+1 > size(x_delaunay,1)
%                                                     vec(2)=1;
%                                                 end
%                                                 hold on
%                                                 plot(x_delaunay(vec,:),y_delaunay(vec,:),'-r')
%                     
%                                                 drawnow
%                                             end
%                                         end
%                                         text(x_global,y_global,num2str(x(connec(cut_elem(ielem),:)')))
%                                         %title(num2str(phi(cut_elem(ielem))))
%                                         close (3)