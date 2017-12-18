clc
clear variables
addpath(genpath('.\FEM\'));
addpath(genpath('.\Input\'));

%% Steps
% 1 - Run 'Main.m'
% 2 - Create object --> obj = Physical_Problem(filename);
% 3 - Preprocess    --> obj.preProcess;
% 4 - Compute       --> obj.computeVariables;
% 5 - Postprocess   --> obj.postProcess;
%% test
run('test.m')
clear variables
%% Main.m

triangle_linear = Physical_Problem('CantileverBeam_Triangle_Linear');
triangle_linear.preProcess;
triangle_linear.computeVariables;
triangle_linear.postProcess;

fprintf('Ok\n');

Micro_Square_Triangle = Physical_Problem_Micro('RVE_Square_Triangle');
Micro_Square_Triangle.preProcess;
Micro_Square_Triangle.computeVariables;
Micro_Square_Triangle.postProcess;

 
% triangle_quadratic = Physical_Problem('CantileverBeam_Triangle_Quadratic');
% triangle_quadratic.preProcess;
% triangle_quadratic.computeVariables;
% triangle_quadratic.postProcess;
% 
% 
% quadrilateral_bilinear = Physical_Problem('Cantileverbeam_Quadrilateral_Bilinear');
% quadrilateral_bilinear.preProcess;
% quadrilateral_bilinear.computeVariables;
% quadrilateral_bilinear.postProcess;
% 
% quadrilateral_serendipity = Physical_Problem('Cantileverbeam_Quadrilateral_Serendipity');
% quadrilateral_serendipity.preProcess
% quadrilateral_serendipity.computeVariables;
% quadrilateral_serendipity.postProcess;

