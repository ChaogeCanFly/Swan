%% TOP OPT TEST ===========================================================

clear; close all;

fprintf('Running TopOpt tests...\n')

%% Test Declaration -------------------------------------------------------

tests_topopt = {'test_cantilever','test_cantilever2','test_cantilever3','test_gripping','test_bridge','test_bridge2','test_micro','test_micro2'};

%% Run Top Opt Tests ------------------------------------------------------
for i = 1:length(tests_topopt)
    clearvars -except tests_topopt i
    tic
    file_name = tests_topopt{i};
    file_name_in = strcat('./Input/',tests_topopt{i});
    settings = Settings(file_name_in);
    load_file = strcat('./tests/',file_name);
    load(load_file)
    
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! DELETE !!!!!!!!!!!!!!!!!!!!!!!!!!!!! %
    if contains(file_name,'bridge')
        if contains(file_name,'2')
            dim = [60 20 20]; div = [24 8 8];
            [A1,b1,A0,b0] = conversionTensors3D(settings.filename,dim,div);
        else
            dim = [2 1]; div = [120 60];
            [A1,b1,A0,b0] = conversionTensors(settings.filename,dim,div);
        end
        save(fullfile(pwd,'Allaire_ShapeOpt','conversion'),'A0','A1','b0','b1','dim','div');
    end
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %
    obj = TopOpt_Problem(settings);
    obj.preProcess;
    obj.computeVariables;
    error = norm(obj.x - x)/norm(x);
    if error < 1e-9
        cprintf('green',strcat(file_name,' PASSED.  Error: ',num2str(error),'\n'));
    else
        cprintf('err',strcat(file_name,' FAILED. Error: ',num2str(error),'\n'));
    end
    toc
    clear settings
end

fprintf('\nTopOpt tests completed.\n')
fprintf('\n-------------------------------------------\n\n')