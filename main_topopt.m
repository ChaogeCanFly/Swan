clc; clear variables; close all;
addpath(genpath(fileparts(mfilename('fullpath'))));

%% Test
run('test_fem.m');
run('test_topopt.m');
% clear variables;

%% Settings

% settings = Settings('CantileverTriangle_Case_2_2_3');
settings=Settings('HoneyComb');%Vfrac07   Vfrac05n5 Bulk1 MicroTriangle_Case_3_7_1

%% Main
tic
test = TopOpt_Problem(settings);
test.preProcess;
test.computeVariables;
toc
test.postProcess;