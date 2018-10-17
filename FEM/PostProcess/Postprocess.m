classdef Postprocess < handle
    properties
        nnode
        ngaus
        posgp
        gauss_points_name
        ndim
        pdim
        gtype
        etype
        ptype
        nelem
        npnod
        coordinates
        connectivities
        fid_mesh
        fid_res
        file_name
        nsteps
        nfields
    end
    
    methods (Access = protected)
        function setBasicParams(obj,physical_problem,file_name,results)
            obj.nfields = physical_problem.element.nfields;
            for ifield = 1:obj.nfields
                obj.coordinates{ifield} = physical_problem.element.interpolation_u(ifield).xpoints;
                obj.connectivities{ifield} = physical_problem.element.interpolation_u(ifield).T;
                obj.nnode(ifield) = physical_problem.element(ifield).nnode;
                obj.npnod(ifield) = physical_problem.element.interpolation_u(ifield).npnod;  % Number of nodes
            end
            obj.gtype = physical_problem.mesh.geometryType;
            obj.ndim = physical_problem.element.interpolation_u.ndime;
            obj.pdim = physical_problem.mesh.pdim;
            obj.ngaus = physical_problem.element(1).quadrature.ngaus;
            obj.posgp = physical_problem.element(1).quadrature.posgp';
            obj.ptype = physical_problem.mesh.ptype;
            
            switch  obj.gtype % GiD type
                case 'TRIANGLE'
                    obj.etype = 'Triangle';
                case 'QUAD'
                    obj.etype = 'Quadrilateral';
                case 'TETRAHEDRA'
                    obj.etype = 'Tetrahedra';
                case 'HEXAHEDRA'
                    obj.etype = 'Hexahedra';
            end
            obj.nelem = physical_problem.element.nelem; % Number of elements
            
            obj.gauss_points_name = 'Guass up?';
            
            obj.file_name = file_name;
            switch obj.ptype
                case 'ELASTIC'
                    obj.nsteps = 1;
                case 'Stokes'
                    obj.nsteps = length(results.physicalVars.u(1,:));
            end
        end
        
        function PrintVector(obj,nameres,indexName,problemType,result_type,result_location,location_name,results,istep)
            % Print Header ------------------------------------------------
            fprintf(obj.fid_res,'\nResult "%s" "%s" %.0f %s %s "%s"\n',nameres,problemType,istep,result_type,result_location,location_name);
            switch obj.ndim
                case 2
                    fprintf(obj.fid_res,'ComponentNames  "%sx", "%sy"\n',indexName,indexName);
                case 3
                    fprintf(obj.fid_res,'ComponentNames "%sx", "%sy", "%sz"\n',indexName,indexName,indexName);
                otherwise
                    error('Invalid value of parametre ndime.')
            end
            
            % Print Variables ---------------------------------------------
            fprintf(obj.fid_res,'Values\n');
            for inode = 1:round(length(results)/obj.ndim)
                fprintf(obj.fid_res,'%6.0f ',inode);
                for idime = 1:obj.ndim
                    fprintf(obj.fid_res,'%12.5d ',results(obj.ndim*(inode-1)+idime));
                end
                fprintf(obj.fid_res,'\n');
            end
            fprintf(obj.fid_res,'End Values\n');
        end
        function PrintTensor(obj,nameres,indexName,problemType,result_type,result_location,location_name,results,istep)
            % Print Header ------------------------------------------------
            fprintf(obj.fid_res,'\nResult "%s" "%s" %.0f %s %s "%s"\n',nameres,problemType,istep,result_type,result_location,location_name);
            switch obj.ndim
                case 2
                    fprintf(obj.fid_res,'ComponentNames  "%sx", "%sy", "%sxy", "%sz"\n',indexName,indexName,indexName,indexName);
                case 3
                    fprintf(obj.fid_res,'ComponentNames "%sx", "%sy", "%sz", "%sxy", "%syz", "%sxz"\n',indexName,indexName,indexName,indexName);
                otherwise
                    error('Invalid value of parametre ndime.')
            end
            
            % Print Variables ---------------------------------------------
            fprintf(obj.fid_res,'Values\n');
            for ielem = 1:size(results,3)
                fprintf(obj.fid_res,'%6.0f ',ielem);
                for igaus = 1:size(results,1)
                    for istre = 1:size(results,2)
                        fprintf(obj.fid_res,'%12.5d ',results(igaus,istre,ielem));
                    end
                    fprintf(obj.fid_res,'\n');
                end
            end
            fprintf(obj.fid_res,'End Values\n');
        end
        
        function PrintScalar(obj,nameres,indexName,problemType,result_type,result_location,location_name,results,istep)
            % Print Header ------------------------------------------------
            
            fprintf(obj.fid_res,'\nResult "%s" "%s" %.0f %s %s "%s"\n',nameres,problemType,istep,result_type,result_location,location_name);
            fprintf(obj.fid_res,'ComponentNames  "%s"\n',indexName);
            
            % Print Variables ---------------------------------------------
            fprintf(obj.fid_res,'Values\n');
            for inode = 1:length(results)
                fprintf(obj.fid_res,'%6.0f ',inode);
                fprintf(obj.fid_res,'%12.5d ',results(inode));
                fprintf(obj.fid_res,'\n');
            end
            fprintf(obj.fid_res,'End Values\n');
        end
        
        function Write_header_res_file(obj)            
            %% File Header
            fprintf(obj.fid_res,'GiD Post Results File 1.0\n\n');
            obj.printTitle(obj.fid_res);
        end
        
        function PrintGaussPointsHeader(obj)
            fprintf(obj.fid_res,'GaussPoints "%s" Elemtype %s\n',obj.gauss_points_name,obj.etype);
            fprintf(obj.fid_res,'Number of Gauss Points: %.0f\n',obj.ngaus);
            fprintf(obj.fid_res,'Nodes not included\n');
            fprintf(obj.fid_res,'Natural Coordinates: given\n');
            for igaus = 1:obj.ngaus
                for idime = 1:obj.ndim
                    fprintf(obj.fid_res,'%12.5d ',obj.posgp(igaus,idime));
                end
                fprintf(obj.fid_res,'\n');
            end
            fprintf(obj.fid_res,'End GaussPoints\n');
        end
         
        function PrintMeshFile(obj)
            for istep = 1:obj.nsteps
                mesh_group = ['u' 'p'];
                for ifield = 1:obj.nfields
                    msh_file = fullfile('Output',obj.file_name,strcat(obj.file_name,'_',mesh_group(ifield),'_',num2str(istep),'.flavia.msh'));
                    obj.fid_mesh = fopen(msh_file,'w');
                    obj.printTitle(obj.fid_mesh);
                    %                         fprintf(obj.fid_mesh,'Group "%c" \n',mesh_group(ifield));
                    fprintf(obj.fid_mesh,'MESH "WORKPIECE" dimension %3.0f   Elemtype %s   Nnode %2.0f \n \n',obj.ndim,obj.etype,obj.nnode(ifield));
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
            end
        end
        
        function PrintResFile(obj,results)
            for istep = 1:obj.nsteps
                mesh_group = ['u' 'p'];
                for ifield = 1:obj.nfields
                    res_file = fullfile('Output',obj.file_name,strcat(obj.file_name,'_',mesh_group(ifield),'_',num2str(istep),'.flavia.res'));
                    obj.fid_res = fopen(res_file,'w');
                    obj.Write_header_res_file
                    obj.Print_results(results,ifield,istep)
                    fclose(obj.fid_res);
                end
            end
        end
    end
    
    % methods (Abstract, Access = public)
    %      Print_results(obj);
    % end
    
    methods (Access = protected, Static)
        function printTitle(fid)
            fprintf(fid,'####################################################\n');
            fprintf(fid,'################# FEM-MAT-OO v.1.0 #################\n');
            fprintf(fid,'####################################################\n');
            fprintf(fid,'\n');
        end
    end
    
    methods (Access = public)
        function  print(obj,physical_problem,file_name,physicalVars)
            results.physicalVars = physicalVars;
            path = pwd;
            dir = fullfile(path,'Output',file_name);
            if ~exist(dir,'dir')
                mkdir(dir)
            end
            obj.setBasicParams(physical_problem,file_name,results)
            obj.PrintMeshFile
            obj.PrintResFile(results)
        end
        
        function print_slave(obj,physical_problem,res_file,physicalVars)
            results.physicalVars = physicalVars;
            obj.setBasicParams(physical_problem,'',results)
            obj.fid_res = fopen(res_file,'a');
            obj.Print_results(results,1,1)
            fclose(obj.fid_res);
        end
    end
end

