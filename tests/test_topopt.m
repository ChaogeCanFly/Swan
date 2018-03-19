%% TOP OPT TEST ===========================================================

clear; close all;

fprintf('Running TopOpt tests...\n')

%% Test Declaration -------------------------------------------------------
tests_topopt = {'test_cantilever','test_gripping','test_micro'};
% tests_topopt = {'test_micro'};

%% Run Top Opt Tests ------------------------------------------------------
for i = 1:length(tests_topopt)
    clearvars -except tests_topopt i
    tic
    file_name = tests_topopt{i};
    file_name_in = strcat('./Input/',tests_topopt{i});
    load_file = strcat('./tests/',file_name);
    run(tests_topopt{i})
    load(load_file)
    settings.filename = file_name_in;
    obj = TopOpt_Problem(settings);
    obj.preProcess;
    obj.computeVariables;
    error = norm(obj.x - x)/norm(x);
    if error < 1e-6
        cprintf('green',strcat(file_name,' PASSED.  Error: ',num2str(error),'\n'));
    else
        cprintf('err',strcat(file_name,' FAILED. Error: ',num2str(error),'\n'));
    end
    toc
    clear settings
end

fprintf('\nTopOpt tests completed.\n')
fprintf('\n-------------------------------------------\n\n')