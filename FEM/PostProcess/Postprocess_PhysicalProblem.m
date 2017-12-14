classdef Postprocess_PhysicalProblem < Postprocess
    
    properties
    end
    
    methods (Access = protected)
        % Export Results
        function ToGiDpost(obj,file_name,istep)
            % Write the file with the results
            [fid,ndim,gauss_points_name] = obj.write_header_res_file(file_name,istep);
            
            %% Print Results
           obj.PrintVector(fid,ndim,'Displacements','U','Elastic Problem','Vector',istep,'OnNodes','',obj.physical_problem.variables.d_u);
           obj.PrintTensor(fid,ndim,'Stress','S','Elastic Problem','Vector',istep,'OnGaussPoints',gauss_points_name,obj.physical_problem.variables.stress);
           obj.PrintTensor(fid,ndim,'Strain','E','Elastic Problem','Vector',istep,'OnGaussPoints',gauss_points_name,obj.physical_problem.variables.strain);
          fclose(fid);
        end
        
        
    end
    
    methods (Access = public)
        function obj = Postprocess_PhysicalProblem(results)
            obj.physical_variables = results;
        end
        
        
        function Print_make_video_stress(obj,gidPath,file_name,files_folder,iterations_to_print,output_video_name)
            file_tcl_name = 'tcl_gid.tcl';
            field2print = 'Stress';
            componentfield = 'S';
            file_list = obj.create_file_list(iterations_to_print,file_name,files_folder);
            file_tcl_name_with_path = fullfile(files_folder,file_tcl_name);
            fid = fopen(file_tcl_name_with_path,'w+');
            fprintf(fid,'GiD_Process PostProcess \n');
            fprintf(fid,['set arg1 "',file_list,'"\n']);
            fprintf(fid,['set arg2 "',output_video_name,'"\n']);
            fprintf(fid,['set arg3 "',field2print,'"\n']);
            fprintf(fid,['set arg4 "',componentfield,'"\n']);
            fprintf(fid,['source "',fullfile(pwd,'FEM','PostProcess','Make_Video_stress.tcl'),'"\n']);
            fprintf(fid,['Make_Video_stress $arg1 $arg2 $arg3 $arg4 \n']);
            fprintf(fid,['GiD_Process Mescape Quit']);
            fclose(fid);
            
            obj.execute_tcl_files(gidPath,file_tcl_name_with_path)
        end
        
        
        
    end
end

