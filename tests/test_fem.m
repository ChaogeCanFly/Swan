clear all; close all; clc
%% TEST
% -

% Load the results for 2-d and 3-d tests
tests_fem={'test2d_triangle';
    'test2d_quad';
    'test2d_stokes_triangle';
    'test3d_hexahedra';
    'test3d_tetrahedra'};

%% FEM TESTS
for i=1:length(tests_fem)
    file_name = tests_fem{i};
    file_name_in = strcat('./Input/',tests_fem{i});
    
    load_file = strcat('./tests/',file_name);
    load(load_file)
    obj = Physical_Problem(file_name);
    obj.preProcess;
    obj.computeVariables;
    if strcmp(obj.mesh.ptype,'ELASTIC')
        if sum(abs(obj.variables.d_u - d_u)) < 1e-6
            disp(strcat(file_name,' PASSED'));
        else
            disp(strcat(file_name,' FAILED'));
        end
    else
        if sum(abs(obj.variables.u - variable.u)) < 1e-6 && sum(abs(obj.variables.p - variable.p)) < 1e-6
            disp(strcat(file_name,' PASSED'));
        else
            disp(strcat(file_name,' FAILED'));
        end
    end
end
