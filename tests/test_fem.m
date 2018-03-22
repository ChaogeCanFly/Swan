%% FEM TEST ===============================================================

clear; close all;

fprintf('Running FEM tests...\n')

%% Test Declaration -------------------------------------------------------
% Load the results for 2-d and 3-d tests
tests_fem = {'test2d_triangle';
    'test2d_quad';
    'test2d_stokes_triangle';
    'test2d_micro';
    'test3d_tetrahedra';
    'test3d_hexahedra'
    };

%% Run FEM Tests ----------------------------------------------------------
for i=1:length(tests_fem)
    file_name = tests_fem{i};
    file_name_in = strcat('./Input/',tests_fem{i});
    
    load_file = strcat('./tests/',file_name);
    load(load_file);
    
    obj = FEM.create(file_name);
    if obj.mesh.scale == 'MACRO'
        obj.preProcess;
        obj.computeVariables;
        if strcmp(obj.mesh.ptype,'ELASTIC')
            if sum(abs(obj.variables.d_u - d_u)) < 1e-6
                cprintf('green',strcat(file_name,' PASSED\n'));
            else
                cprintf('err',strcat(file_name,' FAILED\n'));
            end
        else
            if sum(abs(obj.variables.u - variable.u)) < 1e-6 && sum(abs(obj.variables.p - variable.p)) < 1e-6
                cprintf('green',strcat(file_name,' PASSED\n'));
            else
                cprintf('err',strcat(file_name,' FAILED\n'));
            end
        end
    else
        obj = Elastic_Problem_Micro(file_name);
        obj.preProcess;
        obj.computeChomog;
        if sum(abs(obj.variables.Chomog- Chomog)) < 1e-6
            cprintf('green',strcat(file_name,' PASSED\n'));
        else
            cprintf('err',strcat(file_name,' FAILED\n'));
        end
    end
end

fprintf('\nFEM tests completed.\n')
fprintf('\n-------------------------------------------\n\n')
