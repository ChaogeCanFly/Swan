classdef Postprocess_TopOpt < Postprocess
    properties (SetObservable,AbortSet)
        res_file
    end
    
    properties (Access = protected)
        Field
        Iter
    end
    
    methods (Access = public)        

        
        function  print(obj,mesh,results)
            path = pwd;
            dir = fullfile(path,'Output',results.case_file);
            obj.obtainIter(results);
            obj.getField(results);
            if 7~=exist(dir,'dir')
                mkdir(dir)
            end
         %   mesh=obj.setNewMesh(mesh,results); 
            obj.setBasicParams(mesh,results)
            obj.PrintMeshFile(results.iter)
            obj.PrintResFile(results)
        end
        function mesh=setNewMesh(obj,mesh,results)
           % null_nodes=find(results.design_variable<0.2);  
            null_nodes=find(results.design_variable>0);  
            null_elements=any(ismember(mesh.connec,null_nodes)');
            mesh.connec(null_elements,:)=[];
        end
    end
    
    methods (Access = protected)
        function setBasicParams(obj,mesh,results)
            obj.nfields = 1;
            for ifield = 1:obj.nfields
                obj.coordinates{ifield} = mesh.coord;
                obj.connectivities{ifield} = mesh.connec;
                obj.nnode(ifield) = size(mesh.connec,2);
                obj.npnod(ifield) = size(mesh.coord,1);  % Number of nodes
            end
            obj.gtype = mesh.geometryType;
            obj.pdim = mesh.pdim;
            switch obj.pdim
                case '2D'
                    obj.ndim=2;
                case '3D'
                    obj.ndim=3;
            end
            obj.ptype = mesh.ptype;
            
            switch  obj.gtype %gid type
                case 'TRIANGLE'
                    obj.etype = 'Triangle';
                case 'QUAD'
                    obj.etype = 'Quadrilateral';
                case 'TETRAHEDRA'
                    obj.etype = 'Tetrahedra';
                case 'HEXAHEDRA'
                    obj.etype = 'Hexahedra';
            end
            obj.nelem = size(mesh.connec,1); % Number of elements
            obj.gauss_points_name = 'Guass up?';
            
            obj.file_name = results.case_file;
            obj.nsteps = 1;
        end
        
        function PrintMeshFile(obj,iter)
            ifield=1;
            msh_file = fullfile('Output',obj.file_name,strcat(obj.file_name,'_',num2str(iter),'.flavia.msh'));
            obj.fid_mesh = fopen(msh_file,'w');
            obj.printTitle(obj.fid_mesh);
            %                         fprintf(obj.fid_mesh,'Group "%c" \n',mesh_group(ifield));
            fprintf(obj.fid_mesh,'MESH "WORKPIECE" dimension %3.0f   Elemtype %s   Nnode %2.0f \n \n',obj.ndim,obj.etype,obj.nnode);
            fprintf(obj.fid_mesh,'coordinates \n');
            switch obj.pdim
                case '2D'
                    for i = 1:obj.npnod(ifield)
                        fprintf(obj.fid_mesh,'%6.0f %12.5d %12.5d \n',i,obj.coordinates{ifield}(i,1:2));
                    end
                case '3D'
                    for i = 1:obj.npnod(ifield)
                        fprintf(obj.fid_mesh,'%6.0f %12.5d %12.5d %12.5d \n',i,obj.coordinates{ifield}(i,:));
                    end
            end
            fprintf(obj.fid_mesh,'end coordinates \n \n');
            fprintf(obj.fid_mesh,'elements \n');
            switch  obj.gtype
                case 'TRIANGLE'
                    switch obj.nnode(ifield)
                        case 3
                            fprintf(obj.fid_mesh,'%6.0f %6.0f %6.0f %6.0f  1 \n',[1:obj.nelem;obj.connectivities{ifield}']);
                        case 6
                            fprintf(obj.fid_mesh,'%6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f 1 \n',[1:obj.nelem;obj.connectivities{ifield}']);
                        otherwise
                            error('Element type %s with %.0f nodes has not being implemented.',gytpe,obj.nnode(ifield));
                    end
                case 'QUAD'
                    switch obj.nnode(ifield)
                        case 4
                            fprintf(obj.fid_mesh,'%6.0f %6.0f %6.0f %6.0f %6.0f  1 \n',[1:obj.nelem;obj.connectivities{ifield}']);
                        case 8
                            fprintf(obj.fid_mesh,'%6.0f %6.0f %6.0f %6.0f %6.0f  %6.0f %6.0f %6.0f %6.0f 1 \n',[1:obj.nelem;obj.connectivities{ifield}']);
                        case 9
                            fprintf(obj.fid_mesh,'%6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f 1 \n',[1:obj.nelem;obj.connectivities{ifield}']);
                        otherwise
                            error('Element type %s with %.0f nodes has not being implemented.',gytpe,obj.nnode(ifield));
                    end
                case 'TETRAHEDRA'
                    switch obj.nnode(ifield)
                        case 4
                            fprintf(obj.fid_mesh,'%6.0f %6.0f %6.0f %6.0f %6.0f  1 \n',[1:obj.nelem;obj.connectivities{ifield}']);
                        otherwise
                            error('Element type %s with %.0f nodes has not being implemented.',gytpe,obj.nnode(ifield));
                    end
                case 'HEXAHEDRA'
                    switch obj.nnode(ifield)
                        case 8
                            fprintf(obj.fid_mesh,'%6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f  1 \n',[1:obj.nelem;obj.connectivities{ifield}']);
                        otherwise
                            error('Element type %s with %.0f nodes has not being implemented.',gytpe,obj.nnode(ifield));
                    end
                otherwise
                    error('Element type %s has not being implemented.',gytpe,obj.nnode(ifield));
            end
            
            fprintf(obj.fid_mesh,'end elements\n\n');
            %                         fprintf(obj.fid_mesh,'end group \n');
            fclose(obj.fid_mesh);
        end
        
        function PrintResFile(obj,results)
            FileName = fullfile('Output',obj.file_name,strcat(obj.file_name,'_',num2str(results.iter),'.flavia.res'));
            obj.fid_res = fopen(FileName,'w');
            obj.Write_header_res_file()
            obj.PrintResults()
            fclose(obj.fid_res);
            obj.res_file = FileName;
        end
    end
    
    
    methods (Access = private)        
        function obtainIter(obj,results)
            obj.Iter = results.iter;
        end        
    end
    
    methods (Static)
        function obj = Create(optimizer)
            switch optimizer
                case {'SLERP','PROJECTED SLERP', 'HAMILTON-JACOBI'}
                    obj = Postprocess_TopOpt_levelSet;
                case {'PROJECTED GRADIENT', 'MMA', 'IPOPT'}
                    obj = Postprocess_TopOpt_density;
            end
        end
    end
end
