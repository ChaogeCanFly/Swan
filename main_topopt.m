clc
clear variables;close all;
addpath(genpath('.\FEM\'));
addpath(genpath('.\Topology Optimization\'));
%% test
%run('test.m')
clear variables
%% settings
settings=struct;
settings.filename='TOPOPT_TEST';    
settings.method='SIMPALL';
settings.material='ISOTROPIC';
settings.topoptproblem='Compliance_st_Volume';
settings.initial_case='full';
settings.TOL.rho_plus=1;
settings.TOL.rho_minus=0;
settings.TOL.E_plus=1;
settings.TOL.E_minus=1e-3;
settings.TOL.nu_plus=1/3;
settings.TOL.nu_minus=1/3;
settings.optTOL=0.0175;
settings.constraintTOL=1e-3;
settings.Vfrac=0.3;
%% main
switch settings.topoptproblem
    case 'Compliance_st_Volume'
        test=TopOpt_Problem_Compliance_st_Volume(settings);
    otherwise
        disp('Problem not added')
end

test.computeVariables;