%% TOP OPT TEST ===========================================================

clear; close all;

fprintf('Running TopOpt tests...\n')

%% Test Declaration -------------------------------------------------------
tests_topopt = {'test_micro','test_cantilever','test_cantilever2','test_projected_slerp','test_cantilever3','test_gripping','test_bridge','test_micro2','test_bridge2'};
% tests_topopt = {'test_cantilever3','test_gripping','test_bridge','test_micro2','test_bridge2'};
% tests_topopt = {'test_bridge','test_micro2','test_bridge2'};

% tic
%% Run Top Opt Tests ------------------------------------------------------
for i = 1:length(tests_topopt)
    clearvars -except tests_topopt i
    %tic
    file_name = tests_topopt{i};
    file_name_in = strcat('./Input/',tests_topopt{i});
    settings = Settings(file_name_in);
    load_file = strcat('./tests/',file_name);
    load(load_file)
    
    obj = TopOpt_Problem(settings);
    obj.preProcess;
    obj.computeVariables;
    error = norm(obj.x - x)/norm(x);
    if error < 1e-9
        cprintf('green',strcat(file_name,' PASSED.  Error: ',num2str(error),'\n'));
    else
        cprintf('err',strcat(file_name,' FAILED. Error: ',num2str(error),'\n'));
    end
    %toc
    clear settings
end

fprintf('\nTopOpt tests completed.\n')
fprintf('\n-------------------------------------------\n\n')

test2dFourquad
testStiffnessMatrixGenerator
HomogenizationTests
% toc