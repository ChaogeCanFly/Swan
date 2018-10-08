%% INTEGRATION TEST =======================================================

clear; close all;

fprintf('Running TopOpt tests...\n')

%% Test Declaration -------------------------------------------------------

tests_integration = {'test_circle_triangle','test_circle_quadrilateral','test_sphere_tetrahedra','test_sphere_hexahedra'};
% tests_integration = {'test_sphere_tetrahedra','test_sphere_hexahedra'};

%% Run Integration Opt Tests ----------------------------------------------
for i = 1:length(tests_integration)
    clearvars -except tests_integration i
%     tic
    file_name = tests_integration{i};
    file_name_in = strcat('./Input/',tests_integration{i});
    settings = Settings(file_name_in);
    load_file = strcat('./tests/',file_name);
    load(load_file)
    
    obj = TopOpt_Problem(settings);
    obj.preProcess;
    x = obj.x;
    
    filter = Filter.create(obj.settings);
    filter.preProcess;
    A = filter.IntegrateFacets(x);
    A_star = A/A0;
    errorSurf = (A_star - A_star_ref)/A_star_ref;
    if abs(errorSurf) < 1e-9
        cprintf('green',strcat(file_name,' PASSED.  Surface Error: ',num2str(errorSurf),'\n'));
    else
        cprintf('err',strcat(file_name,' FAILED. Surface Error: ',num2str(errorSurf),'\n'));
    end
    
    V = filter.IntegrateInteriorCells(x);
    V_star = V/V0;
    errorVol= (V_star - V_star_ref)/V_star_ref;
    if abs(errorVol) < 1e-9
        cprintf('green',strcat(file_name,' PASSED.  Volume Error: ',num2str(errorVol),'\n'));
    else
        cprintf('err',strcat(file_name,' FAILED. Volume Error: ',num2str(errorVol),'\n'));
    end

%     toc
    clear settings
end

fprintf('\nTopOpt tests completed.\n')
fprintf('\n-------------------------------------------\n\n')